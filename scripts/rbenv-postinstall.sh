#!/bin/sh

sudo apt install build-essential libreadline-dev libssl-dev

VER=$(rbenv install -l | cut -c3- | grep "^[0-9.]*$" | sort -r | head -1)

rbenv install $VER
rbenv global $VER
rbenv shell $VER
rbenv rehash
