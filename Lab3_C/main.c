#include <stdint.h>
#include "inc/tm4c123gh6pm.h"

void initPortA(void);
void initPortB(void);
void initPortC(void);
void initPortD(void);
void setLED(unsigned long input);

int main(void){
	initPortA();
	while(1){
		// Set LED value of pins PA5, PA4, and PA3
		setLED(0x28);
  }
}

void setLED(unsigned long input){
	GPIO_PORTA_DATA_R = input;
}

void initPortA(void){
	volatile unsigned long delay;
	// Init Port A
	SYSCTL_RCGCGPIO_R |= 0x00000010;	// 1) activate clock for Port A
	delay = SYSCTL_RCGCGPIO_R;				// allow time for clock to start 
	GPIO_PORTA_LOCK_R = 0x4C4F434B;   // 2) unlock PortA  
  GPIO_PORTA_CR_R = 0x38;           // allow changes to PA5-PA3 
  GPIO_PORTA_AMSEL_R = 0x00;        // 3) disable analog on PA
	GPIO_PORTA_PCTL_R = 0x00000000;   // 4) GPIO clear bit PCTL  
  GPIO_PORTA_DIR_R = 0x38;          // 5) PA5-PA3 out
  GPIO_PORTA_AFSEL_R = 0x00;        // 6) disable alt funct on PA7-0
  GPIO_PORTA_PUR_R = 0x00;          // Don't enable pull up
  GPIO_PORTA_DEN_R = 0x38;					// 7) enable digital I/O on PA7
}

void initPortD(void){
	volatile unsigned long delay;
	// Init Port D
	SYSCTL_RCGCGPIO_R |= 0x00000008;	// 1) activate clock for Port D
	delay = SYSCTL_RCGCGPIO_R;				// allow time for clock to start
	GPIO_PORTD_LOCK_R = 0x4C4F434B;   // 2) unlock PortD  
  GPIO_PORTD_CR_R = 0x10;           // allow changes to PD4 
  GPIO_PORTD_AMSEL_R = 0x00;        // 3) disable analog on PE
	GPIO_PORTD_PCTL_R = 0x00000000;   // 4) GPIO clear bit PCTL 
  GPIO_PORTD_DIR_R = 0x10;          // 5) PD4 out
  GPIO_PORTD_AFSEL_R = 0x00;        // 6) disable alt funct on PD7-0
  GPIO_PORTD_PUR_R = 0x00;          // Don't enable pull up
  GPIO_PORTD_DEN_R = 0x10;					// 7) enable digital I/O on PD4
}

void initPortC(void){
	volatile unsigned long delay;
	// Init Port C
	SYSCTL_RCGCGPIO_R |= 0x00000004;	// 1) activate clock for Port C
	delay = SYSCTL_RCGCGPIO_R;				// allow time for clock to start
	GPIO_PORTC_LOCK_R = 0x4C4F434B;   // 2) unlock PortC  
  GPIO_PORTC_CR_R = 0x40;           // allow changes to PC6 
  GPIO_PORTC_AMSEL_R = 0x00;        // 3) disable analog on PC
	GPIO_PORTC_PCTL_R = 0x00000000;   // 4) GPIO clear bit PCTL  
  GPIO_PORTC_DIR_R = 0x40;          // 5) PC6 out
  GPIO_PORTC_AFSEL_R = 0x00;        // 6) disable alt funct on PC7-0
  GPIO_PORTC_PUR_R = 0x00;          // Don't enable pull up
  GPIO_PORTC_DEN_R = 0x40;					// 7) enable digital I/O on PC6
}

void initPortB(void){
	volatile unsigned long delay;
	// Init Port B
	SYSCTL_RCGCGPIO_R |= 0x00000002;	// 1) activate clock for Port B
	delay = SYSCTL_RCGCGPIO_R;				// allow time for clock to start
	GPIO_PORTB_LOCK_R = 0x4C4F434B;   // 2) unlock PortB PB0  
  GPIO_PORTB_CR_R = 0x01;           // allow changes to PB0  
  GPIO_PORTB_AMSEL_R = 0x00;        // 3) disable analog on PB
	GPIO_PORTB_PCTL_R = 0x00000000;   // 4) GPIO clear bit PCTL  
  GPIO_PORTB_DIR_R = 0x00;          // 5) PB0 in
  GPIO_PORTB_AFSEL_R = 0x00;        // 6) disable alt funct on PB7-0
  GPIO_PORTB_PUR_R = 0x01;          // enable pull-up for PB0
  GPIO_PORTB_DEN_R = 0x01;					// 7) enable digital I/O on PB0
}
