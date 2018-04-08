#include <math.h> // needed for fabs
#include "physics.h"

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
