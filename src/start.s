.section .text
.global _start

_start:
    # Set up stack pointer
    la sp, _stack_top
    
    # Jump to main C function
    call main
    
    # If main returns, infinite loop
1:  j 1b

.section .bss
.align 4
stack:
    .space 4096
_stack_top: