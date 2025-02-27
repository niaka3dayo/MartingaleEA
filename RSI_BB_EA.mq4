//+------------------------------------------------------------------+
//|                                                    RSI_BB_EA.mq4 |
//|                                             FX自動売買EAプロジェクト |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "FX自動売買EAプロジェクト"
#property link      "https://github.com/fx-ea-project"
#property version   "1.00"
#property strict

// 外部パラメータ
extern int RSI_Period = 14;         // RSIの期間
extern int RSI_UpperLevel = 70;     // RSIの上限レベル
extern int RSI_LowerLevel = 30;     // RSIの下限レベル
extern int BB_Period = 20;          // ボリンジャーバンドの期間
extern double BB_Deviation = 2.0;   // ボリンジャーバンドの標準偏差
extern double LotSize = 0.1;        // 取引ロットサイズ
extern int StopLoss = 50;           // ストップロス（ポイント）
extern int TakeProfit = 100;        // 利益確定（ポイント）
extern int TrailingStop = 30;       // トレーリングストップ（ポイント）
extern int MagicNumber = 54321;     // マジックナンバー（EA識別用）

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // 初期化処理
   Print("RSI_BB_EA 初期化完了");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // 終了処理
   Print("RSI_BB_EA 終了");
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

   // 新規シグナルの確認
   int signal = CheckSignal();

   // ポジション管理
   ManagePositions();

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
   // RSIの計算
   double rsi = iRSI(Symbol(), 0, RSI_Period, PRICE_CLOSE, 0);

   // ボリンジャーバンドの計算
   double bb_upper = iBands(Symbol(), 0, BB_Period, BB_Deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double bb_lower = iBands(Symbol(), 0, BB_Period, BB_Deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
   double bb_middle = iBands(Symbol(), 0, BB_Period, BB_Deviation, 0, PRICE_CLOSE, MODE_MAIN, 0);

   double current_price = Close[0];

   // 買いシグナル: RSIが下限を下回り、価格がボリンジャーバンドの下限に近い
   if(rsi < RSI_LowerLevel && current_price < bb_lower + (bb_middle - bb_lower) * 0.2)
   {
      return 1; // 買いシグナル
   }

   // 売りシグナル: RSIが上限を上回り、価格がボリンジャーバンドの上限に近い
   if(rsi > RSI_UpperLevel && current_price > bb_upper - (bb_upper - bb_middle) * 0.2)
   {
      return -1; // 売りシグナル
   }

   return 0; // シグナルなし
}

//+------------------------------------------------------------------+
//| ポジション管理関数                                                |
//+------------------------------------------------------------------+
void ManagePositions()
{
   // トレーリングストップの適用
   if(TrailingStop > 0)
   {
      for(int i = 0; i < OrdersTotal(); i++)
      {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            {
               // 買いポジションのトレーリングストップ
               if(OrderType() == OP_BUY)
               {
                  if(Bid - OrderOpenPrice() > Point * TrailingStop)
                  {
                     if(OrderStopLoss() < Bid - Point * TrailingStop)
                     {
                        bool result = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point * TrailingStop, OrderTakeProfit(), 0, Green);
                        if(!result)
                        {
                           Print("トレーリングストップ設定エラー（買い）: ", GetLastError());
                        }
                     }
                  }
               }
               // 売りポジションのトレーリングストップ
               else if(OrderType() == OP_SELL)
               {
                  if(OrderOpenPrice() - Ask > Point * TrailingStop)
                  {
                     if(OrderStopLoss() > Ask + Point * TrailingStop || OrderStopLoss() == 0)
                     {
                        bool result = OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TrailingStop, OrderTakeProfit(), 0, Red);
                        if(!result)
                        {
                           Print("トレーリングストップ設定エラー（売り）: ", GetLastError());
                        }
                     }
                  }
               }
            }
         }
      }
   }
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

   int ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, sl, tp, "RSI_BB_EA Buy", MagicNumber, 0, Green);

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

   int ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, sl, tp, "RSI_BB_EA Sell", MagicNumber, 0, Red);

   if(ticket < 0)
   {
      Print("売り注文エラー: ", GetLastError());
   }
   else
   {
      Print("売り注文成功: チケット番号 ", ticket);
   }
}
