//+------------------------------------------------------------------+
//|                                                 MartingaleEA.mq4 |
//|                                             FX自動売買EAプロジェクト |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "FX自動売買EAプロジェクト"
#property link      "https://github.com/fx-ea-project"
#property version   "1.00"
#property strict

// 外部パラメータ
extern double InitialLotSize = 0.01;    // 初期ロットサイズ
extern double MaxLotSize = 10.0;        // 最大ロットサイズ
extern double LotMultiplier = 2.0;      // 損失時のロット倍率
extern int StopLoss = 50;               // ストップロス（ポイント）
extern int TakeProfit = 20;             // 利益確定（ポイント）
extern int MagicNumber = 98765;         // マジックナンバー（EA識別用）
extern int FastMA = 5;                  // 短期移動平均線の期間
extern int SlowMA = 20;                 // 長期移動平均線の期間

// グローバル変数
double g_currentLotSize = 0;
bool g_lastTradeWasLoss = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // 初期化処理
   g_currentLotSize = InitialLotSize;
   Print("MartingaleEA 初期化完了");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // 終了処理
   Print("MartingaleEA 終了");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // 自動売買が許可されているか確認
   if(IsTradeAllowed() == false)
   {
      Print("自動売買が許可されていません");
      return;
   }

   // 履歴の確認と次のロットサイズの計算
   CheckHistory();

   // ポジション数の確認
   int totalPositions = CountPositions();

   // 新規シグナルの確認
   int signal = CheckSignal();

   // トレード実行
   if(totalPositions == 0 && signal != 0)
   {
      if(signal > 0)
      {
         OpenBuy();
      }
      else if(signal < 0)
      {
         OpenSell();
      }
   }
}

//+------------------------------------------------------------------+
//| シグナルチェック関数                                              |
//+------------------------------------------------------------------+
int CheckSignal()
{
   // 移動平均線の計算
   double fastMA_current = iMA(Symbol(), 0, FastMA, 0, MODE_SMA, PRICE_CLOSE, 0);
   double fastMA_prev = iMA(Symbol(), 0, FastMA, 0, MODE_SMA, PRICE_CLOSE, 1);
   double slowMA_current = iMA(Symbol(), 0, SlowMA, 0, MODE_SMA, PRICE_CLOSE, 0);
   double slowMA_prev = iMA(Symbol(), 0, SlowMA, 0, MODE_SMA, PRICE_CLOSE, 1);

   // クロスオーバーの確認
   if(fastMA_prev < slowMA_prev && fastMA_current > slowMA_current)
   {
      // 買いシグナル
      return 1;
   }
   else if(fastMA_prev > slowMA_prev && fastMA_current < slowMA_current)
   {
      // 売りシグナル
      return -1;
   }

   // シグナルなし
   return 0;
}

//+------------------------------------------------------------------+
//| 履歴確認関数                                                      |
//+------------------------------------------------------------------+
void CheckHistory()
{
   // 最後の取引結果を確認
   for(int i = 0; i < OrdersHistoryTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            // 最後の取引が損失だった場合
            if(OrderProfit() < 0)
            {
               g_lastTradeWasLoss = true;
               g_currentLotSize = MathMin(g_currentLotSize * LotMultiplier, MaxLotSize);
               Print("前回の取引は損失。次のロットサイズ: ", g_currentLotSize);
            }
            else
            {
               g_lastTradeWasLoss = false;
               g_currentLotSize = InitialLotSize;
               Print("前回の取引は利益。ロットサイズをリセット: ", g_currentLotSize);
            }
            break;
         }
      }
   }

   // 初回取引または履歴がない場合
   if(OrdersHistoryTotal() == 0 || g_currentLotSize == 0)
   {
      g_currentLotSize = InitialLotSize;
   }

   // ロットサイズの正規化
   g_currentLotSize = NormalizeLotSize(g_currentLotSize);
}

//+------------------------------------------------------------------+
//| ロットサイズ正規化関数                                            |
//+------------------------------------------------------------------+
double NormalizeLotSize(double lotSize)
{
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);

   lotSize = MathMax(minLot, lotSize);
   lotSize = MathMin(maxLot, lotSize);
   lotSize = MathRound(lotSize / lotStep) * lotStep;

   return(lotSize);
}

//+------------------------------------------------------------------+
//| ポジション数カウント関数                                          |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;

   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            count++;
         }
      }
   }

   return count;
}

//+------------------------------------------------------------------+
//| 買いポジションオープン関数                                        |
//+------------------------------------------------------------------+
void OpenBuy()
{
   double sl = 0;
   double tp = 0;

   if(StopLoss > 0)
   {
      sl = Ask - StopLoss * Point;
   }

   if(TakeProfit > 0)
   {
      tp = Ask + TakeProfit * Point;
   }

   int ticket = OrderSend(Symbol(), OP_BUY, g_currentLotSize, Ask, 3, sl, tp, "MartingaleEA Buy", MagicNumber, 0, Green);

   if(ticket < 0)
   {
      Print("買い注文エラー: ", GetLastError());
   }
   else
   {
      Print("買い注文成功: チケット番号 ", ticket, " ロットサイズ: ", g_currentLotSize);
   }
}

//+------------------------------------------------------------------+
//| 売りポジションオープン関数                                        |
//+------------------------------------------------------------------+
void OpenSell()
{
   double sl = 0;
   double tp = 0;

   if(StopLoss > 0)
   {
      sl = Bid + StopLoss * Point;
   }

   if(TakeProfit > 0)
   {
      tp = Bid - TakeProfit * Point;
   }

   int ticket = OrderSend(Symbol(), OP_SELL, g_currentLotSize, Bid, 3, sl, tp, "MartingaleEA Sell", MagicNumber, 0, Red);

   if(ticket < 0)
   {
      Print("売り注文エラー: ", GetLastError());
   }
   else
   {
      Print("売り注文成功: チケット番号 ", ticket, " ロットサイズ: ", g_currentLotSize);
   }
}
