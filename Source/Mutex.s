.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.equ MutexLocked, 1
.equ MutexUnlocked, 0

/* LockMutex - Block until mutex acquired
 * Arguments: r0 - Address of mutex
 * Return: none
 */
.type LockMutex, %function
.global LockMutex
LockMutex:
	mov r1, #MutexLocked
1:	ldrex r2, [r0] /* load current mutex state into r2 */
	cmp r2, #MutexUnlocked /* is it locked? */
	itt eq
	strexeq r2, r1, [r0] /* store locked state in mutex, result in r2 */
	cmpeq r2, #0 /* did it succeed? */
	bne 1b /* no, loop */
	dmb /* yes */
	bx lr
	
/* FreeMutex
 * Arguments: r0 - Address of mutex
 * Return: none
 */
.type FreeMutex, %function
.global FreeMutex
FreeMutex:
	mov r1, #MutexUnlocked
	dmb
	str r1, [r0] /* unlock mutex */
	bx lr
	
