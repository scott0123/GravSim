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

void debug();
void software_simulation();
void hardware_simulation();

force get_force_between_planets(planet a, planet b);
force get_force_between_planets_fast(planet a, planet b);
force negative_force(force f);
float fast_invsqrt(float f);
float fast_invsqrt_2(float f);

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
    force f = get_force_between_planets_fast(p1, p2);
    force n = negative_force(f);
    printf("Planet 1 is at (%.2f, %.2f, %.2f)\n", p1.pos_x, p1.pos_y, p1.pos_z);
    printf("Planet 2 is at (%.2f, %.2f, %.2f)\n", p2.pos_x, p2.pos_y, p2.pos_z);
    printf("This force has magnitude %.2fN\n", f.magnitude);
    printf("This force is in direction (%.2f, %.2f, %.2f)\n", f.dir_x, f.dir_y, f.dir_z);
    printf("Neg force has magnitude %.2fN\n", n.magnitude);
    printf("Neg force is in direction (%.2f, %.2f, %.2f)\n", n.dir_x, n.dir_y, n.dir_z);
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


/*
 *  get_force_between_planets(planet a, planet b)
 *
 *  The resulting force is the force planet B applies to planet A.
 */
force get_force_between_planets(planet a, planet b){

    float rel_pos_squared = fabs(a.pos_x - b.pos_x) * fabs(a.pos_x - b.pos_x)
                          + fabs(a.pos_y - b.pos_y) * fabs(a.pos_y - b.pos_y)
                          + fabs(a.pos_z - b.pos_z) * fabs(a.pos_z - b.pos_z);
    
    // direction needs to be normallized
    float mag = sqrt(rel_pos_squared);
    float dir_x = (b.pos_x - a.pos_x) / mag;
    float dir_y = (b.pos_y - a.pos_y) / mag;
    float dir_z = (b.pos_z - a.pos_z) / mag;

    force f = {G * a.mass * b.mass / rel_pos_squared, dir_x, dir_y, dir_z};
    return f;
}

/*
 *  get_force_between_planets_optimized(planet a, planet b)
 *
 *  The resulting force is the force planet B applies to planet A.
 *  This version is identical to the standard version except that
 *      we use the fast inverse square root magic.
 */
force get_force_between_planets_fast(planet a, planet b){

    float rel_pos_squared = fabs(a.pos_x - b.pos_x) * fabs(a.pos_x - b.pos_x)
                          + fabs(a.pos_y - b.pos_y) * fabs(a.pos_y - b.pos_y)
                          + fabs(a.pos_z - b.pos_z) * fabs(a.pos_z - b.pos_z);
    
    // direction needs to be normallized
    // Quake magic
    float inv_mag = fast_invsqrt(rel_pos_squared);
    float dir_x = (b.pos_x - a.pos_x) * inv_mag;
    float dir_y = (b.pos_y - a.pos_y) * inv_mag;
    float dir_z = (b.pos_z - a.pos_z) * inv_mag;

    force f = {G * a.mass * b.mass / rel_pos_squared, dir_x, dir_y, dir_z};
    return f;
}

/*
 *  negative_force(force f)
 *
 *  Get the negative of the input force.
 *  The magnitude stays the same while the direction becomes the opposite.
 */
force negative_force(force f){
    force n = {f.magnitude, -f.dir_x, -f.dir_y, -f.dir_z};
    return n;
}

/*
 *  fast_invsqrt(float f)
 *
 *  Calculate the inverse of the square root.
 *  This function employs a special method of float hacking
 *      and bit manipulation to achieve a very fast approximation.
 *  The method originated from Quake III Arena, and is seen and used
 *      in many graphics calculations.
 *  Magic number used: 0x5f3759df
 */
float fast_invsqrt(float f){

    long i;
    float x2, y;
    x2 = f * 0.5f;
    y = f;
    i = *(long*) &y;                        // evil cast
    i = QUAKE_MAGIC - (i >> 1);             // magic hack
    y = *(float*) &i;                       // evil cast again
    y = y * (THREE_HALFS - (x2 * y * y));   // Newton method iteration one
    return y;
}

/*
 *  fast_invsqrt_2(float f)
 *
 *  Calculate the inverse of the square root. Use two iterations of Newtons method instead of one.
 *  This function employs a special method of float hacking
 *      and bit manipulation to achieve a very fast approximation.
 *  The method originated from Quake III Arena, and is seen and used
 *      in many graphics calculations.
 *  Magic number used: 0x5f3759df
 */
float fast_invsqrt_2(float f){

    long i;
    float x2, y;
    x2 = f * 0.5f;
    y = f;
    i = *(long*) &y;                        // evil cast
    i = QUAKE_MAGIC - (i >> 1);             // magic hack
    y = *(float*) &i;                       // evil cast again
    y = y * (THREE_HALFS - (x2 * y * y));   // Newton method iteration one
    y = y * (THREE_HALFS - (x2 * y * y));   // Newton method iteration two
    return y;
}
