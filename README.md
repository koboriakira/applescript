# AppleScript Utilities

macOS向けの便利なAppleScriptユーティリティコレクションです。

## 📁 含まれるスクリプト

- **`convert_downloads_heic_to_jpeg.applescript`** - DownloadsフォルダのHEICファイルをJPEGに変換
- **`heic_to_jpeg_converter.applescript`** - 汎用的なHEIC→JPEG変換ツール

## 🚀 クイックスタート

### 1. シェル関数の設定（推奨）
```bash
# リポジトリをクローン
git clone <repository-url>
cd applescript

# 自動セットアップを実行
./setup.sh
```

### 2. 手動での実行
```bash
# AppleScriptを直接実行
osascript convert_downloads_heic_to_jpeg.applescript

# 構文チェック
osacompile -c convert_downloads_heic_to_jpeg.applescript
```

## 🛠️ 利用可能なシェル関数

セットアップ後、以下の便利な関数が使用できます：

| 関数名 | 説明 | 使用例 |
|--------|------|--------|
| `run_applescript` | AppleScriptを実行 | `run_applescript script.applescript` |
| `check_applescript` | 構文チェック | `check_applescript script.applescript` |
| `applescript_to_app` | アプリ化 | `applescript_to_app script.applescript "My App"` |
| `convert_heic` | HEIC変換実行 | `convert_heic` |
| `list_applescripts` | スクリプト一覧表示 | `list_applescripts` |
| `backup_applescript` | バックアップ作成 | `backup_applescript script.applescript` |
| `applescript_info` | ファイル情報表示 | `applescript_info script.applescript` |
| `applescript_help` | ヘルプ表示 | `applescript_help` |

## 📋 使用例

### HEIC → JPEG 変換
```bash
# シェル関数を使用（最も簡単）
convert_heic

# または直接実行
run_applescript convert_downloads_heic_to_jpeg.applescript

# アプリ化してデスクトップに配置
applescript_to_app convert_downloads_heic_to_jpeg.applescript "HEIC Converter"
```

### スクリプトの管理
```bash
# 現在のディレクトリのAppleScriptファイルを一覧表示
list_applescripts

# 構文チェック
check_applescript convert_downloads_heic_to_jpeg.applescript

# バックアップを作成してから編集
backup_applescript convert_downloads_heic_to_jpeg.applescript

# ファイル情報を確認
applescript_info convert_downloads_heic_to_jpeg.applescript
```

## 🎯 HEIC to JPEG Converter の詳細

### 機能
- ✅ Downloadsフォルダ内のHEICファイルを自動検索
- ✅ 一括変換（JPEG形式）
- ✅ 変換後に元ファイルを自動削除
- ✅ ドラッグ&ドロップ対応
- ✅ エラーハンドリング
- ✅ 確認ダイアログ

### 使用方法
1. **自動実行**: スクリプトを実行してDownloadsフォルダを処理
2. **ドラッグ&ドロップ**: HEICファイルをスクリプト（またはアプリ）にドロップ
3. **アプリ化**: `applescript_to_app`でアプリ化してより便利に使用

## 🔧 カスタマイズ

### 対象フォルダの変更
スクリプト内の以下の部分を編集：
```applescript
set downloadsPath to (path to downloads folder) as string
```

### 出力形式の変更
`sips`コマンドの形式指定を変更：
```applescript
set shellCommand to "sips -s format jpeg '" & filePath & "' --out '" & outputPath & "'"
```

## 📝 トラブルシューティング

### よくある問題

**Q: "実行権限がありません"エラー**  
A: `chmod +x setup.sh`でセットアップスクリプトに実行権限を付与

**Q: 関数が見つからない**  
A: シェルを再起動するか`source ~/.zshrc`（または`~/.bash_profile`）を実行

**Q: HEIC変換が失敗する**  
A: macOSの`sips`コマンドが利用可能か確認（通常は標準でインストール済み）

### ログの確認
```bash
# AppleScriptの詳細ログを有効化
osascript -l AppleScript -e 'log "test"' 2>&1
```

## 🤝 貢献

プルリクエストやイシューの報告を歓迎します。

## 📄 ライセンス

MIT License - 自由に使用・改変してください。
