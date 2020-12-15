;*******************************************************************
; main.s
; Author: ***update this***
; Date Created: 11/18/2016
; Last Modified: 11/18/2016
; Section Number: ***update this***
; Instructor: ***update this***
; Lab number: 4 
;   Brief description of the program
; The overall objective of this system is an interactive alarm
; Hardware connections
;   PF4 is switch input  (1 = switch not pressed, 0 = switch pressed)
;   PF3 is LED output    (1 activates green LED) 
; The specific operation of this system 
;   1) Make PF3 an output and make PF4 an input (enable PUR for PF4). 
;   2) The system starts with the LED OFF (make PF3 =0). 
;   3) Delay for about 100 ms
;   4) If the switch is pressed (PF4 is 0),`
;      then toggle the LED once, else turn the LED OFF. 
;   5) Repeat steps 3 and 4 over and over
;*******************************************************************

GPIO_PORTF_DATA_R       EQU   0x400253FC
GPIO_PORTF_DIR_R        EQU   0x40025400
GPIO_PORTF_AFSEL_R      EQU   0x40025420
GPIO_PORTF_PUR_R        EQU   0x40025510
GPIO_PORTF_DEN_R        EQU   0x4002551C
GPIO_PORTF_AMSEL_R      EQU   0x40025528
GPIO_PORTF_PCTL_R       EQU   0x4002552C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
GPIO_PORTF_LOCK_R  	    EQU   0x40025520
GPIO_PORTF_CR_R         EQU   0x40025524
GPIO_LOCK_KEY			EQU	  0x4C4F434B
DELAY_VALUE				EQU	  0x0003C8C0 ; 0x00061A80 for Simulation and 0x00082355 for Board 0x0003C8C0
GREEN					EQU	  0x08

		AREA    |.text|, CODE, READONLY, ALIGN=2
		THUMB
		EXPORT  Start
Start
		BL	GPIOF_INIT
		LDR R0, =GPIO_PORTF_DATA_R
		MOV R1, #0x10
		STR R1, [R0]
		
loop
		BL	CHECK_INPUT
		B	loop

DELAY
		SUBS R0, R0, #0x01
		BNE	DELAY
		BX LR

CHECK_INPUT
		LDR R0, =GPIO_PORTF_DATA_R
		LDR R1, [R0]
		AND R1, R1, #0x10
		CMP R1, #0x00
		BEQ	SWITCH_ON
		BNE SWITCH_OFF
		
SWITCH_ON
		LDR R0, =GPIO_PORTF_DATA_R
		MOV R1, #GREEN
		STR R1, [R0]
		LDR R0, =DELAY_VALUE
		BL	DELAY
		LDR R0, =GPIO_PORTF_DATA_R
		MOV R1, #0x10
		STR R1, [R0]
		LDR R0, =DELAY_VALUE
		BL	DELAY
		B	loop
		
SWITCH_OFF
		LDR R0, =GPIO_PORTF_DATA_R
		MOV R1, #0x10
		STR R1, [R0]
		B	loop

GPIOF_INIT
		LDR R0, =SYSCTL_RCGCGPIO_R
		LDR R1, [R0]
		ORR R1, R1, #0x20
		STR R1, [R0]
		NOP
		NOP
		LDR R0, =GPIO_PORTF_LOCK_R
		LDR R1, =GPIO_LOCK_KEY
		STR R1, [R0]
		LDR R0, =GPIO_PORTF_CR_R
		MOV R1, #0x18
		STR R1, [R0]
		LDR R0, =GPIO_PORTF_AMSEL_R
		MOV R1, #0x00
		STR R1, [R0]
		LDR R0, =GPIO_PORTF_PCTL_R
		STR R1, [R0]
		LDR R0, =GPIO_PORTF_AFSEL_R
		STR R1, [R0]
		LDR R0, =GPIO_PORTF_DIR_R
		MOV R1, #0x08
		STR R1, [R0]
		LDR R0, =GPIO_PORTF_PUR_R
		MOV R1, #0x10
		STR R1, [R0]
		LDR R0, =GPIO_PORTF_DEN_R
		MOV R1, #0x18
		STR R1, [R0]
		BX	LR
		
		
		ALIGN      ; make sure the end of this section is aligned
		END        ; end of file
       