load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "artifact_name_pattern",
    "tool",
    "tool_path",
    "feature",
    "feature_set",
    "flag_group", 
    "with_feature_set",
    "variable_with_value",
    flag_set_ = "flag_set",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", action = "ACTION_NAMES")

def _impl(ctx):
    target_arch = ctx.attr.target_arch
    toolchain_path = "toolchain"

    sdk_sysroot = "{}/{}-w64-mingw32".format(toolchain_path, target_arch)
    if "windows" in ctx.attr.host_os:
        sdk_sysroot = "{}/".format(toolchain_path)
    sdk_clang_resource_dir = "{}/lib/clang/21".format(toolchain_path)

    clang_sysroot = "{}/{}".format(ctx.label.workspace_root, sdk_sysroot)
    clang_resource_dir = "{}/{}".format(ctx.label.workspace_root, sdk_clang_resource_dir)

    actions = construct_actions_(action) 

    tools = {
        "clang": toolchain_path + "/bin/" + target_arch + "-w64-mingw32-clang" + ctx.attr.executable_extension,
        "ar": toolchain_path + "/bin/" + target_arch + "-w64-mingw32-ar" + ctx.attr.executable_extension,
        "cpp": toolchain_path + "/bin/" + target_arch + "-w64-mingw32-clang++" + ctx.attr.executable_extension,
        "dwp": toolchain_path + "/bin/false",  # Not available in this toolchain
        "gcc": toolchain_path + "/bin/" + target_arch + "-w64-mingw32-clang" + ctx.attr.executable_extension,
        "ld": toolchain_path + "/bin/" + target_arch + "-w64-mingw32-ld",
        "nm": toolchain_path + "/bin/" + target_arch + "-w64-mingw32-nm" + ctx.attr.executable_extension,
        "objcopy": toolchain_path + "/bin/" + target_arch + "-w64-mingw32-objcopy" + ctx.attr.executable_extension,
        "objdump": toolchain_path + "/bin/" + target_arch + "-w64-mingw32-objdump",
        "strip": toolchain_path + "/bin/" + target_arch + "-w64-mingw32-strip" + ctx.attr.executable_extension,
    }

    tool_of_tool_name = {
        tool_name: tool(path = path)
        for (tool_name, path) in tools.items()
    }

    tool_paths = [
        tool_path(
            name = tool_name,
            path = path,
        )
        for (tool_name, path) in tools.items()
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

    action_configs = [
        action_config(
            action_name = action.cpp_link_nodeps_dynamic_library,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.strip,
            enabled = True,
            flag_sets = [
                flag_set(
                    flags = ["--strip-unneeded"],
                    features = ["fully_strip"],
                ),
                flag_set(
                    flags = ["--strip-debug"],
                    not_features = ["fully_strip"],
                ),
            ],
            tools = [tool_of_tool_name["strip"]],
        ),
        action_config(
            action_name = action.cpp_link_dynamic_library,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.cc_flags_make_variable,
            enabled = True,
        ),
        action_config(
            action_name = action.assemble,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.preprocess_assemble,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.cpp_module_compile,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.c_compile,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.cpp_header_parsing,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.cpp_module_codegen,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.cpp_link_static_library,
            enabled = True,
            flag_sets = [
                flag_set(
                    flag_groups = [
                        flag_group(
                            flags = ["rcsD", "%{output_execpath}"],
                            expand_if_available = "output_execpath",
                        ),
                    ],
                ),
                flag_set(
                    flag_groups = [
                        flag_group(
                            iterate_over = "libraries_to_link",
                            flag_groups = [
                                flag_group(
                                    flags = ["%{libraries_to_link.name}"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "object_file",
                                    ),
                                ),
                                flag_group(
                                    flags = ["%{libraries_to_link.object_files}"],
                                    iterate_over = "libraries_to_link.object_files",
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "object_file_group",
                                    ),
                                ),
                            ],
                            expand_if_available = "libraries_to_link",
                        ),
                    ],
                ),
                flag_set(
                    flag_groups = [
                        flag_group(
                            flags = ["@%{linker_param_file}"],
                            expand_if_available = "linker_param_file",
                        ),
                    ],
                ),
            ],
            tools = [tool_of_tool_name["ar"]],
        ),
   
        action_config(
            action_name = action.cpp_compile,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.linkstamp_compile,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.clif_match,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.cpp_link_executable,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.lto_backend,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.lto_index_for_executable,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.lto_index_for_dynamic_library,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
        action_config(
            action_name = action.lto_index_for_nodeps_dynamic_library,
            enabled = True,
            tools = [tool_of_tool_name["clang"]],
        ),
    ]

    # Construct features.
    features = [
        # This set of magic "feature"s are important configuration information for bazel.
        feature(
            name = "no_legacy_features",
            enabled = True,
        ),
        feature(
            name = "has_configured_linker_path",
            enabled = True,
        ),

        # Blaze requests this feature by default, but we don't care.
        feature(name = "dependency_file"),

        # Blaze requests this feature by default, but we don't care.
        feature(name = "random_seed"),

        # Blaze requests this feature if fission is requested
        # Blaze tests if it's supported to see if we support fission.
        feature(name = "per_object_debug_info"),

        # Blaze tests if this feature is supported before setting preprocess_defines.
        feature(name = "preprocessor_defines"),

        # Blaze requests this feature by default.
        # Blaze tests if this feature is supported before setting includes.
        feature(name = "include_paths"),

        # Blaze tests if this feature is enabled in order to create implicit
        # "nodeps" .so outputs from cc_library rules.
        # Disabled for MinGW because Windows DLLs require all symbols to be resolved at link time
        feature(
            name = "supports_dynamic_linker",
            enabled = False,
        ),

        # Blaze requests this feature when linking a cc_binary which is
        # "dynamic" aka linked against nodeps-dynamic-library cc_library
        # outputs.
        feature(name = "dynamic_linking_mode"),
        feature(
            name = "static_link_cpp_runtimes",
            enabled = True,
        ),
        feature(
            name = "supports_start_end_lib",
            enabled = True,
        ),

        # This feature stanza is used by third_party/stl/BUILD to determine
        # which headers to include in the module.
        feature(
            name = "has_cxx17_headers",
            enabled = True,
        ),

        # This feature is used generically to determine which STL is enabled by
        # default. (e.g. for //tools/cpp:standard_library)
        feature(
            name = "has_libcxx",
            enabled = True,
        ),

        # This feature is needed to prevent name mangling during dynamic library links.
        feature(name = "copy_dynamic_libraries_to_binary"),

        #### Configuration features

        feature(
            name = "crosstool_cpu_arm",
            provides = ["variant:crosstool_cpu"],
        ),
        feature(
            name = "crosstool_cpu_arm64",
            provides = ["variant:crosstool_cpu"],
        ),
        feature(
            name = "crosstool_cpu_x86_64",
            provides = ["variant:crosstool_cpu"],
        ),
        feature(
            name = "do_not_split_linking_cmdline",
        ),
        feature(
            name = "crosstool_linker_gold",
            provides = ["variant:crosstool_linker"],
            enabled = False,
        ),
        feature(
            name = "crosstool_linker_lld",
            provides = ["variant:crosstool_linker"],
            enabled = True,
        ),
        feature(
            name = "proto_force_lite_runtime",
            implies = ["proto_disable_services"],
            enabled = True,
        ),
        feature(
            name = "proto_disable_services",
            enabled = True,
        ),
        feature(
            name = "proto_one_output_per_message",
            implies = ["proto_force_lite_runtime"],
            enabled = True,
            requires = [feature_set(features = ["opt"])],
        ),
        # Allows disabling nolegacy_whole_archive for individual targets. Automatically turned on
        # for cc_proto_library targets, but requires proto_one_output_per_message
        feature(
            name = "disable_whole_archive_for_static_lib",
            requires = [feature_set(features = ["proto_one_output_per_message"])],
        ),
        # These 3 features will be automatically enabled by bazel in the
        # corresponding build mode.
        feature(
            name = "opt",
            provides = ["variant:crosstool_build_mode"],
        ),
        feature(
            name = "dbg",
            provides = ["variant:crosstool_build_mode"],
        ),
        feature(
            name = "fastbuild",
            provides = ["variant:crosstool_build_mode"],
        ),
        # User-settable strip features
        feature(
            # --strip-all for .stripped binaries
            name = "fully_strip",  # --strip-all for strip=always
            enabled = True,
            requires = [feature_set(features = ["opt"])],  # Only fully strip in opt mode.
        ),
        feature(
            # --strip-all for --strip=always
            name = "linker_fully_strip",
            requires = [feature_set(features = ["opt"])],  # Only fully strip in opt mode.
        ),
        feature(name = "lto_unit"),

        # This reduces bitcode compatibility issues.
        feature(
            name = "no_use_lto_indexing_bitcode_file",
            enabled = True,
        ),
        feature(name = "warnings_as_errors"),

        # Configure the header parsing and preprocessing. Blaze will test to see if
        # the Crosstool supports it if the cc_toolchain specifies
        # supports_header_parsing = True.
        feature(name = "parse_headers"),

        # We have different features for module consumers and producers:
        # 'header_modules' is enabled for targets that support being compiled as a
        # header module.
        # 'use_header_modules' is enabled for targets that want to use the provided
        # header modules from their transitive closure. We enable this globally and
        # disable it for targets that do not support builds with header modules.
        feature(
            name = "header_modules",
            requires = [
                feature_set(features = ["use_header_modules"]),
            ],
            implies = [
                "header_module_compile",
            ],
        ),
        feature(
            name = "header_module_codegen",
            requires = [
                feature_set(features = ["header_modules"]),
            ],
        ),
        feature(
            name = "header_modules_codegen_functions",
            implies = ["header_module_codegen"],
        ),
        feature(
            name = "header_modules_codegen_debuginfo",
            implies = ["header_module_codegen"],
        ),
        feature(
            name = "header_module_compile",
        ),
        feature(
            name = "use_header_modules",
            implies = ["use_module_maps"],
        ),
        feature(
            name = "use_module_maps",
            requires = [feature_set(features = ["module_maps"])],
        ),
        feature(
            name = "module_maps",
            implies = [
                "module_map_home_cwd",
                "module_map_without_extern_module",
                "generate_submodules",
            ],
        ),
        feature(name = "module_map_home_cwd"),
        feature(name = "module_map_without_extern_module"),

        # Indicate that the crosstool supports submodules.
        feature(name = "generate_submodules"),

        # Configure the strict layering check.
        feature(
            name = "layering_check",
            implies = [
                "use_module_maps",
            ],
        ),

        # Disallow undefined symbols in final shared objects.
        feature(
            name = "no_undefined",
            enabled = True,
        ),

        # The following flag_set list defines the crucial set of flag_sets for primary
        # compilation and linking. Its order is incredibly important.
        feature(
            name = "crosstool_compiler_flags",
            enabled = True,
            flag_sets = [
                # Compile, Link, and CC_FLAGS make variable
                flag_set(
                    actions = actions.all_compile_and_link + actions.cc_flags_make_variable,
                    flags = [
                        "-no-canonical-prefixes",
                        "-target", target_arch + "-w64-mingw32",
                        "--sysroot=" + clang_sysroot,
                        "-resource-dir", clang_resource_dir,
                        # Override search paths of clang for startup files and libraries since we override --sysroot.
                        "-B{}/lib".format(clang_sysroot),
                        "-B{}/lib/windows".format(clang_resource_dir),
                    ],
                ),
                # Compile + Link
                flag_set(
                    actions = actions.all_compile_and_link,
                    # This forces color diagnostics even on Forge (where we don't have an
                    # attached terminal).
                    flags = ["-fdiagnostics-color"],
                ),
                # These flags are used to enfore the NX (no execute) security feature
                # in the generated machine code. This adds a special section to the
                # generated shared libraries that instruct the Linux kernel to disable
                # code execution from the stack and the heap.
                flag_set(
                    actions = actions.all_compile,
                    flags = ["-Wa,--noexecstack"],
                ),
                # flag_set(
                #     actions = actions.all_link,
                #     flags = ["-Wl,-z,noexecstack"],
                # ),
                # C++ compiles
                flag_set(
                    actions = actions.all_cpp_compile,
                    flags = [
                        "-std=gnu++17",
                        "-Wc++2a-extensions",
                        "-Woverloaded-virtual",
                        "-Wnon-virtual-dtor",
                        "-Wno-deprecated",
                        "-fshow-overloads=best",
                        "-Wdeprecated-increment-bool",
                        "-Wimplicit-fallthrough",
                        "-Wno-final-dtor-non-final-class",
                        "-Wno-dynamic-exception-spec",
                    ],
                ),
                # All compiles
                flag_set(
                    actions = actions.all_compile,
                    flags = [
                        "-faddrsig",
                        "-faligned-new",
                        "-fdata-sections",
                        "-ffunction-sections",
                        "-funsigned-char",
                        "-fno-stack-protector",
                        "-g",
                    ],
                ),

                flag_set(
                    actions = actions.all_compile,
                    flags = [
                        "-D__MINGW32__",
                        "-D_WIN64" if target_arch == "x86_64" else "-D_WIN32",
                    ],
                ),
                ## Options for particular compile modes:

                # OPT-specific flags
                flag_set(
                    actions = actions.preprocessor_compile,
                    flags = ["-DNDEBUG"],
                    features = ["opt"],
                ),
                flag_set(
                    actions = actions.all_compile,
                    flags = [
                        "-fno-strict-aliasing",
                        "-fomit-frame-pointer",
                        "-g0",
                    ],
                    features = ["opt"],
                ),
                flag_set(
                    actions = actions.all_compile,
                    flags = [
                        "-O3",
                    ],
                    features = ["opt"],
                ),
                flag_set(
                    actions = actions.all_cpp_compile,
                    flags = ["-fvisibility-inlines-hidden"],
                    features = ["opt"],
                ),

                # DBG-specific flags
                flag_set(
                    actions = actions.all_compile,
                    flags = [
                        "-O0",
                        "-fno-omit-frame-pointer",
                        "-fno-strict-aliasing",
                    ],
                    features = ["dbg"],
                ),

                # NDK-version specific options
                # flag_set(
                #     actions = actions.preprocessor_compile,
                #     # The clang shipped with NDK r15 is a pre-release Clang 5.0
                #     # binary, which has a buggy "clang::xray_log_args" that
                #     # doesn't work on the 'implicit this' argument of a class
                #     # method. It was fixed in llvm svn r305544.
                #     flags = ["-DABSL_NO_XRAY_ATTRIBUTES"],
                #     features = ["crosstool_disable_xray"],
                # ),

                ## Warning flag sets
                flag_set(
                    actions = actions.all_compile,
                    flags = ["-Werror"],
                    features = ["warnings_as_errors"],
                ),

                # Generic warning flag list
                flag_set(
                    actions = actions.all_compile,
                    flags = [
                        "-Wall",
                        "-Wformat-security",
                        "-Wno-char-subscripts",
                        "-Wno-error=deprecated-declarations",
                        "-Wno-maybe-uninitialized",
                        "-Wno-sign-compare",
                        "-Wno-strict-overflow",
                        "-Wno-unused-but-set-variable",
                        "-Wunused-but-set-parameter",
                        "-Wno-unknown-warning-option",
                        "-Wno-unused-command-line-argument",
                        "-Wno-ignored-optimization-argument",

                        # Disable some broken warnings from Clang.
                        "-Wno-ambiguous-member-template",
                        "-Wno-char-subscripts",
                        "-Wno-error=deprecated-declarations",
                        "-Wno-extern-c-compat",
                        "-Wno-gnu-alignof-expression",
                        "-Wno-gnu-variable-sized-type-not-at-end",
                        "-Wno-implicit-int-float-conversion",
                        "-Wno-invalid-source-encoding",
                        "-Wno-mismatched-tags",
                        "-Wno-pointer-sign",
                        "-Wno-private-header",
                        "-Wno-sign-compare",
                        "-Wno-signed-unsigned-wchar",
                        "-Wno-strict-overflow",
                        "-Wno-trigraphs",
                        "-Wno-unknown-pragmas",
                        "-Wno-unused-const-variable",
                        "-Wno-unused-function",
                        "-Wno-unused-private-field",
                        "-Wno-user-defined-warnings",

                        # Low SNR or otherwise not desirable.
                        "-Wno-extern-c-compat",
                        "-Wno-gnu-alignof-expression",
                        "-Wno-gnu-designator",
                        "-Wno-gnu-variable-sized-type-not-at-end",
                        "-Wno-invalid-source-encoding",
                        "-Wno-mismatched-tags",
                        "-Wno-reserved-user-defined-literal",
                        "-Wno-return-type-c-linkage",
                        "-Wno-self-assign-overloaded",
                        "-Wno-tautological-constant-in-range-compare",
                        "-Wno-unknown-pragmas",
                        "-Wfloat-overflow-conversion",
                        "-Wfloat-zero-conversion",
                        "-Wfor-loop-analysis",
                        "-Wgnu-redeclared-enum",
                        "-Winfinite-recursion",
                        "-Wliteral-conversion",
                        "-Wself-assign",
                        "-Wstring-conversion",
                        "-Wtautological-overlap-compare",
                        "-Wunused-comparison",
                        "-Wvla",

                        # Turn on thread safety analysis.
                        "-Wthread-safety-analysis",
                    ],
                ),

                # C++-specific warning flags
                flag_set(
                    actions = actions.all_cpp_compile,
                    flags = [
                        "-Wno-deprecated",
                        "-Wdeprecated-increment-bool",
                        "-Wnon-virtual-dtor",
                        "-Woverloaded-virtual",
                    ],
                ),

                # Defines and Includes and Paths and such
                flag_set(
                    actions = actions.all_compile,
                    flag_groups = [
                        flag_group(flags = ["-fPIC"]),
                    ],
                ),
                flag_set(
                    actions = actions.all_compile,
                    flag_groups = [
                        flag_group(
                            flags = ["-gsplit-dwarf", "-g"],
                            expand_if_available = "per_object_debug_info_file",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.preprocessor_compile,
                    flag_groups = [
                        flag_group(
                            flags = ["-D%{preprocessor_defines}"],
                            iterate_over = "preprocessor_defines",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.preprocessor_compile,
                    flag_groups = [
                        flag_group(
                            flags = ["-include", "%{includes}"],
                            iterate_over = "includes",
                            expand_if_available = "includes",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.preprocessor_compile,
                    flag_groups = [
                        flag_group(
                            flags = ["-iquote", "%{quote_include_paths}"],
                            iterate_over = "quote_include_paths",
                        ),
                        flag_group(
                            flags = ["-I%{include_paths}"],
                            iterate_over = "include_paths",
                        ),
                        flag_group(
                            flags = ["-isystem", "%{system_include_paths}"],
                            iterate_over = "system_include_paths",
                        ),
                    ],
                ),

                ## Linking options (not libs -- those go last)

                # Generic link options
                flag_set(
                    actions = actions.all_link,
                    flags = [
                        "-Wl,--gc-sections",
                        # Add explicit library search paths since we override --sysroot.
                        "-L{}/lib".format(clang_sysroot),
                        "-L{}/lib/windows".format(clang_resource_dir),
                    ],
                ),
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            flags = ["-Wl,--print-symbol-counts=%{symbol_counts_output}"],
                            expand_if_available = "symbol_counts_output",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            flags = ["-Wl,--gdb-index"],
                            expand_if_available = "is_using_fission",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            flags = ["-Wl,-s"],
                            expand_if_available = "strip_debug_symbols",
                        ),
                    ],
                    with_features = [with_feature_set(features = ["linker_fully_strip"])],
                ),
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            flags = ["-Wl,-S"],
                            expand_if_available = "strip_debug_symbols",
                        ),
                    ],
                    with_features = [with_feature_set(not_features = ["linker_fully_strip"])],
                ),
                flag_set(
                    actions = [action.cpp_link_executable],
                    flags = ["-pie"],
                ),
                flag_set(
                    # Dynamic Link Actions only:
                    actions = [
                        action.cpp_link_dynamic_library,
                        action.cpp_link_nodeps_dynamic_library,
                        action.lto_index_for_dynamic_library,
                        action.lto_index_for_nodeps_dynamic_library,
                    ],
                    flags = ["-shared"],
                ),

                # LLD/Gold specific linking options
                flag_set(
                    actions = actions.all_link,
                    flags = ["-fuse-ld=gold"],
                    features = ["crosstool_linker_gold"],
                ),
                flag_set(
                    actions = actions.all_link,
                    flags = ["-fuse-ld=lld"],
                    features = ["crosstool_linker_lld"],
                ),
                flag_set(
                    actions = actions.all_link,
                    flags = ["-Wl,--icf=safe"],
                    features = ["opt"],
                ),

                # Linker search paths and objects:
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            flags = ["-L%{library_search_directories}"],
                            iterate_over = "library_search_directories",
                            expand_if_available = "library_search_directories",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            # This is actually a list of object files from the linkstamp steps
                            flags = ["%{linkstamp_paths}"],
                            iterate_over = "linkstamp_paths",
                            expand_if_available = "linkstamp_paths",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            flags = ["-Wl,@%{thinlto_param_file}"],
                            expand_if_available = "libraries_to_link",
                            expand_if_true = "thinlto_param_file",
                        ),
                        flag_group(
                            iterate_over = "libraries_to_link",
                            flag_groups = [
                                flag_group(
                                    flags = ["-Wl,--start-lib"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "object_file_group",
                                    ),
                                    expand_if_false = "libraries_to_link.is_whole_archive",
                                ),
                                flag_group(
                                    flags = ["-Wl,-whole-archive"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "static_library",
                                    ),
                                    expand_if_true = "libraries_to_link.is_whole_archive",
                                ),
                                flag_group(
                                    flags = ["%{libraries_to_link.object_files}"],
                                    iterate_over = "libraries_to_link.object_files",
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "object_file_group",
                                    ),
                                ),
                                flag_group(
                                    flags = ["%{libraries_to_link.name}"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "object_file",
                                    ),
                                ),
                                flag_group(
                                    flags = ["%{libraries_to_link.name}"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "interface_library",
                                    ),
                                ),
                                flag_group(
                                    flags = ["%{libraries_to_link.name}"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "static_library",
                                    ),
                                ),
                                flag_group(
                                    flags = ["-l%{libraries_to_link.name}"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "dynamic_library",
                                    ),
                                ),
                                flag_group(
                                    flags = ["-l:%{libraries_to_link.name}"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "versioned_dynamic_library",
                                    ),
                                ),
                                flag_group(
                                    flags = ["-Wl,-no-whole-archive"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "static_library",
                                    ),
                                    expand_if_true = "libraries_to_link.is_whole_archive",
                                ),
                                flag_group(
                                    flags = ["-Wl,--end-lib"],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "object_file_group",
                                    ),
                                    expand_if_false = "libraries_to_link.is_whole_archive",
                                ),
                            ],
                            expand_if_available = "libraries_to_link",
                        ),
                    ],
                ),

                # Configure the header parsing and preprocessing.
                flag_set(
                    actions = [action.cpp_header_parsing],
                    flags = ["-xc++-header", "-fsyntax-only"],
                    features = ["parse_headers"],
                ),

                # Configure header module generation
                flag_set(
                    actions = [action.cpp_module_compile],
                    flags = [
                        "-fmodules-codegen",
                    ],
                    features = ["header_modules_codegen_functions"],
                ),
                flag_set(
                    actions = [action.cpp_module_compile],
                    flags = [
                        "-fmodules-debuginfo",
                    ],
                    features = ["header_modules_codegen_debuginfo"],
                ),
                flag_set(
                    actions = [action.cpp_module_compile],
                    flags = " ".join([
                        "-xc++",
                        "-Xclang -emit-module",
                        "-Xclang -fmodules-embed-all-files",
                        "-Xclang -fmodules-local-submodule-visibility",
                    ]).split(" "),
                    features = ["header_module_compile"],
                ),
                flag_set(
                    actions = [
                        action.cpp_compile,
                        action.cpp_header_parsing,
                        action.cpp_module_compile,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-fmodules",
                                "-fmodule-file-deps",
                                "-fno-implicit-modules",
                                "-fno-implicit-module-maps",
                                "-Wno-modules-ambiguous-internal-linkage",
                                "-Wno-module-import-in-extern-c",
                                "-Wno-modules-import-nested-redundant",
                            ],
                        ),
                        flag_group(
                            flags = ["-fmodule-file=%{module_files}"],
                            iterate_over = "module_files",
                        ),
                    ],
                    features = ["use_header_modules"],
                ),

                # Configure header module consumption.
                flag_set(
                    actions = [
                        action.c_compile,
                        action.cpp_compile,
                        action.cpp_header_parsing,
                        action.cpp_module_compile,
                    ],
                    features = ["module_map_home_cwd"],
                    flags = [
                        "-Xclang",
                        "-fmodule-map-file-home-is-cwd",
                    ],
                ),
                flag_set(
                    actions = [
                        action.c_compile,
                        action.cpp_compile,
                        action.cpp_header_parsing,
                        action.cpp_module_compile,
                    ],
                    features = ["use_module_maps"],
                    flag_groups = [
                        flag_group(
                            flags = ["-fmodule-name=%{module_name}"],
                            expand_if_available = "module_name",
                        ),
                        flag_group(
                            flags = ["-fmodule-map-file=%{module_map_file}"],
                            expand_if_available = "module_map_file",
                        ),
                    ],
                ),
                flag_set(
                    actions = [
                        action.c_compile,
                        action.cpp_compile,
                        action.cpp_header_parsing,
                        action.cpp_module_compile,
                    ],
                    features = ["layering_check"],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-fmodules-strict-decluse",
                                "-Wprivate-header",
                            ],
                        ),
                        flag_group(
                            flags = ["-fmodule-map-file=%{dependent_module_map_files}"],
                            iterate_over = "dependent_module_map_files",
                        ),
                    ],
                ),

                # Note: user compile flags should be nearly last -- you probably
                # don't want to put any more features after this!
                flag_set(
                    actions = actions.all_compile,
                    flag_groups = [
                        flag_group(
                            flags = ["%{user_compile_flags}"],
                            iterate_over = "user_compile_flags",
                            expand_if_available = "user_compile_flags",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            flags = ["%{user_link_flags}"],
                            iterate_over = "user_link_flags",
                            expand_if_available = "user_link_flags",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            flags = ["%{legacy_link_flags}"],
                            iterate_over = "legacy_link_flags",
                            expand_if_available = "legacy_link_flags",
                        ),
                    ],
                ),

                ## Options which need to go late -- after all the user options -- go here.
                flag_set(
                    actions = actions.all_link,
                    # Override and turn off icf for ld.gold x86.
                    flags = ["-Wl,--icf=none"],
                    features = ["opt", "crosstool_linker_gold", "crosstool_cpu_x86"],
                ),

                # Hardcoded library link flags.
                flag_set(
                    actions = actions.all_full_link,
                    flags = ["-Wl,--no-undefined"],
                    features = ["no_undefined"],
                ),
                # flag_set(
                #     # We override memmove() on 32-bit arm targets.
                #     # Also refer to README.md for information on how libmemmove.a is constructed.
                #     actions = actions.all_link,
                #     flags = ["-lmemmove"],
                #     features = ["crosstool_cpu_arm", "crosstool_needs_memmove_fix"],
                # ),
                # Inputs and outputs
                flag_set(
                    actions = actions.all_compile,
                    flag_groups = [
                        flag_group(
                            flags = ["-MD", "-MF", "%{dependency_file}"],
                            expand_if_available = "dependency_file",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.all_compile,
                    flag_groups = [
                        flag_group(
                            flags = ["-c", "%{source_file}"],
                            expand_if_available = "source_file",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.all_compile,
                    flag_groups = [
                        flag_group(
                            flags = ["-S"],
                            expand_if_available = "output_assembly_file",
                        ),
                        flag_group(
                            flags = ["-E"],
                            expand_if_available = "output_preprocess_file",
                        ),
                        flag_group(
                            flags = ["-o", "%{output_file}"],
                            expand_if_available = "output_file",
                        ),
                    ],
                ),
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            flags = ["-o", "%{output_execpath}"],
                            expand_if_available = "output_execpath",
                        ),
                    ],
                ),
                # And finally, the params file!
                flag_set(
                    actions = actions.all_link,
                    flag_groups = [
                        flag_group(
                            flags = ["@%{linker_param_file}"],
                            expand_if_available = "linker_param_file",
                        ),
                    ],
                ),
            ],
        ),
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "llvm-mingw-" + target_arch,
        target_system_name = "mingw",
        target_cpu = target_arch,
        target_libc = "mingw",
        cc_target_os = "windows",
        compiler = "clang",
        abi_version = "llvm",
        abi_libc_version = "mingw",
        tool_paths = tool_paths,
        builtin_sysroot = sdk_sysroot,
        cxx_builtin_include_directories = [
            "%sysroot%/include",
            "%sysroot%/include/c++/v1",
            sdk_clang_resource_dir,
        ],
        artifact_name_patterns = artifact_name_patterns,
        features = features,
        action_configs = action_configs,
    )

