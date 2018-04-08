#ifndef _PHYSICS_H
#define _PHYSICS_H

// universal constants
#define G 6.673E-11

// standard constants
#define THREE_HALFS 1.5f
#define DT 0.01667f // for 60 fps

// magic numbers
#define QUAKE_MAGIC 0x5f3759df

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
