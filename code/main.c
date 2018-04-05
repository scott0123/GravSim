/************************************************************************
GravSim main file

Scott Liu, Spring 2018

For use with ECE 385 Final Project
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "planet.h"

// 0 for software simulation, 1 for hardware simulation
#define SIM_MODE 0

void software_simulation();
void hardware_simulation();

// Pointer to base address of GravSim Hardware memory,
// this needs to exactly match the address in Qsys
volatile unsigned int * MEM_PTR = (unsigned int *) 0x00001000;

/*  main()
 *
 *  Execute the pre-defined method of simulation
 *
 */
int main(){

    clock_t begin = clock();
    #if SIM_MODE == 0
    software_simulation();
    #elif SIM_MODE == 1
    hardware_simulation();
    #endif
    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    printf("Computational cycles elapsed: %d\n", (int)(end - begin));
    printf("Time spent: %.2fs\n", time_spent);

	return 0;
}

/* software_simulation()
 *
 */
void software_simulation(){
    
    // TODO

    // initialize a planet with the initial values
    // mass = 1
    // radius = 1
    // pos = (1, 0, 0)
    // vel = (0, 1, 0)
    planet p1 = { 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0 };
    
    // initialize another planet with the initial values
    // mass = 1
    // radius = 1
    // pos = (-1, 0, 0)
    // vel = (0, -1, 0)
    planet p2 = { 1.0, 1.0, -1.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0.0 };

    
}

/* hardware_simulation()
 *
 */
void hardware_simulation(){
    // TODO
}
