## セットアップ手順

### 1. リポジトリをクローン
まず、リポジトリをローカルにクローンします：

```bash
git clone <リポジトリのURL>
cd setup/mac
```
### 2. シェルスクリプトに実行権限を付与

```bash
chmod +x setup.sh
```
### 3. 自動セットアップスクリプトの実行

```bash
./setup.sh
```
### 4. 手動でのセットアップ
manual_install.txt を参考にして、手動タスクを完了してください

### 5. appleScriptの設定(chromeを使用している場合)
appleScript/chromeTranslate.mdを参考にして、chromeの翻訳機能のショートカットを設定



## 更新手順
### 1. シェルスクリプトに実行権限を付与
```bash
chmod +x brewFileUpdate.sh
```

### 2. Brewfireの更新
随時、以下コマンドでBrewfileを更新してください。
```bash
./brewFileUpdate.sh
```