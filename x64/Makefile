CC=gcc
CFLAGS=-Wall -Wextra -g -lreadline -lpcre -lglib-2.0


SOURCES = $(wildcard step*.s)
TARGETS = $(SOURCES:.s=)

all: $(TARGETS)

%: %.s lexer.s
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(TARGETS)
