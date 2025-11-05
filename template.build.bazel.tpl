load("@@{repository_name}//toolchains:toolchain_config.bzl", "llvm_mingw_cc_toolchain_config")

variants = ["i686", "x86_64"]

# Basic filegroups
filegroup(
    name = "all_files",
    srcs = glob(["toolchain/**"]),
    visibility = ["//visibility:public"],
)

[
    filegroup(
        name = "compiler_files_%s" % arch,
        srcs = glob([
            "toolchain/bin/%s-w64-mingw32-clang{executable_extension}" % arch,
            "toolchain/bin/%s-w64-mingw32-clang++{executable_extension}" % arch,
            "toolchain/bin/clang*{executable_extension}",
            "toolchain/bin/lib*.dll",
            "toolchain/lib/lib*.so*",
            "toolchain/lib/lib*.dylib*",
            "toolchain/%s-w64-mingw32/include/**" % arch,
            "toolchain/lib/clang/21/include/**",
            "toolchain/include/**",
        ]),
        visibility = ["//visibility:public"],
    )
for arch in variants]

filegroup(
    name = "runtime_lib",
    srcs = glob([
        "toolchain/lib/**/libc++*.a",
        "toolchain/lib/**/libunwind*.a",
        "toolchain/*/lib/lib*.a",
        "toolchain/*/lib/lib*.dll",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "bin",
    srcs = glob(["toolchain/bin/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "include",
    srcs = glob(["toolchain/**/include/**", "include/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "lib",
    srcs = glob(["toolchain/lib/**", "lib/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ar_files",
    srcs = glob([
        "toolchain/bin/*-w64-mingw32-ar{executable_extension}",
        "toolchain/bin/*-w64-mingw32-llvm-ar{executable_extension}",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "linker_files",
    srcs = glob([
        "toolchain/bin/*-w64-mingw32-ld",
        "toolchain/bin/*-w64-mingw32-clang{executable_extension}",
        "toolchain/bin/*-w64-mingw32-clang++{executable_extension}",
        "toolchain/bin/lld",
        "toolchain/bin/ld.lld{executable_extension}",
        "toolchain/bin/lib*.dll",
        "toolchain/lib/lib*.so*",
        "toolchain/lib/lib*.dylib*",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "objcopy_files",
    srcs = glob([
        "toolchain/bin/*-w64-mingw32-objcopy{executable_extension}",
        "toolchain/bin/*-w64-mingw32-objdump",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "strip_files",
    srcs = glob(["toolchain/bin/*-w64-mingw32-strip{executable_extension}"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "empty",
    srcs = [],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "toolchain_marker",
    srcs = glob(["toolchain/**"]),
    visibility = ["//visibility:public"],
)


[ 
    llvm_mingw_cc_toolchain_config(
        name = arch + "_mingw_cc_toolchain_config",
        target_arch = arch,
        executable_extension = "{executable_extension}",
    )
for arch in variants]

[
    cc_toolchain(
        name = arch + "_mingw_cc_toolchain",
        all_files = "//:all_files",
        ar_files = "//:ar_files",
        compiler_files = "//:compiler_files_%s" % arch,
        dwp_files = "//:empty",
        linker_files = "//:linker_files",
        objcopy_files = "//:objcopy_files",
        strip_files = "//:strip_files",
        dynamic_runtime_lib = "//:runtime_lib",
        static_runtime_lib = "//:runtime_lib",
        supports_param_files = True,
        toolchain_config = ":" + arch + "_mingw_cc_toolchain_config",
        toolchain_identifier = "llvm-mingw-" + arch,
    )
for arch in variants]

[
    toolchain(
        name = arch + "_mingw_toolchain",
        exec_compatible_with = [{host_platform}] + [{host_cpu}],
        target_compatible_with = [
            "@platforms//cpu:" + ('x86_32' if arch == 'i686' else arch),
            "@platforms//os:windows",
        ],
        toolchain = ":" + arch + "_mingw_cc_toolchain",
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )
for arch in variants]