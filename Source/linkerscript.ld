_KernelStackSize = 0x200;
_TaskStackSpace = 0x0200;

MEMORY
{
    SRAM1 (rwx) : ORIGIN = 0x20000000, LENGTH = 0x1C000
    SRAM2 (rwx) : ORIGIN = 0x2001C000, LENGTH = 0x4000
	CCMRAM (rw) : ORIGIN = 0x10000000, LENGTH = 0x10000
    
    VECTORTABLE (rx) : ORIGIN = 0x08000000, LENGTH = 0x188
    FLASH (rx)    : ORIGIN = 0x08000200, LENGTH = 64K
}

SECTIONS
{
	.vector_table :
	{
		. = ALIGN(4);
		KEEP(*(.vector_table))
		KEEP(*(.processor_exceptions))
		. = ALIGN(4);
	} > VECTORTABLE
	
	.text :
	{
		. = ALIGN(4);
		KEEP(*(.text))
		. = ALIGN(4);
	} > FLASH
	
	.stack :
	{
		. = ALIGN(4);
		_kernelStackBottom = .;
		. = . + _KernelStackSize;
		_kernelStackTop = .;
		_taskStackBottom = .;
		. = . + _TaskStackSpace;
		_taskStackTop = .;
		
	} > CCMRAM
	
	.data : {
		_DataStart = .;
		*(.data);
		. = ALIGN(4);
		_DataEnd = .;
	} >SRAM1 AT >FLASH
	
	_DataLoad = LOADADDR(.data);
	
	.bss (NOLOAD) : {
		_BssStart = .;
		*(.bss);
		. = ALIGN(4);
		_BssEnd = .;
	} >SRAM1
}