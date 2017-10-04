#!/usr/bin/env bash
set -e
set -x

alias nciphr="./_build/default/bin/nciphr"

cat test/plaintext/msg.txt            | nciphr encrypt test/keys/rsa_key.pub - | nciphr decrypt test/keys/rsa_key - > test/decrypted.txt
cat test/plaintext/erlang07-wiger.pdf | nciphr encrypt test/keys/rsa_key.pub - | nciphr decrypt test/keys/rsa_key - > test/decrypted.pdf

md5sum test/plaintext/erlang07-wiger.pdf
md5sum test/decrypted.pdf

md5sum test/plaintext/msg.txt
md5sum test/decrypted.txt
