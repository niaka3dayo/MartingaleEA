# MartingaleEA - FX自動売買EA

## 概要
MartingaleEAは、移動平均線のクロスオーバーを利用したシンプルなマーチンゲール戦略のMT4用自動売買EAです。

## 特徴
- 移動平均線クロスオーバーによるエントリーシグナル
- マーチンゲール戦略によるロットサイズ管理
- カスタマイズ可能なパラメーター設定
- 詳細なログ出力機能

## プロジェクト構造
```
SampleEA/
├── FX_EA_Project/         # EAプロジェクトのメインディレクトリ
│   ├── MQL4/              # MT4用のMQLコード
│   │   ├── Experts/       # EAファイル
│   │   ├── Include/       # インクルードファイル
│   │   ├── Libraries/     # ライブラリファイル
│   │   └── Scripts/       # スクリプトファイル
│   └── README.md          # プロジェクト説明
├── scripts/               # 管理用PowerShellスクリプト
│   ├── compile_ea.ps1     # EAコンパイルスクリプト
│   ├── install_to_mt4.ps1 # MT4インストールスクリプト
│   └── setup_project.ps1  # プロジェクトセットアップスクリプト
├── docs/                  # ドキュメントディレクトリ
│   ├── project_rules.md   # プロジェクト開発ルール
│   ├── pr_description.md  # PR説明テンプレート
│   └── 使い方.md          # 日本語使用方法ガイド
├── src/                   # EAソースコードディレクトリ
│   ├── MartingaleEA.mq4   # マーチンゲールEAのソースコード
│   ├── RSI_BB_EA.mq4      # RSI+ボリンジャーバンドEAのソースコード
│   └── SimpleMAcrossEA.mq4 # 単純移動平均線クロスEAのソースコード
├── compile_ea.ps1         # コンパイルスクリプトショートカット
├── install_to_mt4.ps1     # インストールスクリプトショートカット
└── setup_project.ps1      # セットアップスクリプトショートカット
```

## パラメーター設定

### トレード設定
- **InitialLotSize**: 初期ロットサイズ（デフォルト: 0.01）
- **MaxLotSize**: 最大ロットサイズ（デフォルト: 10.0）
- **LotMultiplier**: 損失時のロット倍率（デフォルト: 2.0）
- **StopLoss**: ストップロス（ポイント）（デフォルト: 50）
- **TakeProfit**: 利益確定（ポイント）（デフォルト: 20）
- **Slippage**: スリッページ（ポイント）（デフォルト: 3）

### シグナル設定
- **FastMA**: 短期移動平均線の期間（デフォルト: 5）
- **SlowMA**: 長期移動平均線の期間（デフォルト: 20）
- **MAMethod**: 移動平均線の計算方法（デフォルト: MODE_SMA）
- **AppliedPrice**: 適用価格（デフォルト: PRICE_CLOSE）

### その他の設定
- **MagicNumber**: マジックナンバー（EA識別用）（デフォルト: 98765）
- **EnableDebugLog**: デバッグログを有効にする（デフォルト: false）

## 使用方法

### セットアップ
1. PowerShellを管理者権限で実行
2. プロジェクトのルートディレクトリで以下のコマンドを実行:
   ```
   .\setup_project.ps1
   ```

### コンパイル
1. PowerShellを管理者権限で実行
2. プロジェクトのルートディレクトリで以下のコマンドを実行:
   ```
   .\compile_ea.ps1
   ```
3. MetaEditorが自動検出されない場合は、正確なパスを入力

### MT4へのインストール
1. PowerShellを管理者権限で実行
2. プロジェクトのルートディレクトリで以下のコマンドを実行:
   ```
   .\install_to_mt4.ps1
   ```
3. MT4のデータディレクトリが複数ある場合は、使用するディレクトリを選択

### MT4での使用
1. MT4を起動
2. ナビゲーターウィンドウを開く
3. Expert Advisorsセクションで目的のEAを見つける
4. チャート上にEAをドラッグ＆ドロップ
5. パラメーターを必要に応じて調整
6. 「OK」をクリックして開始

## 注意事項
- マーチンゲール戦略は、連続した損失が発生した場合に大きなリスクを伴います
- デモ口座でテストしてから実口座で使用することを強く推奨します
- リスク管理を適切に行い、資金管理に十分注意してください

## ドキュメント
詳細なドキュメントは以下のファイルを参照してください：
- [プロジェクト開発ルール](docs/project_rules.md)
- [使い方（日本語）](docs/使い方.md)

## ライセンス
このプロジェクトはオープンソースとして公開されています。

## 開発者
FX自動売買EAプロジェクト
