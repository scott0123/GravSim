/***********************************************************************************

            â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ•—   â–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ•—   â–ˆâ–ˆâ–ˆâ•—
           â–ˆâ–ˆâ•”â•�â•�â•�â•�â•� â–ˆâ–ˆâ•”â•�â•�â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•�â•�â–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•�â•�â•�â•�â•�â–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ•‘
           â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•�â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â–ˆâ–ˆâ–ˆâ–ˆâ•”â–ˆâ–ˆâ•‘
           â–ˆâ–ˆâ•‘   â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•”â•�â•�â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•�â•�â–ˆâ–ˆâ•‘â•šâ–ˆâ–ˆâ•— â–ˆâ–ˆâ•”â•�â•šâ•�â•�â•�â•�â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘â•šâ–ˆâ–ˆâ•”â•�â–ˆâ–ˆâ•‘
           â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•�â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘  â–ˆâ–ˆâ•‘ â•šâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•� â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘â–ˆâ–ˆâ•‘ â•šâ•�â•� â–ˆâ–ˆâ•‘
            â•šâ•�â•�â•�â•�â•�â•� â•šâ•�â•�  â•šâ•�â•�â•šâ•�â•�  â•šâ•�â•�  â•šâ•�â•�â•�â•�  â•šâ•�â•�â•�â•�â•�â•�â•�â•šâ•�â•�â•šâ•�â•�     â•šâ•�â•�

GravSim main file

Scott Liu, Spring 2018

For use in

             â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•— â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—
             â–ˆâ–ˆâ•”â•�â•�â•�â•�â•�â–ˆâ–ˆâ•”â•�â•�â•�â•�â•�â–ˆâ–ˆâ•”â•�â•�â•�â•�â•�â•šâ•�â•�â•�â•�â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•�â•�â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•�â•�â•�â•�â•�
             â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—  â–ˆâ–ˆâ•‘     â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—   â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•�â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•�â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—
             â–ˆâ–ˆâ•”â•�â•�â•�  â–ˆâ–ˆâ•‘     â–ˆâ–ˆâ•”â•�â•�â•�   â•šâ•�â•�â•�â–ˆâ–ˆâ•—â–ˆâ–ˆâ•”â•�â•�â–ˆâ–ˆâ•—â•šâ•�â•�â•�â•�â–ˆâ–ˆâ•‘
             â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•—â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•�â•šâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•”â•�â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ•‘
             â•šâ•�â•�â•�â•�â•�â•�â•� â•šâ•�â•�â•�â•�â•�â•�â•šâ•�â•�â•�â•�â•�â•�â•�â•šâ•�â•�â•�â•�â•�â•�  â•šâ•�â•�â•�â•�â•� â•šâ•�â•�â•�â•�â•�â•�â•�
 
University of Illinois Electrical & Computer Engineering Department
(This is used to prevent a simple Google search giving free code to future students)

************************************************************************************/

#define CPP_COMPILE 0

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "physics.h"

#if CPP_COMPILE == 1
#include "GifGenerator.h"
#endif

// 0 for debug, 1 for software simulation, 2 for hardware simulation
#define SIM_MODE 1
#define SIM_TIME 20 // (seconds)
#define SIM_FPS 30

void unit_test();
void software_simulation();
void hardware_simulation();

