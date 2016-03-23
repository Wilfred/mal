        .global main

        .text
main:
readloop:
	## call readline(message);
        mov     $message, %rdi
        call    readline

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
