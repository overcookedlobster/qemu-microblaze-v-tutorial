MEMORY {
    BRAM : ORIGIN = 0x00000000, LENGTH = 128K
    DDR  : ORIGIN = 0x80000000, LENGTH = 0x80000000
}

SECTIONS {
    .text : {
        *(.text)
        *(.text.*)
    } > BRAM
    
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    } > BRAM
    
    .data : {
        *(.data)
        *(.data.*)
    } > BRAM
    
    .bss : {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    } > BRAM
    
    /* Stack grows down from end of BRAM */
    _stack_top = ORIGIN(BRAM) + LENGTH(BRAM);
}