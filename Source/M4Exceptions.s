.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.global  NMI_Handler
.global  HardFault_Handler
.global  MemManage_Handler
.global  BusFault_Handler
.global  UsageFault_Handler
.global  SVC_Handler
.global  DebugMon_Handler
.global  PendSV_Handler
.global  SysTick_Handler

.section .text
NMI_Handler:
	b NMI_Handler

HardFault_Handler:
	b HardFault_Handler
	
MemManage_Handler:
	b MemManage_Handler
	
BusFault_Handler:
	b BusFault_Handler

UsageFault_Handler:
	b UsageFault_Handler
	
SVC_Handler:
	 b SVC_Handler
	 
DebugMon_Handler:
	b DebugMon_Handler
	
PendSV_Handler:
	b PendSV_Handler
	
SysTick_Handler:
	b SysTick_Handler
