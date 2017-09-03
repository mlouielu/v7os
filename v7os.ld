MEMORY
{
    ROM (rx) : ORIGIN = 0x08000000, LENGTH = 128k
    RAM (rwx): ORIGIN = 0x20000000, LENGTH = 64k
}

ENTRY(reset_handler)

SECTIONS
{
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text*)
        *(.rodata*)
    } >ROM

    __etext = .;
    _sidata = .;

    .data : AT (__etext)
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data*)
        _edata = .;
    } >RAM

    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss*)
        _ebss = .;
    } >RAM

    _estack = ORIGIN(RAM) + LENGTH(RAM);
}
