// import C++ header files
#include <iostream>

// import user-defined CUDA header files
#include "include/kernel.cuh"


int main(void) {
    int* a = new int {1};
    int* b = new int {2};
    int* c = new int;

    my_add(a, b, c);

    std::cout << "C = A + B = " << *a << " + " << *b << " = " << *c << std::endl;

    delete a;
    delete b;
    delete c;

    return 0;
}
