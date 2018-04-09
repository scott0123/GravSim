/***********************************************************************************

            ██████╗ ██████╗  █████╗ ██╗   ██╗███████╗██╗███╗   ███╗
           ██╔════╝ ██╔══██╗██╔══██╗██║   ██║██╔════╝██║████╗ ████║
           ██║  ███╗██████╔╝███████║██║   ██║███████╗██║██╔████╔██║
           ██║   ██║██╔══██╗██╔══██║╚██╗ ██╔╝╚════██║██║██║╚██╔╝██║
           ╚██████╔╝██║  ██║██║  ██║ ╚████╔╝ ███████║██║██║ ╚═╝ ██║
            ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝╚═╝     ╚═╝

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

************************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "physics.h"

// 0 for debug, 1 for software simulation, 2 for hardware simulation
#define SIM_MODE 0

void unit_test();
void software_simulation();
void hardware_simulation();

// Pointer to base address of GravSim Hardware memory,
// this needs to exactly match the address in Qsys
volatile unsigned int * MEM_PTR = (unsigned int *) 0x00001000;

/* 
 *  main()
 *
 *  Execute the simulation type of choice.
 */
int main(){

    clock_t begin = clock();
    #if SIM_MODE == 0
    unit_test();
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


void unit_test(){
    
    planet p1 = { 1.0, 1.0, 
                1.0, 0.0, 0.0, 
                0.0, 1.0, 0.0, 
                1.0, 1.0, 1.0 };
    planet p2 = { 1.0, 1.0, 
                -1.0, 0.0, 0.0, 
                0.0, -1.0, 0.0, 
                0.0, 0.0, -1.0 };
    force f = get_force_between_planets_fast(p1, p2);
    force n = negative_force(f);
    printf("Planet 1 is at (%.2f, %.2f, %.2f)\n", p1.pos_x, p1.pos_y, p1.pos_z);
    printf("Planet 2 is at (%.2f, %.2f, %.2f)\n", p2.pos_x, p2.pos_y, p2.pos_z);
    printf("This force has magnitude %.2fN\n", f.magnitude);
    printf("This force is in direction (%.2f, %.2f, %.2f)\n", f.dir_x, f.dir_y, f.dir_z);
    printf("Neg force has magnitude %.2fN\n", n.magnitude);
    printf("Neg force is in direction (%.2f, %.2f, %.2f)\n", n.dir_x, n.dir_y, n.dir_z);
    
    printf("===== Begin Simulation =====\n");
    for(int i = 0; i < 100; i++){
        clear_acceleration(&p1);
        clear_acceleration(&p2);
        force f = get_force_between_planets(p1, p2);
        force n = negative_force(f);
        apply_force_to_planet(f, &p1);
        apply_force_to_planet(n, &p2);
        timestep(&p1);
        timestep(&p2);
        printf("After timestep %d, planet 1 is at (%.2f, %.2f, %.2f)\n", i, p1.pos_x, p1.pos_y, p1.pos_z);
        printf("After timestep %d, planet 2 is at (%.2f, %.2f, %.2f)\n", i, p2.pos_x, p2.pos_y, p2.pos_z);
    }
}

/* 
 *  software_simulation()
 *
 *  This function handles the entirety of the software simulation.
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

/* 
 *  hardware_simulation()
 *
 *  This function handles the entirety of the hardware simulation.
 */
void hardware_simulation(){
    // TODO
}

