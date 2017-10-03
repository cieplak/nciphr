#!/usr/bin/env bash

./_build/default/bin/nciphr encrypt test/keys/rsa_key.pub test/plaintext/erlang07-wiger.pdf > test/encrypted.pdf
./_build/default/bin/nciphr decrypt test/keys/rsa_key test/encrypted.pdf > test/decrypted.pdf

./_build/default/bin/nciphr encrypt test/keys/rsa_key_protected.pub test/plaintext/msg.txt > test/encrypted.txt
