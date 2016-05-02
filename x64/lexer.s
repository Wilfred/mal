## Return a stack-allocated pcre struct that matches mal lexemes.
compile_lex_pattern:
        ## we use these registers, so store their old values.
        push    %r12
        push    %r13
        push    %r14
        
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

        call    pcre_compile
        mov     %rax, %r14

        ##  sanity check
        cmpq    $0, %rax
        je      .bad_pattern

        ## free the pointers we allocated
        mov     %r12, %rdi
        call    free

        mov     %r13, %rdi
        call    free

        mov     %r14, %rax

        ## restore old r12 and r13
        pop     %r14
        pop     %r13
        pop     %r12

        ret
.bad_pattern:
        mov     $.bad_pattern_message, %rdi
        call    puts
        ud2                      # boom!

## Print the length of the string passed in by the user.
lex:
        push    %r12
        push    %r13
        push    %r14

        ## %r12 = user_string
        mov     %rax, %r12

        ## %r14 len = strlen(user_string)
        mov     %rax, %rdi
        call    strlen
        mov     %rax, %r14

        ## i = 0
        mov     $0, %r13
.lex_loop:
        ## i == len
        cmp     %r13, %r14
        je      .lex_loop_end

        mov     $.countmessage, %rdi
        mov     %r13, %rsi
        mov     $0, %rax
        call    printf
        add     $1, %r13
        jmp     .lex_loop
        
.lex_loop_end:
        call    compile_lex_pattern

        mov     %rax, %rdi
        ## pcre_free has type
        ## void (*pcre_free)(void *);
        ## so we need to dereference it when calling.
        call    *pcre_free

        pop     %r14
        pop     %r13
        pop     %r12

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

        ## g_ptr_array_add(arr, str);
        mov     %r12, %rdi
        movq    $.message, %rsi # arbitrary string
        call    g_ptr_array_add

        ## g_ptr_array_add(arr, str);
        mov     %r12, %rdi
        movq    $.message, %rsi # arbitrary string
        call    g_ptr_array_add

        ## g_ptr_array_add(arr, str);
        mov     %r12, %rdi
        movq    $.message, %rsi # arbitrary string
        call    g_ptr_array_add

        mov %r12, %rdi
        call print_str_array

        mov     %r12, %rdi
        mov     $1, %rsi
        call    g_ptr_array_free

        ret

## Given a GPtrArray of strings, print each item.
print_str_array:
        push %r12
        push %r13

        ## %r12 = array
        mov %rdi, %r12
        ## %r13 i = 0
        mov $0, %r13
.print_loop:
        ## i == array->len
        cmp %r13, 8(%r12)
        je .print_loop_end

        mov $.print_loop_message, %rdi
        mov %r13, %rsi
        mov $0, %rax
        call printf

        add $1, %r13
        jmp .print_loop
        
.print_loop_end:

        pop %r13
        pop %r12
        
        ret

.bad_pattern_message:
        .asciz "pcre_compile failed!"
.token_pattern:
        .asciz 	"[\\s,]*(~@|[\\[\\]{}()'`~^@]|\"(?:\\\\.|[^\\\\\"])*\"|;.*|[^\\s\\[\\]{}('\"`,;)]*)"
.lenmessage:
        .asciz "array length: %d\n"
.countmessage: .asciz "i: %d\n"
.print_loop_message: .asciz "%d: todo\n"
