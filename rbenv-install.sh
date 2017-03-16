#!/bin/sh

git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' > ~/.oh-my-zsh/custom/rbenv.zsh
echo 'eval "$(rbenv init -)"' >> ~/.oh-my-zsh/custom/rbenv.zsh

echo "Sal del terminal, vuelve a entrar y ejecuta 'rbenv-postinstall.sh'."

