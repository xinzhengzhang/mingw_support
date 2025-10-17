"""Bazelmod extension for registering MinGW toolchains."""

load("//:rules.bzl", "mingw_tool_repository")

def _toolchain_extension_impl(module_ctx):
    """Register all MinGW toolchains."""

    arch = module_ctx.os.arch
    os_name = module_ctx.os.name.lower()

    # MacOS: darwin, mac os x, macos
    if "darwin" in os_name or "mac" in os_name:
        toolchain_url = "https://github.com/mstorsjo/llvm-mingw/releases/download/20251007/llvm-mingw-20251007-ucrt-macos-universal.tar.xz"
        toolchain_strip_prefix = "llvm-mingw-20251007-ucrt-macos-universal"
        host_platform = ["@platforms//os:macos"]
        host_cpu = []
    # Windows
    elif "windows" in os_name:
        if arch == "amd64" or arch == "x86_64":
            toolchain_url = "https://github.com/mstorsjo/llvm-mingw/releases/download/20251007/llvm-mingw-20251007-ucrt-x86_64.zip"
            toolchain_strip_prefix = "llvm-mingw-20251007-ucrt-x86_64"
            host_platform = ["@platforms//os:windows"]
            host_cpu = ["@platforms//cpu:x86_64"]
        elif arch == "aarch64":
            toolchain_url = "https://github.com/mstorsjo/llvm-mingw/releases/download/20251007/llvm-mingw-20251007-ucrt-aarch64.zip"
            toolchain_strip_prefix = "llvm-mingw-20251007-ucrt-aarch64"
            host_platform = ["@platforms//os:windows"]
            host_cpu = ["@platforms//cpu:aarch64"]
        else:
            #FIXME Not tested
            toolchain_url = "https://github.com/mstorsjo/llvm-mingw/releases/download/20251007/llvm-mingw-20251007-ucrt-i686.zip"
            toolchain_strip_prefix = "llvm-mingw-20251007-ucrt-i686"
            host_platform = ["@platforms//os:windows"]
            host_cpu = ["@platforms//cpu:x86_32"]
    # Linux
    elif "linux" in os_name:
        if arch == "amd64" or arch == "x86_64":
            toolchain_url = "https://github.com/mstorsjo/llvm-mingw/releases/download/20251007/llvm-mingw-20251007-ucrt-ubuntu-22.04-x86_64.tar.xz"
            toolchain_strip_prefix = "llvm-mingw-20251007-ucrt-ubuntu-22.04-x86_64"
            host_platform = ["@platforms//os:linux"]
            host_cpu = ["@platforms//cpu:x86_64"]
        elif arch == "aarch64":
            toolchain_url = "https://github.com/mstorsjo/llvm-mingw/releases/download/20251007/llvm-mingw-20251007-ucrt-ubuntu-22.04-aarch64.tar.xz"
            toolchain_strip_prefix = "llvm-mingw-20251007-ucrt-ubuntu-22.04-aarch64"
            host_platform = ["@platforms//os:linux"]
            host_cpu = ["@platforms//cpu:aarch64"]
        else:
            fail("Unsupported host platform for MinGW toolchain: " + module_ctx.os.name + "_" + arch)
    else:
        fail("Unsupported host platform for MinGW toolchain: " + module_ctx.os.name + "_" + arch)

    mingw_tool_repository(
        name = "llvm_mingw",
        toolchain_url = toolchain_url,
        toolchain_strip_prefix = toolchain_strip_prefix,
        host_platform = host_platform,
        host_cpu = host_cpu,
    )


mingw_toolchain_extension = module_extension(
    implementation = _toolchain_extension_impl,
)