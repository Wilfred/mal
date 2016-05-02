lex:
        ## allocate a pointer for pcre_compile to write its error
        ## messages to.
        mov     $8, %rdi
        call    malloc
        mov     %rax, %r12      # r12 is callee saved.

        ## allocate another pointer for the offset.
        mov     $8, %rdi
        call    malloc
        mov     %rax, %r13

        ## pcre_compile(pattern, 0, &error, &offset, NULL)
        mov     $.token_pattern, %rdi
        mov     $0, %rsi
        mov     %r12, %rdx
        mov     %r13, %rcx
        mov     $0, %r8
        
        call    pcre_compile

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
