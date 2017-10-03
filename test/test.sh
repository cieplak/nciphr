#!/usr/bin/env bash
set -e

./_build/default/bin/nciphr encrypt test/keys/rsa_key.pub test/plaintext/erlang07-wiger.pdf > test/encrypted.pdf
./_build/default/bin/nciphr decrypt test/keys/rsa_key test/encrypted.pdf > test/decrypted.pdf

./_build/default/bin/nciphr encrypt test/keys/rsa_key.pub test/plaintext/msg.txt > test/encrypted.txt
./_build/default/bin/nciphr decrypt test/keys/rsa_key test/encrypted.txt > test/decrypted.txt

md5sum test/plaintext/erlang07-wiger.pdf
md5sum test/decrypted.pdf

md5sum test/plaintext/msg.txt
md5sum test/decrypted.txt
