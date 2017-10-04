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

    $ echo secret   | nciphr encrypt ~/id_rsa.pub - > encrypted
    $ cat encrypted | nciphr decrypt ~/id_rsa     - > decrypted.txt
