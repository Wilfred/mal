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
        mov     $emptystr, %rsi
        call    EVAL

        mov     %rax, %rdi
        call    PRINT

main:
        push    %rbp
        mov     %rsp, %rbp
readloop:
        ## call readline(message);
        mov     $message, %rdi
        call    readline

        mov     %rax, %rdi
        call    READ

        ## on EOF (e.g. pressing Ctrl-D), readline returns NULL.
        ## Terminate when that happens.
        cmpq    $0, %rax
        je      end
        
        ## We need to clean up the string allocated by readline.
        mov     %rax, %rdi
        call    free

        jmp     readloop

end:
        mov     $emptystr, %rdi
        call    puts
        ret
message:
        .asciz "user> "            # asciz puts a 0 byte at the end
emptystr:
        .asciz ""
