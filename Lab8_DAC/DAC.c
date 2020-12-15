/*******************************************************************
 * DAC.c
 * Instructor: ***fill this in***
 * Runs on TM4C123
 * Implementation of the 4-bit digital to analog converter
 * Authors: Daniel Valvano,
 *					Jonathan Valvano,
 * 					Thomas Royko
 * Student: ***fill this in***
 * Section: ***fill this in***
 * Date:    ***fill this in***
 *
 * Port B bits 3-0 have the 4-bit DAC
 *******************************************************************/

#include "DAC.h"
#include "..//inc//tm4c123gh6pm.h"

// **************DAC_Init*********************
// Initialize 4-bit DAC 
// Input: none
// Output: none
void DAC_Init(void){
	// DAC bit 3  PB3
	// DAC bit 2  PB2
	// DAC bit 1  PB1
	// DAC bit 0  PB0
	GPIO_PORTB_AMSEL_R &= ~0x1F; 			// disable analog function on PB3-0
  GPIO_PORTB_PCTL_R &= ~0x00FFFFFF; // enable regular GPIO
  GPIO_PORTB_DIR_R |= 0x1F;    			// outputs on PB3-0
  GPIO_PORTB_AFSEL_R &= ~0x1F; 			// regular function on PB3-0
  GPIO_PORTB_DEN_R |= 0x1F;    			// enable digital on PB3-0
  GPIO_PORTB_DR8R_R |= 0x1F; 				// can drive up to 8mA out though PB3-0

	// Connect PD3 to your DAC output
	GPIO_PORTD_AMSEL_R &= 0x00; 			// disable analog function on PD3
  GPIO_PORTD_PCTL_R &= 0x00000000; 	// no analog on Port D
	GPIO_PORTD_DIR_R &= ~0x04;   			// input on PD3
  GPIO_PORTD_AFSEL_R &= 0x00; 			// regular function on PD3
  GPIO_PORTD_DEN_R |= 0x04;    			// enable digital on PD3
}

// **************DAC_Out*********************
// output to DAC
// Input: 4-bit data, 0 to 15 
// Output: none
void DAC_Out(unsigned long data){
	GPIO_PORTB_DATA_R = data;
}
