#!/bin/bash

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
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  echo "zsh-autosuggestionsをインストール中..."
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  sed -i '' '/^plugins=/s/)/ zsh-autosuggestions)/' ~/.zshrc
  source ~/.zshrc
else
  echo "zsh-autosuggestionsはすでにインストールされています"
fi

echo "===== Brewfileを使用したパッケージのインストール ====="
if [ -f ./Brewfile ]; then
  echo "Brewfileを使用してインストールを開始..."
  brew bundle --file=Brewfile
else
  echo "Brewfileが見つかりません。スクリプトを終了します。"
  exit 1
fi

echo "===== セットアップが完了しました！ ====="[]