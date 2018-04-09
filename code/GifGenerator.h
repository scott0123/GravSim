#include "../../../PNG/png.h"
#include "../../../PNG/animation.h"

class GifGenerator {

    public:
        GifGenerator();
        GifGenerator(int w, int h);
        void init(int w, int h);
        void newFrame();
        void drawPixel(int x, int y);
        void addFrame();
        void output(char* fp);
    private:
        int width;
        int height;
        PNG* currFrame;
        animation ani;
};
