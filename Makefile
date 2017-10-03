default: cli

cli:
	rebar3 escriptize

tests:
	./test/test.sh

clean:
	rm test/encr*
	rm test/decr*
