## Return a stack-allocated pcre struct that matches mal lexemes.
compile_lex_pattern:
        mov     $.dummy, %rdi
        call    puts
        
        ## allocate a pointer for pcre_compile to write its error
        ## messages to.
        mov     $8, %rdi
        call    malloc
        mov     %rax, %r12      # r12 is callee saved.

        ## allocate another pointer for the erroffset.
        mov     $8, %rdi
        call    malloc
        mov     %rax, %r13

        ## pcre_compile(pattern, 0, &error, &erroffset, NULL)
        mov     $.token_pattern, %rdi
        mov     $0, %rsi
        mov     %r12, %rdx
        mov     %r13, %rcx
        mov     $0, %r8

        cmpq    $0, %rax
        je      .bad_pattern
        
        call    pcre_compile
        ret
.bad_pattern:
        mov     $.bad_pattern_message, %rdi
        call    puts
        ud2                      # boom!
        
lex:
        call    compile_lex_pattern

        mov     %rax, %r14

        mov     %r12, %rdi
        call    free

        mov     %r13, %rdi
        call    free

        mov     %r14, %rdi
        ## pcre_free has type
        ## void (*pcre_free)(void *);
        ## so we need to dereference it when calling.
        call    *pcre_free

        ret

make_array:
        call    g_ptr_array_new
        mov     %rax, %r12

        ## g_ptr_array_add(arr, str);
        mov     %rax, %rdi
        movq    $.message, %rsi # arbitrary string
        call    g_ptr_array_add

        ## g_ptr_array_add(arr, str);
        mov     %r12, %rdi
        movq    $.message, %rsi # arbitrary string
        call    g_ptr_array_add

        ## printf(lenmessage, arr->len);
        mov     $.lenmessage, %rdi
        mov     8(%r12), %rsi
        mov     $0, %rax
        call    printf

        mov     %r12, %rdi
        mov     $1, %rsi
        call    g_ptr_array_free

        ret

.dummy:
        .asciz "in compile_lex_pattern"
.bad_pattern_message:
        .asciz "pcre_compile failed!"
