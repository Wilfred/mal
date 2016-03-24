CC=gcc
CFLAGS=-Wall -Wextra -g -lreadline -lpcre


SOURCES = $(wildcard *.s)
TARGETS = $(SOURCES:.s=)

all: $(TARGETS)

%: %.s
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(TARGETS)
