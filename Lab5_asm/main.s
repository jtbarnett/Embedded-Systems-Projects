;*******************************************************************
; main.s
; Author: ***update this***
; Date Created: 11/18/2016
; Last Modified: 11/18/2016
; Section Number: ***update this***
; Instructor: ***update this***
; Lab number: 5
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE1 is switch input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard) 
; Overall functionality is similar to Lab 4, with six changes:
;   1) the pin to which we connect the switch is moved to PE1, 
;   2) you will have to remove the PUR initialization because
;      pull up is no longer needed. 
;   3) the pin to which we connect the LED is moved to PE0, 
;   4) the switch is changed from negative to positive logic, and 
;   5) you should increase the delay so it flashes about 8 Hz.
;   6) the LED should be on when the switch is not pressed
; Operation
;   1) Make PE0 an output and make PE1 an input. 
;   2) The system starts with the LED on (make PE0 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE1 is 1), then toggle the LED
;      once, else turn the LED on. 
;   5) Steps 3 and 4 are repeated over and over
;*******************************************************************

GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
DELAY_VALUE				EQU	  0x000C9D2B ; 0x0012EBC0 for Simulation and 0x000C9D2B for Board

       IMPORT  TExaS_Init

       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
		; TExaS_Init sets bus clock at 80 MHz
		BL  TExaS_Init ; voltmeter, scope on PD3
		BL	GPIOE_INIT

		CPSIE  I    ; TExaS voltmeter, scope runs on interrupts

		LDR R0,=GPIO_PORTE_DATA_R	; start with LED on
		MOV R1,#0x01
		STR R1,[R0]

loop
		BL	CHECK_INPUT				; check if switch is pressed
		B    loop

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
		B	loop

GPIOE_INIT
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


		ALIGN      ; make sure the end of this section is aligned
		END        ; end of file
       