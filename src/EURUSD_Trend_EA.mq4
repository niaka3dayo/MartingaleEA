//+------------------------------------------------------------------+
//|                                                EURUSD_Trend_EA.mq4 |
//|                                          FX自動売買EAプロジェクト |
//|                                                                    |
//+------------------------------------------------------------------+
#property copyright "FX自動売買EAプロジェクト"
#property link      ""
#property version   "1.00"
#property strict

// 外部パラメーター（ユーザーが設定可能）
// トレード設定
extern string Trade_Settings = "===== トレード設定 =====";
extern double InitialLotSize = 0.1;       // 初期ロットサイズ
extern double MaxLotSize = 5.0;           // 最大ロットサイズ
extern bool UseMoneyManagement = true;    // 資金管理を使用する
extern double RiskPercent = 2.0;          // リスク率（％）
extern int StopLoss = 50;                 // ストップロス（ポイント）
extern int TakeProfit = 100;              // 利益確定（ポイント）
extern int TrailingStop = 30;             // トレーリングストップ（ポイント）
extern int Slippage = 3;                  // スリッページ（ポイント）
extern int MaxSpread = 5;                 // 最大許容スプレッド（ポイント）

// 時間設定
extern string Time_Settings = "===== 時間設定 =====";
extern bool UseTimeFilter = true;         // 時間フィルターを使用する
extern int StartHour = 8;                 // 開始時間（時）
extern int EndHour = 20;                  // 終了時間（時）
extern bool MondayFilter = false;         // 月曜日を除外
extern bool FridayFilter = true;          // 金曜日を除外

// トレンド判定設定
extern string Trend_Settings = "===== トレンド判定設定 =====";
extern int FastEMA = 8;                   // 短期EMA期間
extern int SlowEMA = 21;                  // 長期EMA期間
extern int SignalEMA = 13;                // シグナルEMA期間
extern int RSI_Period = 14;               // RSI期間
extern int RSI_UpperLevel = 70;           // RSI上限レベル
extern int RSI_LowerLevel = 30;           // RSI下限レベル
extern int ADX_Period = 14;               // ADX期間
extern int ADX_MinLevel = 25;             // ADX最小レベル
extern int MACD_FastEMA = 12;             // MACD短期EMA
extern int MACD_SlowEMA = 26;             // MACD長期EMA
extern int MACD_SignalPeriod = 9;         // MACDシグナル期間

// その他の設定
extern string Other_Settings = "===== その他の設定 =====";
extern int MagicNumber = 20240601;        // マジックナンバー
extern bool EnableDebugLog = false;       // デバッグログを有効にする
extern bool SendPushNotifications = false; // プッシュ通知を送信する
extern bool CloseAllFriday = true;        // 金曜日に全ポジションを閉じる
extern int FridayCloseHour = 20;          // 金曜日のクローズ時間（時）

// グローバル変数
double g_point;                           // ポイント値
int g_digits;                             // 小数点以下の桁数
bool g_ecnBroker = false;                 // ECNブローカーフラグ
datetime g_lastTradeTime = 0;             // 最後のトレード時間
int g_totalOrders = 0;                    // 総注文数
double g_accountBalance = 0;              // 口座残高

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // 通貨ペアの確認
    if(Symbol() != "EURUSD") {
        Print("このEAはEURUSDのみで使用できます。現在のチャート: ", Symbol());
        return INIT_FAILED;
    }

    // ポイント値と小数点以下の桁数を設定
    g_digits = Digits;
    g_point = Point;
    if(g_digits == 3 || g_digits == 5) {
        g_point = Point * 10;
    }

    // ECNブローカーの確認
    if(MarketInfo(Symbol(), MODE_STOPLEVEL) > 0) {
        g_ecnBroker = true;
    }

    // 口座残高を記録
    g_accountBalance = AccountBalance();

    // 初期化メッセージ
    Print("EURUSD_Trend_EA 初期化完了");
    Print("通貨ペア: ", Symbol(), ", 時間足: ", Period());
    Print("初期ロットサイズ: ", InitialLotSize, ", 最大ロットサイズ: ", MaxLotSize);
    Print("ストップロス: ", StopLoss, ", 利益確定: ", TakeProfit);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("EURUSD_Trend_EA 終了: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // 新しいローソク足の確認
    static datetime lastBar;
    datetime currentBar = Time[0];

    // 同じローソク足内での複数実行を防止
    if(lastBar == currentBar) {
        // トレーリングストップの処理
        if(TrailingStop > 0) {
            ManageTrailingStop();
        }
        return;
    }
    lastBar = currentBar;

    // デバッグログ
    if(EnableDebugLog) {
        Print("新しいローソク足: ", TimeToStr(currentBar));
    }

    // 取引時間のチェック
    if(!IsTradeAllowed()) {
        return;
    }

    // スプレッドのチェック
    double currentSpread = MarketInfo(Symbol(), MODE_SPREAD);
    if(currentSpread > MaxSpread) {
        if(EnableDebugLog) {
            Print("スプレッドが大きすぎます: ", currentSpread);
        }
        return;
    }

    // 金曜日の全ポジションクローズ処理
    if(CloseAllFriday && DayOfWeek() == 5 && Hour() >= FridayCloseHour) {
        CloseAllPositions();
        return;
    }

    // 既存のポジションの確認
    g_totalOrders = CountOrders();

    // トレンド分析
    int trendSignal = AnalyzeTrend();

    // トレード実行
    if(g_totalOrders == 0) {
        if(trendSignal == 1) {
            OpenBuyOrder();
        }
        else if(trendSignal == -1) {
            OpenSellOrder();
        }
    }

    // トレーリングストップの処理
    if(TrailingStop > 0) {
        ManageTrailingStop();
    }
}

