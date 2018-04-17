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
#define SIM_MODE 0
#define SIM_TIME 20 // (seconds)

void unit_test();
void quake_test();
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
    //quake_test();
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

    planet_node* head = NULL;
    head = append_planet_node(head, &p1);
    head = append_planet_node(head, &p2);
    head = append_planet_node(head, &p3);
    head = append_planet_node(head, &p4);

    printf("===== Begin Simulation =====\n");
    for(int i = 0; i < SIM_TIME * SIM_FPS; i++){
        #if CPP_COMPILE == 1
        gif.newFrame();
        #endif

        planet_node* curr;
        
        curr = head;
        while(curr != NULL){
            clear_acceleration(curr->data);
            curr = curr->next;
        }

        curr = head;
        planet_node* neighbor = NULL;

        while(curr != NULL){
            neighbor = curr->next;
            while(neighbor != NULL){
                force f = get_force_between_planets_fast(*(curr->data), *(neighbor->data));
                force n = negative_force(f);
                apply_force_to_planet(f, curr->data);
                apply_force_to_planet(n, neighbor->data);
                neighbor = neighbor->next;
            }
            curr = curr->next;
        }
        
        curr = head;
        while(curr != NULL){
            timestep(curr->data);
            curr = curr->next;
        }
        //printf("After timestep %d, planet 1 is at (%.2f, %.2f, %.2f)\n", i, p1.pos_x, p1.pos_y, p1.pos_z);

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
 *  quake_test()
 *
 *  test the accuracy of the quake magic for inv_sqrt
 */
void quake_test(){

    printf("Number --- actual_invsqrt --- fast_invsqrt --- accuracy\n");

    for(int i = 0; i < 100; i++){
        float number = (i + 1) / 100.0;
        float actual = 1.0 / sqrt(number);
        float fast = fast_invsqrt(number);
        printf("%.6f ---    %.6f      ---    %.6f    ---    %.6f\n",
        number, actual, fast, 1 - fabs(actual - fast) / actual);
    }
    for(int i = 0; i < 10; i++){
        float number = 10.0 * (i + 1);
        float actual = 1.0 / sqrt(number);
        float fast = fast_invsqrt(number);
        printf("%.6f ---    %.6f      ---    %.6f    ---    %.6f\n",
        number, actual, fast, 1 - fabs(actual - fast) / actual);
    }
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
    planet p2 = { 1.0, 1.0, 
                -1.0, 0.0, 0.0, 
                0.0, -1.0, 0.0, 
                0.0, 0.0, -1.0 };
    
    for(int i = 0; i < SIM_TIME * SIM_FPS; i++){

        // wait until the state machine wants to continue
        //while(MEM_PTR[15] == 0);

        // send the data through the memory pointer
        /*
        MEM_PTR[0] = p1.rad;
        MEM_PTR[1] = p1.pos_x;
        MEM_PTR[2] = p1.pos_y;
        MEM_PTR[3] = p1.pos_z;
        */

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

