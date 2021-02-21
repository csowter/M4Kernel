.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.equ NumberOfTasks, 10
.equ TaskShift, 2

.section .bss
NextFreeTaskId: .space 1
CurrentTaskId: .space 1
.align 4
TaskStacks: .space (4 * NumberOfTasks)


.section .text
/* TaskReturn 
* Arguments: none
* Return: none
* function to spin forever if a task returns
*/
.type TaskReturn, %function

TaskReturn:
	b TaskReturn

/* TaskCreate 
* Arguments: r0 Top of stack
*            r1 Task function
*
* Return: 0 if success, 1 if fail
*/
.type TaskCreate, %function
.global TaskCreate
TaskCreate:
	mov r2, r1
	mov r1, #0x01
	lsl r1, #24
	stmfd r0!, {r1} /* xPSR */
	stmfd r0!, {r2} /* pc */
	ldr r3, =TaskReturn
	stmfd r0!, {r3} /* lr */
	mov r3, #0
	stmfd r0!, {r3} /* r12 */
	stmfd r0!, {r3} /* r3 */
	stmfd r0!, {r3} /* r2 */
	stmfd r0!, {r3} /* r1 */
	stmfd r0!, {r3} /* push r0 */
	mvn r3, #0
	sub r3, #2
	stmfd r0!, {r3} /* software stacked lr, 0xfffffffd */

	mov r3, #0
	stmfd r0!, {r3}	/* r11 */
	stmfd r0!, {r3}	/* r10 */
	stmfd r0!, {r3}	/* r9 */
	stmfd r0!, {r3}	/* r8 */
	stmfd r0!, {r3}	/* r7 */
	stmfd r0!, {r3}	/* r6 */
	stmfd r0!, {r3}	/* r5 */
	stmfd r0!, {r3}	/* r4 */
	
	/* add stack pointer to tasks array */
	ldr r1, =NextFreeTaskId
	ldr r3, [r1]
	
	ldr r2, =TaskStacks
	
	str r0, [r2, r3, LSL #TaskShift] /* store stack pointer into array offset by next free id */
	add r3, #1
	str r3, [r1]
	bx lr
	
.type PendSV_Handler, %function
.global PendSV_Handler
PendSV_Handler:
	cpsid i
	mrs r3, psp /* get psp */
	stmfd r3!, {r4-r11, lr}
	
	ldr r0, =TaskStacks
	ldr r2, =CurrentTaskId
	ldrb r1, [r2]
	str r3, [r0, r1, LSL #TaskShift] /* write current stack pointer to tasks array */
	add r1, 1 /* increment task id */
	ldr r3, =NextFreeTaskId
	ldrb r3, [r3]
	cmp r1, r3
	it eq /* have we serviced all tasks */
	moveq r1, 0  /* reset next task to 0 */
	strb r1, [r2]
	ldr r0, [r0, r1, LSL #TaskShift] /* load next task stack pointer into r0 */
	ldmfd r0!, {r4-r11, lr}
	msr psp, r0 /* set next task stack pointer in psp */
	cpsie i
	bx lr

.type SVC_Handler, %function
.global SVC_Handler
SVC_Handler:
	cpsid i
	ldr r0, =TaskStacks
	ldr r1, =CurrentTaskId
	ldrb r1, [r1]
	ldr r0, [r0, r1, LSL #TaskShift]
	ldmfd r0!, {r4-r11, lr}
	
	msr psp, r0
	cpsie i
	bx lr
	
			 