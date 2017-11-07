#!/bin/sh

apt-clone clone dagon
dpkg --get-selections | gzip -9 > dpkg--get-selections.txt.gz
