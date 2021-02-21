.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.include "stm32f407.inc"
.include "CortexM4.inc"

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
/* configure pin as out - PD15 - blue led, PD14 - red led */
	ldr r0, =GPIOD
	ldr r1, =GPIO_MODER
	mov r2, 0x05
	lsl r2, 28
	str r2, [r0, r1]
	
	ldr r1, =Task1Function
	ldr r0, =_taskStackBottom
	add r0, #100 /* 100 byte task stack*/
	bl TaskCreate
	ldr r1, =Task2Function
	ldr r0, =_taskStackBottom
	add r0, #200
	bl TaskCreate
	
	svc 0/* schedule first task */
	b .
	
	b Reset_Handler
	
.type Task1Function, %function
Task1Function:
	mov r1, #500
	mov r2, #0
	mov r3, #0x01
	lsl r3, #15
	mov r4, #0xaa
	mov r5, r4
	mov r6, r4
	mov r7, r4
	mov r8, r4
	mov r9, r4
	mov r10, r4
	mov r11, #0xca
	
1:	bl GetSysTickCount
	cmp r0, r2
	blt 1b
	mov r2, r0
	add r2, r1
	ldr r0, =GPIOD
	str r3, [r0, #GPIO_BSRR]
	ror r3, 16
	b 1b
	
.type Task2Function, %function
Task2Function:
	mov r1, #100
	mov r2, #0
	mov r3, #0x01
	lsl r3, #14
	mov r4, #0x55
	mov r5, r4
	mov r6, r4
	mov r7, r4
	mov r8, r4
	mov r9, r4
	mov r10, r4
	mov r11, #0xdd
	
1:	bl GetSysTickCount
	cmp r0, r2
	blt 1b
	mov r2, r0
	add r2, r1
	ldr r0, =GPIOD
	str r3, [r0, #GPIO_BSRR]
	ror r3, 16
	b 1b
	