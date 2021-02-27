.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.equ TaskUninitialised, 0
.equ TaskReady, 1
.equ TaskSleeping, 2


.equ NumberOfTasks, 10
.equ TaskShift, 4

/* task structure offsets */
.equ StackPointerOffset, 0
.equ StackLimitOffset, 4
.equ TaskStateOffset, 8
.equ PriorityOffset, 12

.section .bss
NextFreeTaskId: .space 1
CurrentTaskId: .space 1

.align 4
/* task
 * u32 StackPointer
 * u32 StackLimit
 * u32 TaskState
 * u8  priority
 * u8  fill
 * u8  fill
 * u8  fill
 */
 
TaskStacks: .space (16 * NumberOfTasks)


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
			 r2 Stack size
*
* Return: 0 if success, 1 if fail
*/
.type TaskCreate, %function
.global TaskCreate
TaskCreate:
	ldr r3, =NextFreeTaskId
	ldr r3, [r3]
	cmp r3, NumberOfTasks
	blt 1f
	mov r0, #1 /* failed to create return value */
	bx lr
1:  push {r4 - r5}
	sub r5, r0, r2 /* work out stack limit, store in r5 */
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
	lsl r4, r3, #TaskShift
	str r0, [r2, r4] /* store stack pointer into array offset by next free id */
	add r4, #StackLimitOffset
	str r5, [r2, r4] /* store stack limit */	
	add r3, #1
	str r3, [r1]
	mov r0, #0
	pop {r4 - r5}
	bx lr
	
.type PendSV_Handler, %function
.global PendSV_Handler
PendSV_Handler:
	cpsid i
	mrs r3, psp /* get psp */
		
	tst lr, #0x00000010 /* was this a floating point context? */
	it      eq
	vstmdbeq  r3!, {s16-s31} /* stack fpu registers not done by hardware */
	
	stmfd r3!, {r4-r11, lr} /* push software stock frame */
	
	ldr r0, =TaskStacks
	ldr r2, =CurrentTaskId
	ldrb r1, [r2] /* load current task id into r1 */
	lsl r4, r1, #TaskShift	
	str r3, [r0, r4] /* write current stack pointer to tasks array */
	add r4, StackLimitOffset
	ldr r4, [r0, r4] /* load stack limit to r4 */
	cmp r3, r4 /* compare current sp with limit */
	it lt 
	blt StackOverflowed /* it has overflowed */
	add r1, 1 /* increment task id */
	ldr r3, =NextFreeTaskId
	ldrb r3, [r3]
	cmp r1, r3
	it eq /* have we serviced all tasks */
	moveq r1, 0  /* reset next task to 0 */
	strb r1, [r2] /* store next task */
	lsl r1, #TaskShift
	ldr r0, [r0, r1] /* load next task stack pointer into r0 */
	ldmfd r0!, {r4-r11, lr} /* pop software stack frame */
	
	tst     lr, #0x00000010 /* do we need to restore floating point context? */
	it      eq
	vldmiaeq  r0!,      {s16-s31}
	
	msr psp, r0 /* set next task stack pointer in psp */
	cpsie i
	bx lr
	
StackOverflowed:
	bkpt
	b .

.type SVC_Handler, %function
.global SVC_Handler
SVC_Handler:
	cpsid i
	ldr r0, =TaskStacks
	ldr r1, =CurrentTaskId
	ldrb r1, [r1]
	lsl r1, #TaskShift
	ldr r0, [r0, r1]
	ldmfd r0!, {r4-r11, lr}
	
	msr psp, r0
	cpsie i
	bx lr
	
	
			 