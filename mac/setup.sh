#!/bin/zsh

set -e # エラーが発生した場合にスクリプトを終了

echo "===== Gitのインストール ====="
if ! command -v git &> /dev/null; then
  echo "Gitをインストール中..."
  xcode-select --install
else
  echo "Gitはすでにインストールされています"
fi

echo "===== Homebrewのインストール ====="
if ! command -v brew &> /dev/null; then
  echo "Homebrewをインストール中..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrewはすでにインストールされています"
fi

echo "===== Rosetta 2のインストール ====="
if /usr/bin/pgrep oahd &> /dev/null; then
  echo "Rosetta 2はすでにインストールされています"
else
  echo "Rosetta 2をインストール中..."
  sudo softwareupdate --install-rosetta --agree-to-license
fi

echo "===== Oh My Zshのインストール ====="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zshをインストール中..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zshはすでにインストールされています"
fi

echo "===== Voltaのセットアップ ====="
if ! command -v volta &> /dev/null; then
  echo "Voltaをインストール中..."
  curl https://get.volta.sh | bash
  echo 'export VOLTA_HOME="$HOME/.volta"' >> ~/.zshrc
  echo 'export PATH="$VOLTA_HOME/bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
else
  echo "Voltaはすでにインストールされています"
fi

echo "===== ターミナル補完拡張のインストール ====="
PLUGIN_DIR="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

if [ ! -d "$PLUGIN_DIR" ]; then
  echo "zsh-autosuggestionsをインストール中..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR"
  sed -i '' '/^plugins=/s/)/ zsh-autosuggestions)/' ~/.zshrc
  source ~/.zshrc
else
  echo "zsh-autosuggestionsはすでにインストールされています。更新を確認中..."
  CURRENT_DIR=$(pwd)
  cd "$PLUGIN_DIR"
  git pull
  cd "$CURRENT_DIR"
fi

echo "===== aws_session_managerのインストール ====="
echo "Session Manager Pluginをダウンロード中..."
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"

if [ $? -ne 0 ]; then
    echo "Failed to download sessionmanager-bundle.zip"
    exit 1
fi

# ZIPファイルの解凍
echo "ZIPファイルの解凍中..."
unzip sessionmanager-bundle.zip

if [ $? -ne 0 ]; then
    echo "Failed to unzip sessionmanager-bundle.zip"
    exit 1
fi

# Session Manager Pluginのインストール
echo "インストール中..."
sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin

if [ $? -ne 0 ]; then
    echo "Failed to install Session Manager Plugin"
    exit 1
fi

# インストール確認
echo "インストール確認中..."
session-manager-plugin

if [ $? -eq 0 ]; then
    echo "インストールが成功しました!"
    # 不要なファイルを削除
    echo "Cleaning up..."
    rm -f sessionmanager-bundle.zip
    rm -rf sessionmanager-bundle
    echo "Cleanup completed."
else
    echo "インストールに失敗しています"
    exit 1
fi


echo "===== Brewfileを使用したパッケージのインストール ====="
if [ -f ./Brewfile ]; then
  echo "Brewfileを使用してインストールを開始..."
  brew bundle --file=Brewfile
else
  echo "Brewfileが見つかりません。スクリプトを終了します。"
  pwd
  exit 1
fi
echo "=====libpq postgreSQL のクライアントツール　のパスを通すコマンド ====="
grep -qxF 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' ~/.zshrc || echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> ~/.zshrc

echo "===== aws cliの設定 ====="
aws configure set region ap-northeast-1
aws configure set output json

echo "===== キーボード入力速度の設定 ====="
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 15


echo "===== gitingestのinstall ====="
pipx install gitingest
pipx ensurepath
source ~/.zshrc


echo "===== セットアップが完了しました！ ====="[]