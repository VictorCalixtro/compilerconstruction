CC = gcc
CFLAGS = -I./src -std=gnu99
LEX=lex

obj/scanner: obj/lex.yy.o obj/driver.o
	gcc $(CFLAGS) -o $@ $^ -ll

obj/lex.yy.o: obj/lex.yy.c
	gcc $(CFLAGS) -c $< -o $@

obj/lex.yy.c: src/scanner.l
	@mkdir -p obj
	lex -o $@ $<

obj/driver.o: src/driver.c
	@mkdir -p obj
	$(CC)  $(CFLAGS) -c $< -o $@

.PHONY: clean test

clean:
	rm -rf obj
	rm -f lex.yy.* *.o *~ scanner

test: obj/scanner
	@python ./test/testScanner.py