def construct_actions_(action = action):
    """Return a struct of lists of action names."""
    return struct(
        all_compile = [
            action.c_compile,
            action.cpp_compile,
            action.lto_backend,
            action.linkstamp_compile,
            action.assemble,
            action.preprocess_assemble,
            action.cpp_header_parsing,
            action.cpp_module_compile,
            action.cpp_module_codegen,
            action.clif_match,
        ],
        all_compile_and_link = [
            action.c_compile,
            action.cpp_compile,
            action.lto_backend,
            action.linkstamp_compile,
            action.assemble,
            action.preprocess_assemble,
            action.cpp_header_parsing,
            action.cpp_module_compile,
            action.cpp_module_codegen,
            action.clif_match,
            action.cpp_link_executable,
            action.cpp_link_dynamic_library,
            action.cpp_link_nodeps_dynamic_library,
            action.lto_index_for_executable,
            action.lto_index_for_dynamic_library,
            action.lto_index_for_nodeps_dynamic_library,
        ],
        all_cpp_compile = [
            action.cpp_compile,
            action.lto_backend,
            action.linkstamp_compile,
            action.cpp_header_parsing,
            action.cpp_module_compile,
            action.cpp_module_codegen,
            action.clif_match,
        ],
        all_full_link = [
            action.cpp_link_executable,
            action.cpp_link_dynamic_library,
            action.lto_index_for_executable,
            action.lto_index_for_dynamic_library,
        ],
        all_link = [
            action.cpp_link_executable,
            action.cpp_link_dynamic_library,
            action.cpp_link_nodeps_dynamic_library,
            action.lto_index_for_executable,
            action.lto_index_for_dynamic_library,
            action.lto_index_for_nodeps_dynamic_library,
        ],
        cc_flags_make_variable = [action.cc_flags_make_variable],
        lto_index = [
            action.lto_index_for_executable,
            action.lto_index_for_dynamic_library,
            action.lto_index_for_nodeps_dynamic_library,
        ],
        preprocessor_compile = [
            action.c_compile,
            action.cpp_compile,
            action.linkstamp_compile,
            action.preprocess_assemble,
            action.cpp_header_parsing,
            action.cpp_module_compile,
            action.clif_match,
        ],
    )

