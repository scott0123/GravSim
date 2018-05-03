

// 1 heavy mass in center, 1 fast, large orbit, 2 small orbits (system moving down right)

    // set G
    float G_const = 1.0f;
    planet p1 = { 100.0, 1.0,
//                        1.0, 0.0, 0.0,
        1.0, -1.0, 1.0,
//                          0.0, 1.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0 };
    planet p2 = { 1.0, 1.0,
        -1.0, 0.0, 0.0,
        0.0, -1.0, 0.0,
        0.0, 0.0, -1.0 };
    planet p3 = { 1.0, 1.0,
//        0.0, 1.0 + ((rand() % 500) / 1000.0) - 0.25, 0.0,
    		0.0, 1.0, 0.0,
        -1.0, 0.0, 0.0,
        0.0, 0.0, -1.0 };
    planet p4 = { 0.92, 1.0,
        //                    0.0, -0.98, 0.0,
        0.0, -1.07, 0.0,
        //                    1.04, 0.0, 0.0,
        0.97, 0.0, 0.0,
        0.0, 0.0, -1.0 };
    



// large central mass
    // set G
    float G_const = 1.0f;
    // for this simulation we need G to be equal to 4
    planet p1 = { 100.0, 1.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0 };
    planet p2 = { 0.1, 1.0,
        -1.0, 0.0, 0.0,
        0.0, -10.0, 0.0,
        0.0, 0.0, 0.0 };
    planet p3 = { 0.1, 1.0,
//        0.0, 1.0 + ((rand() % 500) / 1000.0) - 0.25, 0.0,
        0.0, 1.0, 0.0,
        -10.0, 0.0, 0.0,
        0.0, 0.0, 0.0 };
    planet p4 = { 0.1, 1.0,
        0.0, -1.07, 0.0,
        0.97, 0.0, 0.0,
        0.0, 0.0, -0.0 };

// slow binary star system with very fast large orbit comets
 // for this simulation we need G to be equal to 4
    planet p1 = { 2.0, 1.0,
        0.8, 0.0, 0.0,
        0.0, 0.5, 0.0,
        0.0, 0.0, 0.0 };
    planet p2 = { 2.0, 1.0,
        0.3, 0.0, 0.0,
        0.0, -0.5, 0.0,
        0.0, 0.0, 0.0 };
    planet p3 = { 1, 1.0,
//        0.0, 1.0 + ((rand() % 500) / 1000.0) - 0.25, 0.0,
        -1.0, -1.0, -10.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 0.0 };
    planet p4 = { 0, 1.0,
        10.0, 1.0, -100.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0 };
    
    // set G
    float G_const = 20.0f;

    // secondary
        // slow binary star system with very fast large orbit comets
     // for this simulation we need G to be equal to 4
        planet p1 = { 2.0, 1.0,
            -0.8, 0.0, 0.0,
            0.0, 0.5, 0.0,
            0.0, 0.0, 0.0 };
        planet p2 = { 2.0, 1.0,
            0.3, 0.0, 0.0,
            0.0, -0.5, 0.0,
            0.0, 0.0, 0.0 };
        planet p3 = { 1, 1.0,
    //        0.0, 1.0 + ((rand() % 500) / 1000.0) - 0.25, 0.0,
            -1.0, -1.0, -10.0,
            0.0, 1.0, 0.0,
            0.0, 0.0, 0.0 };
        planet p4 = { 0, 1.0,
            10.0, 1.0, -100.0,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0 };

        // set G
        float G_const = 20.0f;