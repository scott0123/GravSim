#ifndef _PHYSICS_H
#define _PHYSICS_H

// universal constants
//#define G 6.673E-11
#define G 4 // unit tests are mostly built around this
//#define G 4 // this is good for 2 planet orbit

// standard constants
#define THREE_HALFS 1.5f
#define DT 0.01667f // for 60 fps
//#define DT 0.03333f // for 30 fps
#define SIM_FPS 60

// magic numbers
#define QUAKE_MAGIC 0x5f3759df

/*
 *  Force struct
 */
typedef struct
{
    float magnitude;
    float dir_x, dir_y, dir_z;
} force;

/*
 *  Planet struct
 */
typedef struct
{
    float mass, rad;
    float pos_x, pos_y, pos_z;
    float vel_x, vel_y, vel_z;
    float acc_x, acc_y, acc_z;
} planet;

/*
 *  Planet node struct (singly linked)
 */
struct planet_node_t
{
    planet* data;
    struct planet_node_t* next;
};
typedef struct planet_node_t planet_node;

// functions
void timestep(planet *p);
void apply_force_to_planet(force f, planet *p);
void clear_acceleration(planet *p);
force get_force_between_planets(planet a, planet b);
force get_force_between_planets_fast(planet a, planet b);
force negative_force(force f);
float fast_invsqrt(float f);
float fast_invsqrt_2(float f);

planet_node* append_planet_node(planet_node* head, planet* p);

#endif
