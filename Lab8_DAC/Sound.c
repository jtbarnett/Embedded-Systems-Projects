/*******************************************************************
 * Sound.c
 * Instructor: ***fill this in***
 * Runs on TM4C123
 * Use the SysTick timer to request interrupts at a particular period.
 * Authors: Daniel Valvano,
 *					Jonathan Valvano,
 * 					Thomas Royko
 * Student: ***fill this in***
 * Section: ***fill this in***
 * Date:    ***fill this in***
 *
 * This module calls the 4-bit DAC
 *******************************************************************/

#include "Sound.h"
#include "DAC.h"
#include "..//inc//tm4c123gh6pm.h"

unsigned char Index;
const unsigned char SineWave[32] = {8,9,11,12,13,14,14,15,15,15,14,14,13,12,11,9,8,7,5,4,3,2,2,1,1,1,2,2,3,4,5,7};

// **************Sound_Init*********************
// Initialize Systick periodic interrupts
// Also calls DAC_Init() to initialize DAC
void Sound_Init(void){
  DAC_Init();          				// Port B is DAC
  Index = 0;									// Set Index to 0
  NVIC_ST_CTRL_R = 0;         // Disable SysTick during setup
  NVIC_ST_CURRENT_R = 0;      // Any write to current clears it
	NVIC_ST_RELOAD_R = 0;
  NVIC_SYS_PRI3_R = (NVIC_SYS_PRI3_R&0x00FFFFFF)|0x20000000; // priority 1      
  NVIC_ST_CTRL_R = 0x0007;  	// Enable SysTick with core clock and interrupts 
}

// **************Sound_Tone*********************
// Change Systick periodic interrupts to start sound output
// This routine sets the RELOAD and starts SysTick
// Input: interrupt period
//           Units of period are 12.5ns
//           Maximum is 2^24-1
//           Minimum is determined by length of ISR
// Output: none
void Sound_Tone(unsigned long period){
	// Sets the RELOAD and starts SysTick
	NVIC_ST_CTRL_R = 0x0007;     // Enable SysTick with core clock and interrupts
	NVIC_ST_RELOAD_R = period-1; // RELOAD value	
}

// **************Sound_Off*********************
// Stop outputing to DAC
// This routine stops the sound output
// Output: none
void Sound_Off(void){
  // Stops the sound output
	NVIC_ST_RELOAD_R = 0; // Clear RELOAD value
	NVIC_ST_CTRL_R = 0;
	DAC_Out(0);
}

// Interrupt service routine
// Executed every 12.5ns*(period)
void SysTick_Handler(void){
  Index = (Index+1)&0x1F;
  DAC_Out(SineWave[Index]); // Output one value each interrupt
}
