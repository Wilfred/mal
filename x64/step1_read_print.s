        .global main

        .text
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
        ## g_array_new(false, false, sizeof(char*))
        mov     $0, %rdi
        mov     $0, %rsi
        mov     $8, %rdx
        call    g_array_new

        ## we need a pointer to the string we want to push.
        ## g_array_append_vals(arr, &str, 1);
        sub     $8, %rsp
        mov     %rax, %rdi
        movq    $.message, (%rsp) # arbitrary string
        lea     (%rsp), %rsi      # address of $.message
        mov     $1, %rdx
        call    g_array_append_vals
        add     $8, %rsp

        ## printf(lenmessage, arr->new);
        mov     $.lenmessage, %rdi
        mov     8(%rax), %rsi
        mov     $0, %rax
        call    printf

        ret
        
READ:
        mov     %rdi, %rax
        ret
EVAL:
        mov     %rdi, %rax
        ret
PRINT:
        mov     %rdi, %rax
        ret

rep:
        ## rep(str): return PRINT(EVAL(READ(str),""))
        call    READ

        mov     %rax, %rdi
        mov     $.emptystr, %rsi
        call    EVAL

        mov     %rax, %rdi
        call    PRINT
        ret

main:
.readloop:
        ## call readline(message);
        mov     $.message, %rdi
        call    readline

        ## on EOF (e.g. pressing Ctrl-D), readline returns NULL.
        ## Terminate when that happens.
        cmpq    $0, %rax
        je      .end

        ## save a copy of the string from readline in a callee-saved
        ## register.
        mov     %rax, %rbx

        ## rep(user_input_line)
        mov     %rax, %rdi
        call rep

        ## println(rep(user_input_line))
        mov     %rax, %rdi
        call    puts

        ## We need to clean up the string allocated by readline.
        mov     %rbx, %rdi
        call    free

        call    lex

        call    make_array

        jmp     .readloop

.end:
        mov     $.emptystr, %rdi
        call    puts
        ret
.message:
        .asciz "user> "            # asciz puts a 0 byte at the end
.emptystr:
        .asciz ""
.token_pattern:
        .asciz 	"[\\s,]*(~@|[\\[\\]{}()'`~^@]|\"(?:\\\\.|[^\\\\\"])*\"|;.*|[^\\s\\[\\]{}('\"`,;)]*)"
.lenmessage:
        .asciz "array length: %d\n"
