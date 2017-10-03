nciphr
=====

Command-line RSA encryption tool

Build
-----

    $ make
    $ make tests
    $ cp ./_build/default/bin/nciphr ~/bin/.

Usage
-----

    $ nciphr encrypt ~/id_rsa.pub msg.txt       > encrypted.txt
    $ nciphr decrypt ~/id_rsa     encrypted.txt > decrypted.txt
