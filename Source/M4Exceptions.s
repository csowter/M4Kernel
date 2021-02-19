.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.global Reset_Handler
.global NMI_Handler
.global HardFault_Handler
.global MemManage_Handler
.global BusFault_Handler
.global UsageFault_Handler
.global SVC_Handler
.global DebugMon_Handler
.global PendSV_Handler
.global SysTick_Handler

.section .text

.type Reset_Handler,%function
.weak Reset_Handler
Reset_Handler:
	b Reset_Handler

.type NMI_Handler,%function
.weak NMI_Handler
NMI_Handler:
	b NMI_Handler

.type HardFault_Handler,%function
.weak HardFault_Handler
HardFault_Handler:
	pop {r8}
	pop {r7}
	pop {r6}
	pop {r5}
	
	pop {r3}
	pop {r2}
	pop {r1}
	pop {r0}
	1:
	b 1b
	
.type MemManage_Handler,%function
.weak MemManage_Handler
MemManage_Handler:
	b MemManage_Handler

.type BusFault_Handler,%function
.weak BusFault_Handler
BusFault_Handler:
	b BusFault_Handler

.weak UsageFault_Handler
UsageFault_Handler:
	b UsageFault_Handler
	
.weak SVC_Handler
SVC_Handler:
	 b SVC_Handler

.weak DebugMon_Handler
DebugMon_Handler:
	b DebugMon_Handler
	
.weak PendSV_Handler
PendSV_Handler:
	b PendSV_Handler

.type SysTick_Handler,%function
.weak SysTick_Handler
SysTick_Handler:
	b SysTick_Handler
