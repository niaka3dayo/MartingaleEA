//+------------------------------------------------------------------+
//|                                                SimpleMAcrossEA.mq4 |
//|                                             FX自動売買EAプロジェクト |
//|                                                                    |
//+------------------------------------------------------------------+
#property copyright "FX自動売買EAプロジェクト"
#property link      "https://github.com/fx-ea-project"
#property version   "1.00"
#property strict

// 外部パラメータ
extern int ShortMA = 10;        // 短期移動平均線の期間
extern int LongMA = 30;         // 長期移動平均線の期間
extern double LotSize = 0.1;    // 取引ロットサイズ
extern int StopLoss = 50;       // ストップロス（ポイント）
extern int TakeProfit = 100;    // 利益確定（ポイント）
extern int MagicNumber = 12345; // マジックナンバー（EA識別用）

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // 初期化処理
   Print("SimpleMAcrossEA 初期化完了");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // 終了処理
   Print("SimpleMAcrossEA 終了");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // 既存ポジションの確認
   if(IsTradeAllowed() == false)
   {
      Print("自動売買が許可されていません");
      return;
   }

   // 新規シグナルの確認
   int signal = CheckSignal();

   // ポジション数の確認
   int totalPositions = CountPositions();

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
   double shortMA_current = iMA(Symbol(), 0, ShortMA, 0, MODE_SMA, PRICE_CLOSE, 0);
   double shortMA_prev = iMA(Symbol(), 0, ShortMA, 0, MODE_SMA, PRICE_CLOSE, 1);
   double longMA_current = iMA(Symbol(), 0, LongMA, 0, MODE_SMA, PRICE_CLOSE, 0);
   double longMA_prev = iMA(Symbol(), 0, LongMA, 0, MODE_SMA, PRICE_CLOSE, 1);

   // クロスオーバーの確認
   if(shortMA_prev < longMA_prev && shortMA_current > longMA_current)
   {
      // 買いシグナル
      return 1;
   }
   else if(shortMA_prev > longMA_prev && shortMA_current < longMA_current)
   {
      // 売りシグナル
      return -1;
   }

   // シグナルなし
   return 0;
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

   int ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, sl, tp, "SimpleMAcrossEA Buy", MagicNumber, 0, Green);

   if(ticket < 0)
   {
      Print("買い注文エラー: ", GetLastError());
   }
   else
   {
      Print("買い注文成功: チケット番号 ", ticket);
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

   int ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, sl, tp, "SimpleMAcrossEA Sell", MagicNumber, 0, Red);

   if(ticket < 0)
   {
      Print("売り注文エラー: ", GetLastError());
   }
   else
   {
      Print("売り注文成功: チケット番号 ", ticket);
   }
}
