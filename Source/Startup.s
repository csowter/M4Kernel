.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.include "stm32f407.inc"

.section .text
.globl ResetHandler
ResetHandler:
/* enable clock for GPIOD */
	ldr r0, =RCC
	ldr r1, =RCC_AHB1ENR
	mov r2, 0x08
	str r2, [r0, r1]
	isb
/* configure pin as out - PD15 - blue led */
	ldr r0, =GPIOD
	ldr r1, =GPIO_MODER
	mov r2, 0x01
	lsl r2, 30
	str r2, [r0, r1]
	ldr r1, =GPIO_BSRR
	mov r2, 0x01
	lsl r2, 15
flashloop:
	str r2, [r0, r1]
	ror r2, 16
	b flashloop
	
	
	
	
	b ResetHandler
	