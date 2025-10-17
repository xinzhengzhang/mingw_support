#include <iostream>

int main() {
    #ifdef __MINGW32__
    std::cout << "Hello from MinGW on Windows!" << std::endl;
    #ifdef _WIN64
    std::cout << "Built for x86_64 architecture" << std::endl;
    #else
    std::cout << "Built for i686 architecture" << std::endl;
    #endif
    #else
    std::cout << "Built with default toolchain" << std::endl;
    #endif
    return 0;
}