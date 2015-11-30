#!/bin/sh

sudo apt-get install build-essential libreadline-dev
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' > ~/.oh-my-zsh/custom/rbenv.zsh
echo 'eval "$(rbenv init -)"' >> ~/.oh-my-zsh/custom/rbenv.zsh


