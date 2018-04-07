#ifndef _PHYSICS_H
#define _PHYSICS_H

// constants
#define G 6.673E-11

/*
 * Force struct
 */
typedef struct
{
    float magnitude;
    float dir_x, dir_y, dir_z;
} force;

/*
 * Planet struct
 */
typedef struct
{
    float mass, rad;
    float pos_x, pos_y, pos_z;
    float vel_x, vel_y, vel_z;
    float acc_x, acc_y, acc_z;
} planet;

#endif
