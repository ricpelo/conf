#!/bin/sh

apt-clone clone hydra
dpkg --get-selections | gzip -9 > dpkg--get-selections.txt.gz
