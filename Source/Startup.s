.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.include "stm32f407.inc"

.section .text
.type Reset_Handler,%function
.globl Reset_Handler
Reset_Handler:
/* fill in data memory */
	ldr r0, =_DataStart
	ldr r1, =_DataEnd
	ldr r2, =_DataLoad
	
	b 2f
1:	ldr r3, [r2], #4
	str r3, [r0], #4
2:	cmp r0, r1
	blo 1b

/* zero bss */
	ldr r0, =_BssStart
	ldr r1, =_BssEnd
	ldr r2, =0

	b 2f
1:	str r2, [r0], #4
2:	cmp r0, r1
	blo 1b
	
/*configure systick 1 ms period*/
	ldr r0, =#16000000
	mov r1, #1
	bl InitialiseSysTick
/* enable clock for GPIOD */
	ldr r0, =RCC
	ldr r1, =RCC_AHB1ENR
	ldr r2, [r0, r1]
	orr r2, 0x08
	str r2, [r0, r1]
	dsb
/* configure pin as out - PD15 - blue led */
	ldr r0, =GPIOD
	ldr r1, =GPIO_MODER
	mov r2, 0x01
	lsl r2, 30
	str r2, [r0, r1]
	ldr r1, =GPIO_BSRR
	mov r2, 0x01
	lsl r2, 15
	mov r3, r0
	mov r4, #0 /* r4 is tick count at last toggle */
	mov r5, #1000 /* r5 is flash period in ticks */
	add r6, r4, r5 /* r6 is next toggle count */
flashloop:
	bl GetSysTickCount
	cmp r0, r6
	blt flashloop
	mov r6, r0
	add r6, r5
	str r2, [r3, r1]
	ror r2, 16
	b flashloop
	
	
	
	
	b Reset_Handler
	