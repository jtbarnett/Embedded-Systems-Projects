;*******************************************************************
; main.s
; Author: ***update this***
; Date Created: 11/18/2016
; Last Modified: 11/18/2016
; Section Number: ***update this***
; Instructor: ***update this***
; Lab number: 6
; Brief description of the program
;   If the switch is pressed, the LED toggles at 8 Hz
; Hardware connections
;   PE1 is switch input  (1 means pressed, 0 means not pressed)
;   PE0 is LED output (1 activates external LED on protoboard) 
; Overall functionality is similar to Lab 5, with three changes:
;   1) Initialize SysTick with RELOAD 0x00FFFFFF 
;   2) Add a heartbeat to PF2 that toggles every time through loop 
;   3) Add debugging dump of input, output, and time
; Operation
;	1) Make PE0 an output and make PE1 an input. 
;	2) The system starts with the LED on (make PE0 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE1 is 1), then toggle the LED
;      once, else turn the LED on.
;   5) Steps 3 and 4 are repeated over and over
;*******************************************************************

SWITCH                  EQU 0x40024004  ;PE0
LED                     EQU 0x40024008  ;PE1
SYSCTL_RCGCGPIO_R       EQU 0x400FE608
SYSCTL_RCGC2_GPIOE      EQU 0x00000010  ;port E Clock Gating Control
SYSCTL_RCGC2_GPIOF      EQU 0x00000020  ;port F Clock Gating Control
GPIO_PORTE_DATA_R       EQU 0x400243FC
GPIO_PORTE_DIR_R        EQU 0x40024400
GPIO_PORTE_AFSEL_R      EQU 0x40024420
GPIO_PORTE_PUR_R        EQU 0x40024510
GPIO_PORTE_DEN_R        EQU 0x4002451C
GPIO_PORTF_DATA_R       EQU 0x400253FC
GPIO_PORTF_DIR_R        EQU 0x40025400
GPIO_PORTF_AFSEL_R      EQU 0x40025420
GPIO_PORTF_PUR_R        EQU 0x40025510
GPIO_PORTF_DEN_R        EQU 0x4002551C
GPIO_PORTF_AMSEL_R      EQU 0x40025528
GPIO_PORTF_PCTL_R       EQU 0x4002552C
GPIO_PORTF_LOCK_R  	    EQU 0x40025520
GPIO_PORTF_CR_R         EQU 0x40025524
NVIC_ST_CTRL_R          EQU 0xE000E010
NVIC_ST_RELOAD_R        EQU 0xE000E014
NVIC_ST_CURRENT_R       EQU 0xE000E018
GPIO_PORTE_AMSEL_R      EQU 0x40024528
GPIO_PORTE_PCTL_R       EQU 0x4002452C

			THUMB
			AREA	DATA, ALIGN=4
SIZE       	EQU    	50
;You MUST use these two buffers and two variables
;You MUST not change their names
DataBuffer	SPACE  	SIZE*4
TimeBuffer 	SPACE  	SIZE*4
DataPt     	SPACE  	4
TimePt     	SPACE  	4
CountArray	SPACE	4
DELAY_VALUE	EQU		0x0012EBC0 ; 0x0012EBC0 for Simulation and 0x000C9D2B for Board
;These names MUST be exported
			EXPORT 	DataBuffer
			EXPORT 	TimeBuffer
			EXPORT 	DataPt [DATA,SIZE=4]
			EXPORT 	TimePt [DATA,SIZE=4]
			EXPORT	CountArray [DATA,SIZE=4]
			EXPORT	DELAY_VALUE

		ALIGN
		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB
		EXPORT  Start
		IMPORT  TExaS_Init
Start
		BL	TExaS_Init  ; running at 80 MHz, scope voltmeter on PD3
		BL	PortE_Init
		BL	PortF_Init
		BL	Debug_Init
		CPSIE  I    	; TExaS voltmeter, scope runs on interrupts
		LDR R0,=GPIO_PORTE_DATA_R	; start with LED on
		MOV R1,#0x01
		STR R1,[R0]

loop  	
		BL	Debug_Capture
continue_loop
		BL	Heart_Beat
		BL	CHECK_INPUT
		B	loop

DELAY
		SUBS R0,R0,#0x01
		BNE	DELAY
		BX LR

CHECK_INPUT
		LDR R0,=GPIO_PORTE_DATA_R
		LDR R1,[R0]
		AND R1,R1,#0x03
		CMP R1,#0x03
		BEQ	SWITCH_ON
		BNE SWITCH_OFF

SWITCH_ON
		LDR R0,=GPIO_PORTE_DATA_R	; turn LED off
		MOV R1,#0x00
		STR R1,[R0]
		LDR R0,=DELAY_VALUE
		BL	DELAY
		; debug and haertbeat
		BL	Debug_Capture
		BL	Heart_Beat
		LDR R0,=GPIO_PORTE_DATA_R	; turn LED on
		MOV R1,#0x01
		STR R1,[R0]
		LDR R0,=DELAY_VALUE
		BL	DELAY
		B	loop

