CC=gcc
CFLAGS=-Wall -Wextra -g -lreadline -lpcre -lglib-2.0


SOURCES = $(wildcard *.s)
TARGETS = $(SOURCES:.s=)

all: $(TARGETS)

%: %.s
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(TARGETS)
