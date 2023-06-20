#!/usr/bin/env bash

# エラーがあったらそこで即終了、設定していない変数を使ったらエラーにする
set -eu

# is_arm という関数を用意しておく。毎回 uname -m を実行するのは莫迦らしいので、UNAME 環境変数で判断
is_arm() { test "$UNAME" == "arm64"; }

# アーキテクチャ名は UNAME に入れておく
UNAME=`uname -m`

# dotfiles の場所を設定
DOTPATH=$HOME/dotfiles

# このフォルダの取り扱い
if [ ! -d "$DOTPATH" ]; then
  # 初回実行時はリポジトリがないので、clone してくる
  echo "Cloning dotfiles.git ..."
  git clone https://m22014@bitbucket.org/banana-banao/dot-files2.git "$DOTPATH"
else
  # すでにフォルダがある時はそのことを表示
  echo "$DOTPATH already downloaded."
fi

# ここにある dotfiles をホームに展開 (.git, .DS_Store は除外。他に除外するものが増えたらここに追記)
echo "Deploying dotfiles ..."
for file in .??*; do
    [[ "$file" = ".git" ]] && continue
    [[ "$file" = ".DS_Store" ]] && continue
    ln -fvns "$DOTPATH/$file" "$HOME/$file"
done

cd "$DOTPATH"

# 入っていなければ、コマンドライン・デベロッパツールをインストール
xcode-select -p 1>/dev/null || {
  echo "Installing Command line tools ..."
  xcode-select --install
  # その場合、Apple Silicon Mac では Rosetta2 もインストールされていないと思われるので、こちらもインストール
  if is_arm; then
    # ソフトウェアアップデートで Rosetta2 をインストール。面倒なのでライセンス確認クリックをスキップ
    echo "Installing Rosetta2 ..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  fi
  echo "Please exec ./bootstrap.sh again in $DOTPATH after installing command-line-tools and Rosetta2(Apple Silicon Mac only)."
  exit 1
}

# install homebrew
if ! command -v brew > /dev/null 2>&1; then
  echo "Installing homebrew ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# homebrew, cask and mas
brew bundle -v