SWITCH_OFF
		LDR R0,=GPIO_PORTE_DATA_R
		MOV R1,#0x01
		STR R1,[R0]
		LDR R0,=DELAY_VALUE
		BL	DELAY
		B	loop

Heart_Beat
		LDR R0,=GPIO_PORTF_DATA_R
		LDR R1,[R0]
		MOV R2,#0x04
		EOR R3,R1,R2
		STR	R3,[R0]
		BX	LR

;------------Debug_Init------------
; Initializes the debugging instrument
; Note: push/pop an even number of registers so C compiler is happy
Debug_Init
		; init SysTick
		LDR R1,=NVIC_ST_CTRL_R
		MOV R0,#0
		STR R0,[R1] ; 1) disable SysTick during setup
		LDR R1,=NVIC_ST_RELOAD_R
		MOV R0,#0x00FFFFFF
		STR R0,[R1] ; 2) maximum reload value
		LDR R1,=NVIC_ST_CURRENT_R
		MOV R0,#0
		STR R0,[R1] ; 3) any write to current clears it
		LDR R1,=NVIC_ST_CTRL_R
		MOV R0,#0x00000005
		STR R0,[R1] ; 4) enable SysTick with core clock BX LR
		; set count
		LDR R0,=CountArray
		MOV R1,#1
		STR	R1,[R0]
		; set up pointers
		LDR R0,=DataBuffer
		LDR R1,=DataPt
		STR R0,[R1]
		LDR R0,=TimeBuffer
		LDR R1,=TimePt
		STR R0,[R1]
		; set up arrays
		MOV R0,#0xFFFFFFFF
		MOV R1,#0			; index
		MOV R2,#50			; number of iterations
		LDR	R3,=DataBuffer
loop1
		STR R0,[R3],#4
		ADD R1,R1,#1
		CMP R1,R2
		BLT loop1
		MOV R1,#0			; index
		LDR	R3,=TimeBuffer
loop2
		STR R0,[R3],#4
		ADD R1,R1,#1
		CMP R1,R2
		BLT loop2
		BX	LR

;------------Debug_Capture------------
; Dump Port E and time into buffers
; Note: push/pop an even number of registers so C compiler is happy
Debug_Capture
		; check count to see if we need to exit
		LDR R0,=CountArray
		LDR R1,[R0]
		MOV R2,#50			; equivalent to 50 iterations
		CMP R1,R2
		BGT	continue_loop	; return if we have already iterated 50 times
		; record the Port E data
		LDR R0,=GPIO_PORTE_DATA_R
		LDR R1,[R0]
		AND R1,R1,#0x03
		AND R2,R1,#0x02
		LSL	R2,#3
		AND	R1,R1,#0x01
		ORR	R1,R1,R2
		LDR R0,=DataPt
		LDR R2,[R0]
		STR R1,[R2]
		ADD R2,R2,#4
		STR R2,[R0]
		; record SysTick data
		LDR R0,=NVIC_ST_CURRENT_R
		LDR R1,[R0]
		LDR R0,=TimePt
		LDR R2,[R0]
		STR	R1,[R2]
		ADD R2,R2,#4
		STR R2,[R0]
		; increment count
		LDR R0,=CountArray
		LDR R1,[R0]
		ADD R1,R1,#1
		STR R1,[R0]
		BX 	LR

PortE_Init
		LDR R0,=SYSCTL_RCGCGPIO_R
		LDR R1,[R0]
		ORR R1,R1, #0x10
		STR R1,[R0]
		NOP
		NOP
		LDR R0,=GPIO_PORTE_AMSEL_R
		MOV R1,#0x00
		STR R1,[R0]
		LDR R0,=GPIO_PORTE_PCTL_R
		STR R1,[R0]
		LDR R0,=GPIO_PORTE_AFSEL_R
		STR R1,[R0]
		LDR R0,=GPIO_PORTE_DIR_R
		MOV R1,#0x01
		STR R1,[R0]
		LDR R0,=GPIO_PORTE_DEN_R
		MOV R1,#0x03
		STR R1,[R0]
		BX	LR

PortF_Init
		LDR R0,=SYSCTL_RCGCGPIO_R
		LDR R1,[R0]
		ORR R1,R1, #0x20
		STR R1,[R0]
		NOP
		NOP
		LDR R0,=GPIO_PORTF_AMSEL_R
		MOV R1,#0x00
		STR R1,[R0]
		LDR R0,=GPIO_PORTF_PCTL_R
		STR R1,[R0]
		LDR R0,=GPIO_PORTF_AFSEL_R
		STR R1,[R0]
		LDR R0,=GPIO_PORTF_DIR_R
		MOV R1,#0x04
		STR R1,[R0]
		LDR R0,=GPIO_PORTF_DEN_R
		MOV R1,#0x04
		STR R1,[R0]
		BX	LR

		ALIGN      ; make sure the end of this section is aligned
		END        ; end of file
        