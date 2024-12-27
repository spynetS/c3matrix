##
# Project Title
#
# @file
# @version 0.1

CC = c3c
FILES = ./printer.c3 ./main.c3

all:
	$(CC) compile $(FILES)

run: all
	./c3matrix

val: all
	valgrind ./c3matrix
# end
