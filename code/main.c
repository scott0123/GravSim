/************************************************************************
GravSim main file

Scott Liu, Spring 2018

For use in

 ███████╗ ██████╗███████╗██████╗  █████╗ ███████╗
 ██╔════╝██╔════╝██╔════╝╚════██╗██╔══██╗██╔════╝
 █████╗  ██║     █████╗   █████╔╝╚█████╔╝███████╗
 ██╔══╝  ██║     ██╔══╝   ╚═══██╗██╔══██╗╚════██║
 ███████╗╚██████╗███████╗██████╔╝╚█████╔╝███████║
 ╚══════╝ ╚═════╝╚══════╝╚═════╝  ╚════╝ ╚══════╝
 
University of Illinois Electrical & Computer Engineering Department
(This is used to prevent a simple Google search giving free code to future students)
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "physics.h"

// 0 for debug, 1 for software simulation, 2 for hardware simulation
#define SIM_MODE 0

void debug();
void software_simulation();
void hardware_simulation();

float get_force_between_planets(planet a, planet b);

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
    debug();
    #elif SIM_MODE == 1
    software_simulation();
    #elif SIM_MODE == 2
    hardware_simulation();
    #endif
    clock_t end = clock();
    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
    printf("Computational cycles elapsed: %d\n", (int)(end - begin));
    printf("Time spent: %.2fs\n", time_spent);

	return 0;
}


void debug(){
    
    planet p1 = { 1000000.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0 };
    planet p2 = { 1000000.0, 1.0, -1.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0.0 };
    float force = get_force_between_planets(p1, p2);
    printf("we think the force is %.2fN\n", force);
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


float get_force_between_planets(planet a, planet b){

    float rel_pos_squared = fabs(a.pos_x - b.pos_x) * fabs(a.pos_x - b.pos_x)
                          + fabs(a.pos_y - b.pos_y) * fabs(a.pos_y - b.pos_y)
                          + fabs(a.pos_z - b.pos_z) * fabs(a.pos_z - b.pos_z);

    return G * a.mass * b.mass / rel_pos_squared;
}

