#include <math.h> // needed for fabs
#include <stdint.h> // needed for uint_32
#include "physics.h"

/*
 *  timestep(planet &p)
 *
 *  Apply a timestep to the planet.
 *  This involves calculating the new velocity given the acceleration,
 *      as well as the new position, given the velocity.
 */
void timestep(planet *p){

    p->vel_x += p->acc_x * DT;
    p->vel_y += p->acc_y * DT;
    p->vel_z += p->acc_z * DT;
    p->pos_x += p->vel_x * DT;
    p->pos_y += p->vel_y * DT;
    p->pos_z += p->vel_z * DT;
}

/*
 *  apply_force_to_planet(force f, planet *p)
 *
 *  Apply the force to the planet by adjusting
 *      the acceleration depending on its mass.
 */
void apply_force_to_planet(force f, planet *p){

    p->acc_x += f.magnitude * f.dir_x / p->mass;
    p->acc_y += f.magnitude * f.dir_y / p->mass;
    p->acc_z += f.magnitude * f.dir_z / p->mass;
}

/*
 *  clear_acceleration(planet *p)
 *
 *  Clears the acceleration to begin a new round
 *      of force addition.
 */
void clear_acceleration(planet *p){

    p->acc_x = 0;
    p->acc_y = 0;
    p->acc_z = 0;
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

    // prevent div by 0
    if(rel_pos_squared < 0.01) rel_pos_squared = 0.01;
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

    // prevent div by 0
    if(rel_pos_squared < 0.01) rel_pos_squared = 0.01;
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
float fast_invsqrt(float n){

    union {
        float f;
        uint32_t i;
    } conv;

    float x2;
    x2 = n * 0.5f;
    conv.f = n;
    conv.i = QUAKE_MAGIC - (conv.i >> 1);                       // magic hack
    conv.f = conv.f * (THREE_HALFS - (x2 * conv.f * conv.f));   // Newton method iteration one
    return conv.f;
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
float fast_invsqrt_2(float n){
    union {
        float f;
        uint32_t i;
    } conv;

    float x2;
    x2 = n * 0.5f;
    conv.f = n;
    conv.i = QUAKE_MAGIC - (conv.i >> 1);                       // magic hack
    conv.f = conv.f * (THREE_HALFS - (x2 * conv.f * conv.f));   // Newton method iteration one
    conv.f = conv.f * (THREE_HALFS - (x2 * conv.f * conv.f));   // Newton method iteration two
    return conv.f;

}
