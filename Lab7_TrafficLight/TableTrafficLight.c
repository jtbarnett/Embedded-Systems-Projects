/*******************************************************************
 * TableTrafficLight.c
 * Instructor: ***Devinder Kaur***
 * Runs on LM4F120/TM4C123
 * Index implementation of a Moore finite state machine to operate a traffic light.  
 * Authors: Daniel Valvano,
 *					Jonathan Valvano,
 * 					Thomas Royko
 * Student: ***Jacob Barnett***
 * Section: ***004***
 * Date:    ***11/3/2020***
 *
 * east/west red light connected to PB5
 * east/west yellow light connected to PB4
 * east/west green light connected to PB3
 * north/south facing red light connected to PB2
 * north/south facing yellow light connected to PB1
 * north/south facing green light connected to PB0
 * pedestrian detector connected to PE2 (1=pedestrian present)
 * north/south car detector connected to PE1 (1=car present)
 * east/west car detector connected to PE0 (1=car present)
 * "walk" light connected to PF3 (built-in green LED)
 * "don't walk" light connected to PF1 (built-in red LED)
 *******************************************************************/

#include "TExaS.h"
#include "inc\tm4c123gh6pm.h"

void DisableInterrupts(void); 	// Disable interrupts
void EnableInterrupts(void);  	// Enable interrupts
void delay(unsigned long seconds);
void delay10ms(unsigned long inputTime);
void SysTick(void);
void Port_Init(void);
unsigned long timePassed = 0;
unsigned long twoSeconds = 200;
unsigned int goToWalk = 0;

typedef const struct {					// Defining the struct and storing it in the ROM
	unsigned long out[2];					// Two element sub-struct contains outputs for 2 Vehicles Traffic light & 1 Pedestrians Traffic light
	unsigned long delayTime;			// Time delay excuted for each particular state
	unsigned long next[8];				// Eight elements sub-struct contains the potential next state
}FSM;														// Name the struct FSM

#define goS 		0
#define waitS 	1
#define goW 		2
#define waitW 	3
#define walkG		4
#define walkF0	5
#define walkF1	6
#define walkF2	7
#define walkF3	8

#define Vehicle_Light 		(*((volatile unsigned long *)0x400053FC))			// GPIO_PORTB_DATA_R
#define Walk_Light				(*((volatile unsigned long *)0x400253FC))			// GPIO_PORTF_DATA_R
#define Vehicle_Sensor		(*((volatile unsigned long *)0x4002400C))			// PE1 & PE0
#define Walk_Sensor				(*((volatile unsigned long *)0x40024010))			// PE2

// Nine states ruling the transitions of states depending on the current state and the input
// We will always start the program at goN or index 0
FSM All_FSM[9]={
//LED outputs	  delay    next state depending on what PE2-PE0 input is	
	{{0x21,0x02}, 200, {goS,waitS,goS,waitS,waitS,waitS,waitS,waitS}},							// Go south -- goS
	{{0x22,0x02}, 50 , {goW,goW,goW,goW,walkG,walkG,walkG,walkG}},									// Wait south -- waitS
	{{0x0C,0x02}, 200, {goW,goW,waitW,waitW,waitW,waitW,waitW,waitW}},							// Go west -- goW
	{{0x14,0x02}, 50 , {goS,goS,goS,goS,walkG,walkG,walkG,goS}},										// Wait west -- waitW
	{{0x24,0x08}, 200, {walkG,walkF0,walkF0,walkF0,walkG,walkF0,walkF0,walkF0}},		// Walk green - green LED is on
	{{0x24,0x02}, 25 , {walkF1,walkF1,walkF1,walkF1,walkF1,walkF1,walkF1,walkF1}},	// Walk flash 0 - red LED is on
	{{0x24,0x00}, 25 , {walkF2,walkF2,walkF2,walkF2,walkF2,walkF2,walkF2,walkF2}},	// Walk flash 1 - red LED is off
	{{0x24,0x02}, 25 , {walkF3,walkF3,walkF3,walkF3,walkF3,walkF3,walkF3,walkF3}},	// Walk flash 2 - red LED is on again
	{{0x24,0x00}, 25 , {goW,goW,goS,goS,goW,goW,goS,goW}}														// Walk flash 3 - red LED off and redirect to goS or goW
};

