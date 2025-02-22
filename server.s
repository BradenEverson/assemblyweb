    # Extremely simple web server in assembly!

    .global _start

    .text
_start:
    mov     $0, %rdx 
    dec     %rdx
    push    %rdx

    # socket(2, 1, 0)
    mov     $41, %rax             # system call 41 is socket
    mov     $2, %rdi                # AF_INET is 2
    mov     $1, %rsi                # SOCK_STREAM is 1
    mov     $0, %rdx                # Options set to 0
    syscall

    pop     %rdx
    cmp     %rax, %rdx              # Check if rax is negative
    push    %rdx
    je      error_handle            # jump to error handler if things go south

    mov     %rax, %rbx              # Put FD in rbx for safe keeping

    # bind(rbx, sock_addr pointer?, len)
    mov     $49, %rax               # system call 49 is bind
    mov     %rbx, %rdi
    lea     addr(%rip), %rsi        # Pointer to sockaddr_in struct
    mov     $16, %rdx               # sizeof(struct sockaddr_in)
    syscall 

    pop     %rdx
    cmp     %rax, %rdx              # Check if rax is negative
    push    %rdx
    je      error_handle            # jump to error handler if things go south

    # listen (rbx, 4096)
    mov     $50, %rax               # system call 50 is listen
    mov     %rbx, %rdi              # socket fd 
    mov     $4096, %rsi             # max connections
    syscall

    pop     %rdx
    cmp     %rax, %rdx              # Check if rax is negative
    push    %rdx
    je      error_handle            # jump to error handler if things go south

loop:
    # accept(rbx, sock_addr pointer, socklen_t *)
    mov $43, %rax                   # syscall 43 is accept
    lea client_addr(%rip), %rsi     # Pointer to sockaddr_in (client address)
    lea addr_len(%rip), %rdx        # Pointer to socklen_t (size of sockaddr)
    syscall

    pop     %rdx
    cmp     %rax, %rdx              # Check if rax is negative
    push    %rdx
    je      error_handle            # jump to error handler if things go south

    mov     %rax, %rcx              # Put new FD in rcx for safe keeping

    # write(rcx, response, 89)
    mov     $1, %rax                # syscall 1 is write
    mov     %rcx, %rdi              # load new FD
    lea     response(%rip), %rsi    # response text
    mov     $89, %rdx               # response length
    syscall

    pop     %rdx
    cmp     %rax, %rdx              # Check if rax is negative
    push    %rdx
    je      error_handle            # jump to error handler if things go south

    # close(rcx)
    mov     $3, %rax                # system call 3 is close
    mov     %rcx, %rdi              # Fd is stored in rcx
    syscall

    # Infinite loop to keep accepting connections
    jmp     loop

error_handle:
    # write(1, message, 13)
    mov     $1, %rax                # system call 1 is write
    mov     $1, %rdi                # file handle 1 is stdout
    lea     bad(%rip), %rsi         # address of string to output
    mov     $45, %rdx
    syscall

    # exit(0)
    mov     $60, %rax               # system call 60 is exit
    xor     %rdi, %rdi              # return code 0
    syscall

    .section .bss
    .lcomm client_addr, 16 
    .lcomm addr_len, 4

    .section .data
addr:
    .short 2
    .short 0xC61E
    .long 0x0100007F
    .zero 8

    .section .rodata
response:
    .ascii "HTTP/1.0 200 OK\r\nServer: server\r\n Content-type: text/html\r\n\r\n<html>Hello from ASM!</html>" # 97 bytes btw
bad:
    .ascii "So sorry something quite awful has happened\n" # 45 bytes btw
