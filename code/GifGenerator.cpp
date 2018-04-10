/*
 *  A wrapper for easier generation of gifs
 */

#include <cmath>
#include <string>
#include "GifGenerator.h"
#include "PNG/rgbapixel.h"
#include "PNG/png.h"
#include "PNG/animation.h"

GifGenerator::GifGenerator(){

    width = 1;
    height = 1;
    currFrame = new PNG(1 ,1);
}

GifGenerator::GifGenerator(int w, int h){

    width = w;
    height = h;
    currFrame = new PNG(width, height);
}

void GifGenerator::init(int w, int h){

    width = w;
    height = h;
}

void GifGenerator::newFrame(){

    if(currFrame != NULL){
        delete currFrame;
    }
    currFrame = new PNG(width, height);
}

void GifGenerator::drawPixel(int x, int y){

    if(currFrame == NULL) return;
    if(abs(x) >= width / 2) return;
    if(abs(y) >= height / 2) return;

    RGBAPixel *p = (*currFrame)(x + width / 2, -y + height / 2);
    p->red = 0;
    p->green = 0;
    p->blue = 0;
}

void GifGenerator::drawLargePixel(int x, int y){

    int radius = 5;
    for(int i = -radius; i <= radius; i++){
        for(int j = -radius; j <= radius; j++){
            drawPixel(x + i, y + j);
        }
    }
}

void GifGenerator::addFrame(){

    ani.addFrame(*currFrame);
}

void GifGenerator::output(char* fp){

    std::string fp_string(fp);
    ani.write(fp_string);
}