int main(void){unsigned long State,Input,ws,vs;
	Port_Init();
	SysTick();
	// Activate grader and set system clock to 80 MHz
  TExaS_Init(SW_PIN_PE210,LED_PIN_PB543210,ScopeOff);

  EnableInterrupts();
	State = goS;
  while(1){
    Vehicle_Light = All_FSM[State].out[0];	// Outputs the indexed state result into Vehicle traffic lights
		Walk_Light = All_FSM[State].out[1];			// Outputs the indexed state result into pedestrians traffic lights
		delay10ms(All_FSM[State].delayTime);		// Calling delay SysTick and passing delay indexed in the state
		ws = Walk_Sensor;												// Inputs from switch connected to the pedestrians sensor
		vs = Vehicle_Sensor;										// Inputs from switches connected to the vehicles sensor
		Input = ws|vs;													// Combining both inputs from sensors to form the input index of the next state
		// For state goS and goW
		if ((State == 0) || (State == 2)){			// Only check if walk button was pressed for 2 seconds if current state is goS or goW
			if (timePassed == twoSeconds){				// If walk button pressed for at least 2 seconds, then add the walk input to the next state
				goToWalk = 1;
				Input |= 0x04;											// Turn the walkG state on
				timePassed = 0;											// Restart the time counter
			} else {															// Always turn walk state off if walk button not pressed for at least 2 seconds
				Input &= ~0x04;
				goToWalk = 0;
			}
		}
		// For state waitS and waitW
		if ((State == 1) || (State == 3)){
			if (goToWalk == 1){										// the goToWalk flag is set, thus we want to turn PE2 to 1
				goToWalk = 0;
				Input |= 0x04;
			} else {
				Input &= ~0x04;											// If goToWalk flag is not set, then turn PE2 to 0
			}
		}
		State = All_FSM[State].next[Input];			// next state determination will be based on the value of the index(s)
  }
}

void delay10ms(unsigned long inputTime){unsigned long i;
	unsigned long previous = Walk_Sensor&0x04;
	unsigned long current;
	for (i=0; i<inputTime; i++){
		current = Walk_Sensor&0x04;
		if ((current == 0x04) && (timePassed < twoSeconds)){	// The walk button is pressed and we want to increase time for it
			if (previous == 0x00){															// If the previous cycle recorded button not pressed, restart count
				timePassed = 0;
			}
			timePassed++;
		}
		previous = Walk_Sensor&0x04;
		delay(800000);
	}
}

void delay(unsigned long seconds){volatile unsigned long Time;
	unsigned long now = NVIC_ST_CURRENT_R;
		do{
			Time = (now - NVIC_ST_CURRENT_R) & 0x00FFFFFF;
		}while (Time <= seconds);
}

void Port_Init(void){volatile unsigned long delay;
	// Clock Init for all ports B, E, F	
	SYSCTL_RCGC2_R |= 0x32;
	delay = SYSCTL_RCGC2_R;
	
	// Port B Init, PB5-PB0 output
	GPIO_PORTB_AFSEL_R = 0x00;
	GPIO_PORTB_AMSEL_R = 0x00;
	GPIO_PORTB_PCTL_R = 0x00000000;
	GPIO_PORTB_DIR_R = 0x7F;
	GPIO_PORTB_DEN_R = 0x7F;
	
	// Port E Init, PE2-PE0 input
	GPIO_PORTE_AFSEL_R = 0x00;
	GPIO_PORTE_AMSEL_R = 0x00;
	GPIO_PORTE_PCTL_R = 0x00000000;
	GPIO_PORTE_DIR_R = 0x00;
	GPIO_PORTE_DEN_R = 0x07;
	
	// Port F Init, PF3 & PF1 output
	GPIO_PORTF_AFSEL_R = 0x00;
	GPIO_PORTF_LOCK_R = 0x4C4F434B;
	GPIO_PORTF_CR_R = 0x1F;
	GPIO_PORTF_AMSEL_R = 0x00;
	GPIO_PORTF_PCTL_R = 0x00000000;
	GPIO_PORTF_DIR_R = 0x0A;
	GPIO_PORTF_DEN_R = 0x0A;
		
}

void SysTick(void){
	NVIC_ST_CTRL_R &= ~0x01;
	NVIC_ST_RELOAD_R = 0x00FFFFFF;
	NVIC_ST_CURRENT_R = 0x00;
	NVIC_ST_CTRL_R = 0x05;
}