//+------------------------------------------------------------------+
//| トレンド分析関数                                                 |
//+------------------------------------------------------------------+
int AnalyzeTrend()
{
    // EMAの計算
    double fastEMA = iMA(Symbol(), 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
    double slowEMA = iMA(Symbol(), 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
    double signalEMA = iMA(Symbol(), 0, SignalEMA, 0, MODE_EMA, PRICE_CLOSE, 0);

    // RSIの計算
    double rsi = iRSI(Symbol(), 0, RSI_Period, PRICE_CLOSE, 0);

    // ADXの計算
    double adx = iADX(Symbol(), 0, ADX_Period, PRICE_CLOSE, MODE_MAIN, 0);
    double plusDI = iADX(Symbol(), 0, ADX_Period, PRICE_CLOSE, MODE_PLUSDI, 0);
    double minusDI = iADX(Symbol(), 0, ADX_Period, PRICE_CLOSE, MODE_MINUSDI, 0);

    // MACDの計算
    double macd = iMACD(Symbol(), 0, MACD_FastEMA, MACD_SlowEMA, MACD_SignalPeriod, PRICE_CLOSE, MODE_MAIN, 0);
    double macdSignal = iMACD(Symbol(), 0, MACD_FastEMA, MACD_SlowEMA, MACD_SignalPeriod, PRICE_CLOSE, MODE_SIGNAL, 0);

    // トレンドスコアの計算（-3から+3の範囲）
    int trendScore = 0;

    // EMAクロスオーバー
    if(fastEMA > slowEMA) trendScore++;
    if(fastEMA < slowEMA) trendScore--;

    // RSIシグナル
    if(rsi < RSI_LowerLevel) trendScore++;
    if(rsi > RSI_UpperLevel) trendScore--;

    // ADXシグナル
    if(adx > ADX_MinLevel) {
        if(plusDI > minusDI) trendScore++;
        if(plusDI < minusDI) trendScore--;
    }

    // MACDシグナル
    if(macd > macdSignal) trendScore++;
    if(macd < macdSignal) trendScore--;

    // デバッグログ
    if(EnableDebugLog) {
        Print("トレンドスコア: ", trendScore);
        Print("FastEMA: ", fastEMA, ", SlowEMA: ", slowEMA);
        Print("RSI: ", rsi, ", ADX: ", adx);
        Print("MACD: ", macd, ", MACDシグナル: ", macdSignal);
    }

    // 最終的なシグナル
    if(trendScore >= 2) return 1;  // 買いシグナル
    if(trendScore <= -2) return -1; // 売りシグナル

    return 0; // ニュートラル
}

//+------------------------------------------------------------------+
//| 買いポジションを開く                                             |
//+------------------------------------------------------------------+
void OpenBuyOrder()
{
    double lotSize = CalculateLotSize();
    double stopLossPrice = Ask - StopLoss * g_point;
    double takeProfitPrice = Ask + TakeProfit * g_point;

    // ECNブローカー対応
    int ticket;
    if(g_ecnBroker) {
        ticket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, Slippage, 0, 0, "EURUSD_Trend_EA", MagicNumber, 0, Blue);
        if(ticket > 0) {
            if(OrderSelect(ticket, SELECT_BY_TICKET)) {
                OrderModify(ticket, OrderOpenPrice(), stopLossPrice, takeProfitPrice, 0, Blue);
            }
        }
    } else {
        ticket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, Slippage, stopLossPrice, takeProfitPrice, "EURUSD_Trend_EA", MagicNumber, 0, Blue);
    }

    if(ticket > 0) {
        Print("買いポジションを開きました - ロットサイズ: ", lotSize, ", SL: ", stopLossPrice, ", TP: ", takeProfitPrice);
        g_lastTradeTime = Time[0];

        // プッシュ通知
        if(SendPushNotifications) {
            SendNotification("EURUSD_Trend_EA: 買いポジションを開きました - ロットサイズ: " + DoubleToStr(lotSize, 2));
        }
    } else {
        Print("買いポジションを開けませんでした。エラーコード: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| 売りポジションを開く                                             |
//+------------------------------------------------------------------+
void OpenSellOrder()
{
    double lotSize = CalculateLotSize();
    double stopLossPrice = Bid + StopLoss * g_point;
    double takeProfitPrice = Bid - TakeProfit * g_point;

    // ECNブローカー対応
    int ticket;
    if(g_ecnBroker) {
        ticket = OrderSend(Symbol(), OP_SELL, lotSize, Bid, Slippage, 0, 0, "EURUSD_Trend_EA", MagicNumber, 0, Red);
        if(ticket > 0) {
            if(OrderSelect(ticket, SELECT_BY_TICKET)) {
                OrderModify(ticket, OrderOpenPrice(), stopLossPrice, takeProfitPrice, 0, Red);
            }
        }
    } else {
        ticket = OrderSend(Symbol(), OP_SELL, lotSize, Bid, Slippage, stopLossPrice, takeProfitPrice, "EURUSD_Trend_EA", MagicNumber, 0, Red);
    }

    if(ticket > 0) {
        Print("売りポジションを開きました - ロットサイズ: ", lotSize, ", SL: ", stopLossPrice, ", TP: ", takeProfitPrice);
        g_lastTradeTime = Time[0];

        // プッシュ通知
        if(SendPushNotifications) {
            SendNotification("EURUSD_Trend_EA: 売りポジションを開きました - ロットサイズ: " + DoubleToStr(lotSize, 2));
        }
    } else {
        Print("売りポジションを開けませんでした。エラーコード: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| ロットサイズの計算                                               |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
    double lotSize = InitialLotSize;

    // 資金管理を使用する場合
    if(UseMoneyManagement) {
        double accountEquity = AccountEquity();
        double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);

        if(tickValue != 0 && StopLoss != 0) {
            // リスク率に基づいてロットサイズを計算
            lotSize = (accountEquity * RiskPercent / 100) / (StopLoss * tickValue);

            // ロットサイズの正規化
            double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
            lotSize = NormalizeDouble(lotSize / lotStep, 0) * lotStep;

            // 最小・最大ロットサイズの制限
            double minLot = MarketInfo(Symbol(), MODE_MINLOT);
            if(lotSize < minLot) lotSize = minLot;
            if(lotSize > MaxLotSize) lotSize = MaxLotSize;
        }
    }

    return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| トレーリングストップの管理                                       |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
    for(int i = 0; i < OrdersTotal(); i++) {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
                // 買いポジションのトレーリングストップ
                if(OrderType() == OP_BUY) {
                    if(Bid - OrderOpenPrice() > TrailingStop * g_point) {
                        if(OrderStopLoss() < Bid - TrailingStop * g_point) {
                            OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * g_point, OrderTakeProfit(), 0, Blue);
                        }
                    }
                }
                // 売りポジションのトレーリングストップ
                else if(OrderType() == OP_SELL) {
                    if(OrderOpenPrice() - Ask > TrailingStop * g_point) {
                        if(OrderStopLoss() > Ask + TrailingStop * g_point || OrderStopLoss() == 0) {
                            OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TrailingStop * g_point, OrderTakeProfit(), 0, Red);
                        }
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| 全ポジションを閉じる                                             |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
    for(int i = OrdersTotal() - 1; i >= 0; i--) {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
                bool result = false;

                if(OrderType() == OP_BUY) {
                    result = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, Blue);
                }
                else if(OrderType() == OP_SELL) {
                    result = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, Red);
                }

                if(result) {
                    Print("ポジションを閉じました: ", OrderTicket());
                } else {
                    Print("ポジションを閉じられませんでした: ", OrderTicket(), ", エラー: ", GetLastError());
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| 注文数のカウント                                                 |
//+------------------------------------------------------------------+
int CountOrders()
{
    int count = 0;

    for(int i = 0; i < OrdersTotal(); i++) {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
                count++;
            }
        }
    }

    return count;
}

//+------------------------------------------------------------------+
//| 取引時間のチェック                                               |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
{
    // 時間フィルターが無効の場合は常に取引可能
    if(!UseTimeFilter) {
        return true;
    }

    // 曜日フィルター
    if(MondayFilter && DayOfWeek() == 1) {
        return false; // 月曜日は取引しない
    }

    if(FridayFilter && DayOfWeek() == 5) {
        return false; // 金曜日は取引しない
    }

    // 時間フィルター
    int currentHour = Hour();
    if(StartHour <= EndHour) {
        // 通常の時間範囲
        if(currentHour >= StartHour && currentHour < EndHour) {
            return true;
        }
    } else {
        // 日をまたぐ時間範囲
        if(currentHour >= StartHour || currentHour < EndHour) {
            return true;
        }
    }

    return false;
}
