.equ SCS_BASE            ,(0xE000E000UL)                            /*!< System Control Space Base Address */
.equ ITM_BASE            ,(0xE0000000UL)                            /*!< ITM Base Address */
.equ DWT_BASE            ,(0xE0001000UL)                            /*!< DWT Base Address */
.equ TPI_BASE            ,(0xE0040000UL)                            /*!< TPI Base Address */
.equ CoreDebug_BASE      ,(0xE000EDF0UL)                            /*!< Core Debug Base Address */
.equ SysTick_BASE        ,(SCS_BASE +  0x0010UL)                    /*!< SysTick Base Address */
.equ NVIC_BASE           ,(SCS_BASE +  0x0100UL)                    /*!< NVIC Base Address */
.equ SCB_BASE            ,(SCS_BASE +  0x0D00UL)     				/*!< System Control Block Base Addres */

/* SysTick offsets */
.equ SysTick_CTRL	,0x00
.equ SysTick_LOAD	,0x04
.equ SysTick_VAL	,0x08
.equ SysTick_CALIB	,0x0c

/* SCB offsets */
.equ SCB_ICSR, 0x04