def flag_set(flags = None, features = None, not_features = None, **kwargs):
    """Extension to flag_set which allows for a "simple" form.

    The simple form allows specifying flags as a simple list instead of a flag_group
    if enable_if or expand_if semantics are not required.

    Similarly, the simple form allows passing features/not_features if they are a simple
    list of semantically "and" features.
    (i.e. "asan" and "dbg", rather than "asan" or "dbg")

    Args:
      flags: list, set of flags
      features: list, set of features required to be enabled.
      not_features: list, set of features required to not be enabled.
      **kwargs: The rest of the args for flag_set.

    Returns:
      flag_set
    """
    if flags:
        if kwargs.get("flag_groups"):
            fail("Cannot set flags and flag_groups")
        else:
            kwargs["flag_groups"] = [flag_group(flags = flags)]

    if features or not_features:
        if kwargs.get("with_features"):
            fail("Cannot set features/not_feature and with_features")
        kwargs["with_features"] = [with_feature_set(
            features = features or [],
            not_features = not_features or [],
        )]
    return flag_set_(**kwargs)

llvm_mingw_cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "target_arch": attr.string(mandatory = True),
        # A label pointing inside the external repo that contains the
        # prebuilt toolchain. The attribute should be of type label or
        # label_list pointing to a file/filegroup created in the external
        # repository's BUILD file (see suggested WORKSPACE snippet).
        "executable_extension": attr.string(default = ""),
        "host_os": attr.string(mandatory = True),
    },
    provides = [CcToolchainConfigInfo],
)