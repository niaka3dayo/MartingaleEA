//+------------------------------------------------------------------+
//|                                                 MartingaleEA.mq4 |
//|                                             FX自動売買EAプロジェクト |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "FX自動売買EAプロジェクト"
#property link      "https://github.com/fx-ea-project"
#property version   "1.10"
#property strict

//--- 定数定義
#define SIGNAL_BUY  1
#define SIGNAL_SELL -1
#define SIGNAL_NONE 0

//--- 入力パラメータ（トレード設定）
input group "トレード設定"
input double InitialLotSize = 0.01;    // 初期ロットサイズ
input double MaxLotSize = 10.0;        // 最大ロットサイズ
input double LotMultiplier = 2.0;      // 損失時のロット倍率
input int StopLoss = 50;               // ストップロス（ポイント）
input int TakeProfit = 20;             // 利益確定（ポイント）
input int Slippage = 3;                // スリッページ（ポイント）

//--- 入力パラメータ（シグナル設定）
input group "シグナル設定"
input int FastMA = 5;                  // 短期移動平均線の期間
input int SlowMA = 20;                 // 長期移動平均線の期間
input ENUM_MA_METHOD MAMethod = MODE_SMA; // 移動平均線の計算方法
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE; // 適用価格

//--- 入力パラメータ（その他）
input group "その他の設定"
input int MagicNumber = 98765;         // マジックナンバー（EA識別用）
input bool EnableDebugLog = false;     // デバッグログを有効にする

//--- グローバル変数
double g_lotSize = 0;                  // 現在のロットサイズ
bool g_isInitialized = false;          // 初期化フラグ

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // パラメータの検証
   if(!ValidateParameters())
   {
      return(INIT_PARAMETERS_INCORRECT);
   }

   // 初期化処理
   g_lotSize = InitialLotSize;
   g_isInitialized = true;

   // 情報表示
   PrintInfo("MartingaleEA 初期化完了");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // 終了処理
   PrintInfo("MartingaleEA 終了 - 理由コード: " + IntegerToString(reason));
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // 初期化チェック
   if(!g_isInitialized)
   {
      PrintError("EAが正しく初期化されていません");
      return;
   }

   // 自動売買が許可されているか確認
   if(!IsTradeAllowed())
   {
      PrintError("自動売買が許可されていません");
      return;
   }

   // 新規取引の条件チェック
   if(!IsNewBarFormed())
   {
      return; // 新しいバーが形成されていない場合は処理しない
   }

   // 履歴の確認と次のロットサイズの計算
   UpdateLotSize();

   // ポジション数の確認
   int totalPositions = CountPositions();

   // 新規シグナルの確認
   int signal = GetSignal();

   // トレード実行
   if(totalPositions == 0 && signal != SIGNAL_NONE)
   {
      ExecuteTrade(signal);
   }
}

