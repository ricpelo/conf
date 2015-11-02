#!/bin/sh

sudo apt-get install build-essential cmake python python-dev

cd YouCompleteMe
./install.py --clang-completer --omnisharp-completer --gocode-completer
cd ..

