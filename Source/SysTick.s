.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.include "CortexM4.inc"

.section .bss
SystickTickCount: .space 4

.section .text

/* InitialiseSysTick
 * Arguments:
 * r0 - clock speed Hz
 * r1 - period milli seconds
 * Return value: None
*/
.type InitialiseSysTick,%function
.global InitialiseSysTick
InitialiseSysTick:
	mov r2, #1000 
	udiv r0, r0, r2 /* calculate tick count for 1 ms */
	mul r0, r0, r1 /* multiply ticks for 1 ms by period */
	sub r0, #1
	
	ldr r1, =SysTick_BASE
	str r0, [r1, #SysTick_LOAD] /* set systick load value */
	
	mov r0, #0
	str r0, [r1, #SysTick_VAL] /* clear current count */
	
	ldr r0, [r1, #SysTick_CTRL]
	orr r0, #0x07 /* processor clock, interrupt enable, timer enable */
	str r0, [r1, #SysTick_CTRL]
	
	bx lr
	
/* GetSysTickCount
 * Arguments: None
 * Return value: Number of times SysTick has ticked
 */
.type GetSysTickCount,%function
.global GetSysTickCount
GetSysTickCount:
	ldr r0, =SystickTickCount
	ldr r0, [r0]
	bx lr
	
/* SysTick_Handler
 * Arguments: None
 * Return value: None
 * ISR for SysTick Timer
 */
.type SysTick_Handler,%function
.global SysTick_Handler
SysTick_Handler:
	ldr r0, =SystickTickCount
	ldr r1, [r0]
	add r1, #1
	str r1, [r0]

	bx lr
	

	