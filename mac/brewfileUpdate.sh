#!/bin/bash

set -e

BREWFILE_PATH="./Brewfile"
BACKUP_PATH="./Brewfile.backup"

# 1. 現在のBrewfileをバックアップ
if [ -f "$BREWFILE_PATH" ]; then
  echo "バックアップを作成中: $BACKUP_PATH"
  cp "$BREWFILE_PATH" "$BACKUP_PATH"
else
  echo "Brewfileが存在しません。新規作成を行います。"
fi

# 2. 新しいBrewfileを生成
echo "Brewfileを再生成中..."
brew bundle dump --file="$BREWFILE_PATH" --force

# 3. 差分を確認
if [ -f "$BACKUP_PATH" ]; then
  echo "バックアップとの差分:"
  diff "$BACKUP_PATH" "$BREWFILE_PATH" || true
else
  echo "新しいBrewfileが作成されました。"
fi

echo "完了しました！"