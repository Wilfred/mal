// -*- firestarter: (compile "clang -Wall -Wextra -g -lpcre multi.c -o multi") -*-

#include <stdio.h>
#include <string.h>
#include "pcre.h"

void print_matches(char *str) {
    const char *error;
    int erroffset;
    // TODO: what's the right size here? Using 4 segfaults.
    int ovector[10];

    char *pattern =
        "[\\s,]*(~@|[\\[\\]{}()'`~^@]|\"(?:\\\\.|[^\\\\\"])*\"|;.*|[^"
        "\\s\\[\\]{}('\"`,;)]*)";

    pcre *re = pcre_compile(pattern,    /* the pattern */
                            0, &error,  /* for error message */
                            &erroffset, /* for error offset */
                            0);         /* use default character tables */
    if (!re) {
        puts("pcre_compile failed");
        return;
    }

    unsigned int offset = 0;
    unsigned int len = strlen(str);
    while (offset < len &&
           pcre_exec(re, 0, str, len, offset, 0, ovector, sizeof(ovector)) >=
               0) {
        // ovector has the form:
        // [match_start, match_end, group_start, group_end]
        // There is only one group, and we're interested in it.
        int matchlen = ovector[3] - ovector[2];
        char *match_start_addr = str + ovector[2];
        printf("'%.*s'\n", matchlen, match_start_addr);

        offset = ovector[1];
    }
}

int main() {
    char *sample = "  foo bar fo ( + 1 ( * 2 3 ) ) \"foo\" \"barJ\" \"\" baz";
    puts(sample);
    print_matches(sample);
    return 0;
}