// Pointer to base address of GravSim Hardware memory,
// this needs to exactly match the address in Qsys
volatile unsigned int * MEM_PTR = (unsigned int *) 0x00000040;

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

    #if CPP_COMPILE == 1
    GifGenerator gif(400, 400);
    #endif
    #if CPP_COMPILE == 0
    //for(int l = -10; l <= 10; l++){
    //for(int k = -10; k <= 10; k++){
    //for(int j = -10; j <= 10; j++){
    #endif
    planet p1 = { 1.0, 1.0, 
                1.0, 0.0, 0.0, 
                0.0, 1.0, 0.0, 
                0.0, 0.0, 1.0 };
    planet p2 = { 1.0, 1.0, 
                -1.0, 0.0, 0.0, 
                0.0, -1.0, 0.0, 
                0.0, 0.0, -1.0 };
    planet p3 = { 1.0, 1.0, 
                0.0, 1.0, 0.0, 
                -1.0, 0.0, 0.0, 
                0.0, 0.0, -1.0 };
    #if CPP_COMPILE == 1
    planet p4 = { 0.92, 1.0, 
                0.0, -1.07, 0.0, 
                0.97, 0.0, 0.0, 
                0.0, 0.0, -1.0 };
    #endif
    #if CPP_COMPILE == 0
    planet p4 = { 0.92, 1.0, 
                0.0, -1.07, 0.0, 
                0.97, 0.0, 0.0, 
                0.0, 0.0, -1.0 };
    //planet p4 = { 1.0+(float)k/100, 1.0, 
    //            0.0, -1.0+(float)l/100, 0.0, 
    //           1.0f+(float)j/100, 0.0, 0.0, 
    //            0.0, 0.0, -1.0 };
    #endif
    force f = get_force_between_planets(p1, p2);
    force n = negative_force(f);
    printf("Planet 1 is at (%.2f, %.2f, %.2f)\n", p1.pos_x, p1.pos_y, p1.pos_z);
    printf("Planet 2 is at (%.2f, %.2f, %.2f)\n", p2.pos_x, p2.pos_y, p2.pos_z);
    printf("This force has magnitude %.2fN\n", f.magnitude);
    printf("This force is in direction (%.2f, %.2f, %.2f)\n", f.dir_x, f.dir_y, f.dir_z);
    printf("Neg force has magnitude %.2fN\n", n.magnitude);
    printf("Neg force is in direction (%.2f, %.2f, %.2f)\n", n.dir_x, n.dir_y, n.dir_z);
    
    printf("===== Begin Simulation =====\n");
    for(int i = 0; i < SIM_FPS * SIM_TIME; i++){
        #if CPP_COMPILE == 1
        gif.newFrame();
        #endif

        clear_acceleration(&p1);
        clear_acceleration(&p2);
        clear_acceleration(&p3);
        clear_acceleration(&p4);

        force f = get_force_between_planets(p1, p2);
        force n = negative_force(f);
        apply_force_to_planet(f, &p1);
        apply_force_to_planet(n, &p2);
        f = get_force_between_planets(p1, p3);
        n = negative_force(f);
        apply_force_to_planet(f, &p1);
        apply_force_to_planet(n, &p3);
        f = get_force_between_planets(p1, p4);
        n = negative_force(f);
        apply_force_to_planet(f, &p1);
        apply_force_to_planet(n, &p4);
        f = get_force_between_planets(p2, p3);
        n = negative_force(f);
        apply_force_to_planet(f, &p2);
        apply_force_to_planet(n, &p3);
        f = get_force_between_planets(p2, p4);
        n = negative_force(f);
        apply_force_to_planet(f, &p2);
        apply_force_to_planet(n, &p4);
        f = get_force_between_planets(p3, p4);
        n = negative_force(f);
        apply_force_to_planet(f, &p3);
        apply_force_to_planet(n, &p4);

        timestep(&p1);
        timestep(&p2);
        timestep(&p3);
        timestep(&p4);
        printf("After timestep %d, planet 1 is at (%.2f, %.2f, %.2f)\n", i, p1.pos_x, p1.pos_y, p1.pos_z);

        #if CPP_COMPILE == 1
        gif.drawLargePixel((int)(p1.pos_x * 100), (int)(p1.pos_y * 100));
        gif.drawLargePixel((int)(p2.pos_x * 100), (int)(p2.pos_y * 100));
        gif.drawLargePixel((int)(p3.pos_x * 100), (int)(p3.pos_y * 100));
        gif.drawLargePixel((int)(p4.pos_x * 100), (int)(p4.pos_y * 100));

        gif.addFrame();
        #endif
    }
    #if CPP_COMPILE == 1
    char fp[20] = "sample.gif";
    gif.output(fp);
    #endif
    #if CPP_COMPILE == 0
    /*if( p1.pos_x <= 1 && p1.pos_y <= 1 &&
        p2.pos_x <= 1 && p2.pos_y <= 1 &&
        p3.pos_x <= 1 && p3.pos_y <= 1 &&
        p4.pos_x <= 1 && p4.pos_y <= 1)
        printf("mass %.2f, pos %.2f and vel %.2f works\n", 1+(float)k/100, -1.0+(float)l/100, 1+(float)j/100);
    }
    }
    }*/
    #endif
}

/* 
 *  software_simulation()
 *
 *  This function handles the entirety of the software simulation.
 */
void software_simulation(){

    // for this simulation we need G to be equal to 4
    planet p1 = { 1.0, 1.0, 
                1.0, 0.0, 0.0, 
                0.0, 1.0, 0.0, 
                0.0, 0.0, 1.0 };
    planet p2 = { 1.0, 1.5,
                -1.0, 0.0, 0.0, 
                0.0, -1.0, 0.0, 
                0.0, 0.0, -1.0 };
    
    for(int i = 0; i < SIM_TIME * SIM_FPS; i++){

        // wait until the state machine wants to continue
//        while(MEM_PTR[15] == 0);

        // send the data through the memory pointer
        
    	// body 1
        MEM_PTR[0] = (int)(10 * p1.rad);
        MEM_PTR[1] = (int)(320 + 100 * p1.pos_x);
        MEM_PTR[2] = (int)(240 + 100 * p1.pos_y);
        MEM_PTR[3] = (int)(p1.pos_z);
        
        // body 2
        MEM_PTR[4] = (int)(10 * p2.rad);
		MEM_PTR[5] = (int)(320 + 100 * p2.pos_x);
		MEM_PTR[6] = (int)(240 + 100 * p2.pos_y);
		MEM_PTR[7] = (int)(p2.pos_z);

        clear_acceleration(&p1);
        clear_acceleration(&p2);
        
        force f = get_force_between_planets(p1, p2);
        force n = negative_force(f);
        apply_force_to_planet(f, &p1);
        apply_force_to_planet(n, &p2);

        timestep(&p1);
        timestep(&p2);

        printf("After timestep %d, planet 1 is at (%.2f, %.2f, %.2f)\n", i, p1.pos_x, p1.pos_y, p1.pos_z);
    }
}

/* 
 *  hardware_simulation()
 *
 *  This function handles the entirety of the hardware simulation.
 */
void hardware_simulation(){
    // TODO
}

