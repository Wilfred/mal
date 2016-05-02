.include "lexer.s"
        
        .global main

        .text
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

        ## lex(user_input_line)
        mov     %rax, %rdi
        call    lex

        ## rep(user_input_line)
        mov     %rbx, %rdi
        call rep

        ## println(rep(user_input_line))
        mov     %rax, %rdi
        call    puts

        ## We need to clean up the string allocated by readline.
        mov     %rbx, %rdi
        call    free

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
.lenmessage:
        .asciz "array length: %d\n"
