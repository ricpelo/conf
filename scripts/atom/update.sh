#!/bin/sh

apm list --installed --bare | cut -d"@" -f1 > atom-packages.txt