//+------------------------------------------------------------------+
//| パラメータ検証関数                                                |
//+------------------------------------------------------------------+
bool ValidateParameters()
{
   // ロットサイズの検証
   if(InitialLotSize <= 0 || MaxLotSize <= 0)
   {
      PrintError("ロットサイズは0より大きい値を設定してください");
      return false;
   }

   // 倍率の検証
   if(LotMultiplier <= 0)
   {
      PrintError("ロット倍率は0より大きい値を設定してください");
      return false;
   }

   // 移動平均線の期間検証
   if(FastMA <= 0 || SlowMA <= 0)
   {
      PrintError("移動平均線の期間は0より大きい値を設定してください");
      return false;
   }

   // スリッページの検証
   if(Slippage < 0)
   {
      PrintError("スリッページは0以上の値を設定してください");
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| 新しいバーが形成されたかチェックする関数                           |
//+------------------------------------------------------------------+
bool IsNewBarFormed()
{
   static datetime lastBarTime = 0;
   datetime currentBarTime = iTime(Symbol(), 0, 0);

   if(lastBarTime != currentBarTime)
   {
      lastBarTime = currentBarTime;
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| シグナル取得関数                                                  |
//+------------------------------------------------------------------+
int GetSignal()
{
   // 移動平均線の計算
   double fastMA_current = iMA(Symbol(), 0, FastMA, 0, MAMethod, AppliedPrice, 0);
   double fastMA_prev = iMA(Symbol(), 0, FastMA, 0, MAMethod, AppliedPrice, 1);
   double slowMA_current = iMA(Symbol(), 0, SlowMA, 0, MAMethod, AppliedPrice, 0);
   double slowMA_prev = iMA(Symbol(), 0, SlowMA, 0, MAMethod, AppliedPrice, 1);

   // クロスオーバーの確認
   if(fastMA_prev < slowMA_prev && fastMA_current > slowMA_current)
   {
      // 買いシグナル
      PrintDebug("買いシグナル検出: FastMA(" + DoubleToString(fastMA_current, 5) +
                ") > SlowMA(" + DoubleToString(slowMA_current, 5) + ")");
      return SIGNAL_BUY;
   }
   else if(fastMA_prev > slowMA_prev && fastMA_current < slowMA_current)
   {
      // 売りシグナル
      PrintDebug("売りシグナル検出: FastMA(" + DoubleToString(fastMA_current, 5) +
                ") < SlowMA(" + DoubleToString(slowMA_current, 5) + ")");
      return SIGNAL_SELL;
   }

   // シグナルなし
   return SIGNAL_NONE;
}

//+------------------------------------------------------------------+
//| ロットサイズ更新関数                                              |
//+------------------------------------------------------------------+
void UpdateLotSize()
{
   bool lastTradeWasLoss = false;
   bool foundLastTrade = false;

   // 最後の取引結果を確認
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            // 最後の取引が損失だった場合
            if(OrderProfit() < 0)
            {
               lastTradeWasLoss = true;
               g_lotSize = NormalizeLotSize(MathMin(g_lotSize * LotMultiplier, MaxLotSize));
               PrintInfo("前回の取引は損失。次のロットサイズ: " + DoubleToString(g_lotSize, 2));
            }
            else
            {
               lastTradeWasLoss = false;
               g_lotSize = NormalizeLotSize(InitialLotSize);
               PrintInfo("前回の取引は利益。ロットサイズをリセット: " + DoubleToString(g_lotSize, 2));
            }
            foundLastTrade = true;
            break;
         }
      }
   }

   // 初回取引または履歴がない場合
   if(!foundLastTrade || g_lotSize <= 0)
   {
      g_lotSize = NormalizeLotSize(InitialLotSize);
      PrintDebug("初期ロットサイズを設定: " + DoubleToString(g_lotSize, 2));
   }
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
//| トレード実行関数                                                  |
//+------------------------------------------------------------------+
void ExecuteTrade(int signal)
{
   if(signal == SIGNAL_BUY)
   {
      OpenBuy();
   }
   else if(signal == SIGNAL_SELL)
   {
      OpenSell();
   }
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
      sl = NormalizeDouble(Ask - StopLoss * Point, Digits);
   }

   if(TakeProfit > 0)
   {
      tp = NormalizeDouble(Ask + TakeProfit * Point, Digits);
   }

   int ticket = OrderSend(Symbol(), OP_BUY, g_lotSize, Ask, Slippage, sl, tp,
                         "MartingaleEA Buy", MagicNumber, 0, Green);

   if(ticket < 0)
   {
      int errorCode = GetLastError();
      PrintError("買い注文エラー: " + IntegerToString(errorCode) + " - " + GetErrorDescription(errorCode));
   }
   else
   {
      PrintInfo("買い注文成功: チケット番号 " + IntegerToString(ticket) +
               " ロットサイズ: " + DoubleToString(g_lotSize, 2) +
               " SL: " + DoubleToString(sl, Digits) +
               " TP: " + DoubleToString(tp, Digits));
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
      sl = NormalizeDouble(Bid + StopLoss * Point, Digits);
   }

   if(TakeProfit > 0)
   {
      tp = NormalizeDouble(Bid - TakeProfit * Point, Digits);
   }

   int ticket = OrderSend(Symbol(), OP_SELL, g_lotSize, Bid, Slippage, sl, tp,
                         "MartingaleEA Sell", MagicNumber, 0, Red);

   if(ticket < 0)
   {
      int errorCode = GetLastError();
      PrintError("売り注文エラー: " + IntegerToString(errorCode) + " - " + GetErrorDescription(errorCode));
   }
   else
   {
      PrintInfo("売り注文成功: チケット番号 " + IntegerToString(ticket) +
               " ロットサイズ: " + DoubleToString(g_lotSize, 2) +
               " SL: " + DoubleToString(sl, Digits) +
               " TP: " + DoubleToString(tp, Digits));
   }
}

//+------------------------------------------------------------------+
//| エラーコード説明取得関数                                          |
//+------------------------------------------------------------------+
string GetErrorDescription(int errorCode)
{
   string errorDescription;

   switch(errorCode)
   {
      case 0:   errorDescription = "エラーなし"; break;
      case 1:   errorDescription = "一般エラー"; break;
      case 2:   errorDescription = "一般パラメータが無効"; break;
      case 3:   errorDescription = "取引パラメータが無効"; break;
      case 4:   errorDescription = "取引サーバーがビジー状態"; break;
      case 5:   errorDescription = "古いバージョンのクライアントターミナル"; break;
      case 6:   errorDescription = "サーバーに接続されていません"; break;
      case 7:   errorDescription = "操作が許可されていません"; break;
      case 8:   errorDescription = "リクエストが頻繁すぎる"; break;
      case 9:   errorDescription = "操作が多すぎてサーバーがビジー状態"; break;
      case 64:  errorDescription = "アカウントが無効"; break;
      case 65:  errorDescription = "無効なアカウント番号"; break;
      case 128: errorDescription = "取引タイムアウト"; break;
      case 129: errorDescription = "無効な価格"; break;
      case 130: errorDescription = "無効なストップ"; break;
      case 131: errorDescription = "無効なロットサイズ"; break;
      case 132: errorDescription = "市場が閉じています"; break;
      case 133: errorDescription = "取引が無効"; break;
      case 134: errorDescription = "資金不足"; break;
      case 135: errorDescription = "価格が変更されました"; break;
      case 136: errorDescription = "オフクォート"; break;
      case 137: errorDescription = "ブローカーがビジー状態"; break;
      case 138: errorDescription = "リクォートが必要"; break;
      case 139: errorDescription = "注文がロックされています"; break;
      case 140: errorDescription = "ロングポジションのみ許可"; break;
      case 141: errorDescription = "リクエストが多すぎる"; break;
      case 145: errorDescription = "過度の変更により修正が拒否"; break;
      case 146: errorDescription = "取引サーバーがビジー状態"; break;
      case 147: errorDescription = "期限切れの注文の使用"; break;
      default:  errorDescription = "未知のエラー"; break;
   }

   return errorDescription;
}

//+------------------------------------------------------------------+
//| 情報ログ出力関数                                                  |
//+------------------------------------------------------------------+
void PrintInfo(string message)
{
   Print("[INFO] ", message);
}

//+------------------------------------------------------------------+
//| エラーログ出力関数                                                |
//+------------------------------------------------------------------+
void PrintError(string message)
{
   Print("[ERROR] ", message);
}

//+------------------------------------------------------------------+
//| デバッグログ出力関数                                              |
//+------------------------------------------------------------------+
void PrintDebug(string message)
{
   if(EnableDebugLog)
   {
      Print("[DEBUG] ", message);
   }
}
