def _mingw_tool_repository_impl(ctx):
    repository_name = ctx.attr._build.workspace_name

    ctx.download_and_extract(
        url = ctx.attr.toolchain_url,
        output = "toolchain",
        stripPrefix = ctx.attr.toolchain_strip_prefix,
    )

    # Create symlinks for runtime libraries since we override --sysroot.
    # llvm-mingw stores runtime libs in a generic "windows/" directory,
    # but clang expects architecture-specific directories (e.g., x86_64-w64-windows-gnu/).
    clang_lib_dir = "toolchain/lib/clang/21/lib"
    windows_dir = clang_lib_dir + "/windows"

    for arch in ["x86_64-w64-windows-gnu", "i686-w64-windows-gnu",
                 "armv7-w64-windows-gnu", "aarch64-w64-windows-gnu"]:
        arch_dir = clang_lib_dir + "/" + arch
        # Create symlink (or junction point on Windows).
        if ctx.path(windows_dir).exists and not ctx.path(arch_dir).exists:
            ctx.symlink(windows_dir, arch_dir)

    ctx.template(
        "BUILD.bazel",
        ctx.attr._template_build_bazel,
        {
            "{repository_name}": repository_name,
            "{host_platform}": ",".join(['"' + p + '"' for p in ctx.attr.host_platform]),
            "{host_cpu}": ",".join(['"' + c + '"' for c in ctx.attr.host_cpu]),
            "{executable_extension}": ".exe" if "windows" in ctx.os.name else "",
            "{host_os}": ctx.os.name,
        },
        executable = False,
    )
    
mingw_tool_repository = repository_rule(
    attrs = {
        "_build": attr.label(default = ":BUILD", allow_single_file = True),
        "_template_build_bazel": attr.label(default = ":template.build.bazel.tpl", allow_single_file = True),
        "toolchain_url": attr.string(mandatory = True),
        "toolchain_strip_prefix": attr.string(mandatory = True),
        "host_platform": attr.string_list(mandatory = True),
        "host_cpu": attr.string_list(mandatory = False, default = []),
    },
    implementation = _mingw_tool_repository_impl,
)
