load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "artifact_name_pattern",
    "tool_path",
    "feature",
    "flag_group", 
    "flag_set",
    "with_feature_set",
)

def _impl(ctx):
    target_arch = ctx.attr.target_arch
    toolchain_path = "toolchain"
    
    tool_paths = [
        tool_path(
            name = "ar",
            path = toolchain_path + "/bin/" + target_arch + "-w64-mingw32-ar" + ctx.attr.executable_extension,
        ),
        tool_path(
            name = "cpp",
            path = toolchain_path + "/bin/" + target_arch + "-w64-mingw32-clang++" + ctx.attr.executable_extension,
        ),
        tool_path(
            name = "gcc",
            path = toolchain_path + "/bin/" + target_arch + "-w64-mingw32-clang" + ctx.attr.executable_extension,
        ),
        tool_path(
            name = "gcov",
            path = toolchain_path + "/bin/false",  # Not available in this toolchain
        ),
        tool_path(
            name = "ld",
            path = toolchain_path + "/bin/" + target_arch + "-w64-mingw32-ld" + ctx.attr.executable_extension,
        ),
        tool_path(
            name = "nm",
            path = toolchain_path + "/bin/" + target_arch + "-w64-mingw32-nm" + ctx.attr.executable_extension,
        ),
        tool_path(
            name = "objdump",
            path = toolchain_path + "/bin/" + target_arch + "-w64-mingw32-objdump" + ctx.attr.executable_extension,
        ),
        tool_path(
            name = "strip",
            path = toolchain_path + "/bin/" + target_arch + "-w64-mingw32-strip" + ctx.attr.executable_extension,
        ),
    ]



    artifact_name_patterns = [
        artifact_name_pattern(
            category_name = "executable",
            prefix = "",
            extension = ".exe",
        ),
        artifact_name_pattern(
            category_name = "static_library",
            prefix = "lib",
            extension = ".a",
        ),
        artifact_name_pattern(
            category_name = "dynamic_library",
            prefix = "",
            extension = ".dll",
        ),
    ]

    # Define features for cross-compilation
    features = [
        feature(
            name = "default_compile_flags",
            enabled = True,
            flag_sets = [
                # Compile, Link, and CC_FLAGS make variable
                flag_set(
                    actions = [
                        "c-compile",
                        "c++-compile",
                        "c++-header-parsing",
                        "c++-header-preprocessing",
                        "c++-module-compile",
                        "c++-module-codegen",
                        "lto-backend",
                        "preprocess-assemble",
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-no-canonical-prefixes",
                                "-target", target_arch + "-w64-mingw32",
                                "-D__MINGW32__",
                                "-D_WIN32",
                                "-D_WIN64" if target_arch == "x86_64" else "-D_WIN32",
                            ],
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "default_link_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = ["c++-link-executable", "c++-link-dynamic-library"],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-target", target_arch + "-w64-mingw32",
                                "-lc++",
                                "-lc++abi",
                                "-lunwind",
                            ],
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "supports_pic",
            enabled = True,
        ),
        feature(
            name = "supports_dynamic_linker",
            enabled = True,
        ),
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "llvm-mingw-" + target_arch,
        host_system_name = "darwin",
        target_system_name = "mingw",
        target_cpu = target_arch,
        target_libc = "mingw",
        cc_target_os = "windows",
        compiler = "clang",
        abi_version = "llvm",
        abi_libc_version = "mingw",
        tool_paths = tool_paths,
        cxx_builtin_include_directories = [
            "%s/%s-w64-mingw32/include" % (toolchain_path, target_arch),
            "%s/%s-w64-mingw32/include/c++/v1" % (toolchain_path, target_arch),
            "%s/lib/clang/21/include" % toolchain_path,
            "%s/include" % toolchain_path,
        ],
        artifact_name_patterns = artifact_name_patterns,
        features = features,
    )

llvm_mingw_cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "target_arch": attr.string(mandatory = True),
        # A label pointing inside the external repo that contains the
        # prebuilt toolchain. The attribute should be of type label or
        # label_list pointing to a file/filegroup created in the external
        # repository's BUILD file (see suggested WORKSPACE snippet).
        "executable_extension": attr.string(default = ""),
    },
    provides = [CcToolchainConfigInfo],
)