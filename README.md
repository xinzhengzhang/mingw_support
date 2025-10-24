# MinGW Cross-Compilation Toolchain for Bazel

This project provides a comprehensive Bazel toolchain for cross-compiling C/C++ code to Windows using the LLVM MinGW toolchain. It supports building from macOS and Linux hosts.

## Features

- **Cross-platform compilation**: Build Windows executables from macOS and Linux
- **Multiple architectures**: Support for x86_64 and i686 Windows targets  
- **Hermetic toolchain**: Self-contained toolchain for reproducible builds
- **Modern toolchain**: Uses Clang/LLVM with MinGW-w64 runtime
- **Bazel integration**: Full integration with Bazel's modern toolchain system

## Quick Start

### Prerequisites

- Bazel 6.0 or later
- Host system: macOS or Linux

### Building Examples

```bash
# Build the hello world example for x86_64 Windows
bazel build //examples:hello --config=x86_64_windows

# Build for i686 Windows
bazel build //examples:hello --config=i686_windows

# Build the advanced example
bazel build //examples:example --config=x86_64_windows
```

### Testing the Output

```bash
# Examine the built executable
file bazel-bin/examples/hello.exe

# Output: bazel-bin/examples/hello.exe: PE32+ executable (console) x86-64, for MS Windows
```

## Examples

The project includes example programs in the `examples/` directory:

- **hello.cpp** - Basic hello world program demonstrating MinGW detection
- **example.cpp** - More comprehensive example showing platform-specific features

## Configuration Options

The toolchain provides build configurations defined in `.bazelrc`:

- `--config=x86_64_windows` - Build for 64-bit Windows (Intel/AMD)
- `--config=i686_windows` - Build for 32-bit Windows

## Project Structure

```
├── BUILD.bazel                 # Root build file
├── MODULE.bazel                # Bazel module definition  
├── WORKSPACE                   # Legacy workspace file
├── .bazelrc                    # Build configurations
├── examples/
│   ├── BUILD.bazel            # Example programs
│   ├── hello.cpp              # Simple hello world
│   └── example.cpp            # Advanced example
├── extensions/
│   ├── BUILD.bazel            # Extension definitions
│   └── toolchain_extension.bzl # Toolchain module extension
├── platforms/
│   └── BUILD.bazel            # Target platform definitions
├── toolchains/
│   ├── BUILD.bazel            # Toolchain configurations
│   └── toolchain_config.bzl   # Toolchain implementation
├── rules.bzl                   # Custom Bazel rules
└── template.build.bazel.tpl   # Build template
```

## Toolchain Details

- **Compiler**: LLVM Clang
- **Linker**: LLD
- **Target**: Windows (MinGW-w64)
- **Host**: macOS, Linux
- **Architectures**: x86_64, i686
- **Standard Library**: MinGW-w64 runtime + libc++

### ⚠️ Warning

Due to the complexity of Bazel's C toolchain feature system, the current implementation is referenced from [bazelbuild/rules_android_ndk](https://github.com/bazelbuild/rules_android_ndk). Not all features have been individually verified for reliability. Use with caution in production environments and please report any issues you encounter.

## Advanced Usage

### Custom Build Rules

Use the toolchain with standard Bazel C++ rules:

```bazel
cc_binary(
    name = "my_app",
    srcs = ["main.cpp"],
    linkopts = ["-static"],  # Create static executable
)

cc_library(
    name = "my_lib",
    srcs = ["lib.cpp"], 
    hdrs = ["lib.h"],
)
```

### Platform Detection

The toolchain defines standard MinGW macros for platform-specific code:

```cpp
#ifdef __MINGW32__
    // MinGW-specific code
    #ifdef _WIN64
        // 64-bit Windows code
    #else
        // 32-bit Windows code
    #endif
#endif
```

## Extending the Toolchain

### Adding New Architectures

To support additional target architectures:

1. Add new platform definitions in `platforms/BUILD.bazel`
2. Add corresponding toolchain configurations in `toolchains/BUILD.bazel`  
3. Add build configs in `.bazelrc`

### Adding Host Support

The toolchain already supports both macOS and Linux hosts through the module extension system in `extensions/toolchain_extension.bzl`.

## Integration with Existing Projects

To use this toolchain in your own Bazel project:

1. Add this repository as a dependency in your `MODULE.bazel`
2. Register the toolchain extension
3. Use the provided build configurations

## Contributing

When contributing to this project:

1. Test changes with the provided examples
2. Ensure compatibility with both macOS and Linux hosts
3. Verify support for both x86_64 and i686 targets
4. Update documentation for new features

## License

This project provides Bazel integration for MinGW toolchain. The underlying MinGW-w64 and LLVM components are distributed under their respective licenses.
