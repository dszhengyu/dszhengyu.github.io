#!/bin/bash

cp ~/make_tag.sh ~/dszhengyu.github.io/unix_config_backup/
cp ~/.vimrc ~/dszhengyu.github.io/unix_config_backup/
cp ~/config_backup.sh ~/dszhengyu.github.io/unix_config_backup/

cd ~/dszhengyu.github.io && git add . && git commit -m "add unix config backup"
