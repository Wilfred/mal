        .global main

        .text
main:
        mov     $message, %rdi
        call    puts
        ret
message:
        .asciz "user> "            # asciz puts a 0 byte at the end
