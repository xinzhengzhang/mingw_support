#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
    std::cout << "Hello from MinGW cross-compilation!" << std::endl;
    
    #ifdef __MINGW32__
    std::cout << "✓ Built with MinGW toolchain" << std::endl;
    
    #ifdef _WIN64
    std::cout << "✓ Target architecture: x86_64 (64-bit)" << std::endl;
    #else
    std::cout << "✓ Target architecture: i686 (32-bit)" << std::endl;
    #endif
    
    std::cout << "✓ Compiler: " << __VERSION__ << std::endl;
    
    #else
    std::cout << "Built with default toolchain" << std::endl;
    #endif
    
    if (argc > 1) {
        std::cout << "Arguments provided: ";
        for (int i = 1; i < argc; i++) {
            std::cout << argv[i] << " ";
        }
        std::cout << std::endl;
    }
    
    return 0;
}