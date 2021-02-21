.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.include "stm32f407.inc"
.include "CortexM4.inc"

.section .text
.type Reset_Handler,%function
.globl Reset_Handler
Reset_Handler:
/* enable fpu */
	ldr r0, =SCB_CPACR
	ldr r1, [r0]
	orr r1, r1, #(0x0f << 20)
	str r1, [r0]
	dsb
	isb
	
/* fill in data memory */
	ldr r0, =_DataStart
	ldr r1, =_DataEnd
	ldr r2, =_DataLoad
	
	b 2f
1:	ldr r3, [r2], #4 /* load data from load address, increment load address by 4 */
	str r3, [r0], #4 /* store into memory, increment memory address by 4 */
2:	cmp r0, r1 /* have we written to _DataEnd */
	blo 1b /* no, loop back to 1: */

/* zero bss */
	ldr r0, =_BssStart 
	ldr r1, =_BssEnd
	ldr r2, =0

	b 2f
1:	str r2, [r0], #4 /* clear a word, address += 4 */
2:	cmp r0, r1 /* have we cleared it all? */
	blo 1b /* no, loop */
	
/*configure systick 1 ms period*/
	ldr r0, =#16000000 /* clock speed hz */
	mov r1, #1 /* 1 ms ticks */
	bl InitialiseSysTick
	
/* enable clock for GPIOD */
	ldr r0, =RCC
	ldr r2, [r0, #RCC_AHB1ENR]
	orr r2, 0x08
	str r2, [r0, #RCC_AHB1ENR]
	dsb
/* configure pin as out - PD15,14,13,12 */
	ldr r0, =GPIOD
	mov r2, #(0x55 << 24)
	str r2, [r0, #GPIO_MODER]
	
	/* create tasks */
	ldr r1, =Task1Function
	ldr r0, =_taskStackBottom
	add r0, #512 /* 512 byte task stack*/
	bl TaskCreate
	
	ldr r1, =Task2Function
	ldr r0, =_taskStackBottom
	add r0, #1024
	bl TaskCreate
	
	ldr r1, =Task3Function
	ldr r0, =_taskStackBottom
	add r0, #1536
	bl TaskCreate
	
	ldr r1, =Task4Function
	ldr r0, =_taskStackBottom
	add r0, #2048
	bl TaskCreate	
	
	svc 0/* schedule first task */
	b .
	
	b Reset_Handler
	
.type Task1Function, %function
Task1Function:
	mov r1, #100 /* 100 ms timer period */
	mov r2, #0 /* tick count at next toggle */
	mov r3, #0x01
	lsl r3, #15 /* r3 is value to write to GPIO BSRR for toggle */
	vadd.f32 s4, s6, s7 /* test fpu stacking */
1:	bl GetSysTickCount /* get current timer count */
	cmp r0, r2 /* do we need to toggle */ 
	blt 1b /* no */
	mov r2, r0 /* yes, update next toggle time with current tick count */
	add r2, r1 /* plus the tick period */
	ldr r0, =GPIOD
	str r3, [r0, #GPIO_BSRR] /* write pin state to gpio bsrr */
	ror r3, 16 /* rotate pin state by 16 bits ready for next toggle*/
	b 1b /* loop */
	
.type Task2Function, %function
Task2Function:
	mov r1, #200 /* 200 ms timer period */
	mov r2, #0 /* tick count at next toggle */
	mov r3, #0x01
	lsl r3, #14 /* r3 is value to write to GPIO BSRR for toggle */
	vadd.f32 s4, s6, s7 /* test fpu stacking */
1:	bl GetSysTickCount /* get current timer count */
	cmp r0, r2 /* do we need to toggle */ 
	blt 1b /* no */
	mov r2, r0 /* yes, update next toggle time with current tick count */
	add r2, r1 /* plus the tick period */
	ldr r0, =GPIOD
	str r3, [r0, #GPIO_BSRR] /* write pin state to gpio bsrr */
	ror r3, 16 /* rotate pin state by 16 bits ready for next toggle*/
	b 1b /* loop */
	
.type Task3Function, %function
Task3Function:
	mov r1, #400 /* 400 ms timer period */
	mov r2, #0 /* tick count at next toggle */
	mov r3, #0x01
	lsl r3, #13 /* r3 is value to write to GPIO BSRR for toggle */
	vadd.f32 s4, s6, s7 /* test fpu stacking */
1:	bl GetSysTickCount /* get current timer count */
	cmp r0, r2 /* do we need to toggle */ 
	blt 1b /* no */
	mov r2, r0 /* yes, update next toggle time with current tick count */
	add r2, r1 /* plus the tick period */
	ldr r0, =GPIOD
	str r3, [r0, #GPIO_BSRR] /* write pin state to gpio bsrr */
	ror r3, 16 /* rotate pin state by 16 bits ready for next toggle*/
	b 1b /* loop */
	
.type Task4Function, %function
Task4Function:
	mov r1, #800 /* 800 ms timer period */
	mov r2, #0 /* tick count at next toggle */
	mov r3, #0x01
	lsl r3, #12 /* r3 is value to write to GPIO BSRR for toggle */
	vadd.f32 s4, s6, s7 /* test fpu stacking */
1:	bl GetSysTickCount /* get current timer count */
	cmp r0, r2 /* do we need to toggle */ 
	blt 1b /* no */
	mov r2, r0 /* yes, update next toggle time with current tick count */
	add r2, r1 /* plus the tick period */
	ldr r0, =GPIOD
	str r3, [r0, #GPIO_BSRR] /* write pin state to gpio bsrr */
	ror r3, 16 /* rotate pin state by 16 bits ready for next toggle*/
	b 1b /* loop */
	