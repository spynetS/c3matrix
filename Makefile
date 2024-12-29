##
# Project Title
#
# @file
# @version 0.1

OUT_DIR = ./out
EXEC = $(OUT_DIR)/c3matrix

CC = c3c
CFLAGS = -L $(OUT_DIR) -l keypress
FILES = ./printer.c3 ./main.c3


all: keypress $(FILES)
	$(CC) $(CFLAGS) compile $(FILES) -o $(EXEC)

$(OUT_DIR):
	mkdir $(OUT_DIR)

keypress: $(OUT_DIR)
	gcc -c keypress.c -o $(OUT_DIR)/keypress.o
	ar rcs $(OUT_DIR)/libkeypress.a $(OUT_DIR)/keypress.o

run: all
	$(EXEC)

val: all
	valgrind $(EXEC)

clean:
	rm -rf $(OUT_DIR)
# end
