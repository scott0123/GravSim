default:
	clang main.c physics.c -o test
#clean:
#	-rm -f *.o

EXENAME = testcpp
OBJS = main.o physics.o png.o rgbapixel.o animation.o GifGenerator.o

CXX = clang++
CXXFLAGS = -std=c++1y -stdlib=libc++ -c -g -O0 -Wall -Wextra -pedantic
LD = clang++
LDFLAGS = -std=c++1y -stdlib=libc++ -lpng -lc++abi -lpthread

cpp : $(EXENAME)

$(EXENAME) : $(OBJS)
	$(LD) $(OBJS) $(LDFLAGS) -o $(EXENAME)

main.o : PNG/png.h PNG/rgbapixel.h PNG/rgbapixel.h
	$(CXX) $(CXXFLAGS) main.c

physics.o : physics.h
	$(CXX) $(CXXFLAGS) physics.c

png.o : PNG/png.h PNG/rgbapixel.h
	$(CXX) $(CXXFLAGS) PNG/png.cpp

rgbapixel.o : PNG/rgbapixel.h
	$(CXX) $(CXXFLAGS) PNG/rgbapixel.cpp

animation.o : PNG/animation.h PNG/rgbapixel.h PNG/png.h PNG/animation.h
	$(CXX) $(CXXFLAGS) PNG/animation.cpp

GifGenerator.o : GifGenerator.h PNG/animation.h PNG/rgbapixel.h PNG/png.h PNG/animation.h
	$(CXX) $(CXXFLAGS) GifGenerator.cpp

clean :
	-rm -f *.o $(EXENAME)
