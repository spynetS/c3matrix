##
# Project Title
#
# @file
# @version 0.1

OUT_DIR = ./build
EXEC_NAME = c3matrix
EXEC = $(OUT_DIR)/$(EXEC_NAME)
DEST_DIR ?= /usr/local/bin

CC = c3c
CFLAGS = -L $(OUT_DIR) -l keypress
FILES = ./main.c3 ./printer.c3


$(EXEC): $(FILES) $(OUT_DIR)/keypress.o
	$(CC) $(CFLAGS) compile $(FILES) -o $(EXEC)

$(OUT_DIR)/keypress.o: keypress.c
	@if [ ! -d "$(OUT_DIR)" ]; then \
		echo "Directory $(OUT_DIR) does not exist, creating..."; \
		mkdir -p $(OUT_DIR); \
	else \
		echo "Directory $(OUT_DIR) already exists."; \
	fi
	gcc -c keypress.c -o $(OUT_DIR)/keypress.o
	ar rcs $(OUT_DIR)/libkeypress.a $(OUT_DIR)/keypress.o

run: $(EXEC)
	$(EXEC)

install: $(EXEC)
	sudo install -s --mode +x $(EXEC) $(DEST_DIR)/$(EXEC_NAME)
	@echo "Installation complete."

uninstall:
	sudo rm -rf $(DEST_DIR)/$(EXEC_NAME)
	@echo "Uninstallation complete."

clean:
	rm -rf $(OUT_DIR)
# end
