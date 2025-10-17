def _mingw_tool_repository_impl(ctx):
    repository_name = ctx.attr._build.workspace_name

    ctx.download_and_extract(
        url = ctx.attr.toolchain_url,
        output = "toolchain",
        stripPrefix = ctx.attr.toolchain_strip_prefix,
    )

    ctx.template(
        "BUILD.bazel",
        ctx.attr._template_build_bazel,
        {
            "{repository_name}": repository_name,
            "{host_platform}": ",".join(['"' + p + '"' for p in ctx.attr.host_platform]),
            "{host_cpu}": ",".join(['"' + c + '"' for c in ctx.attr.host_cpu]),
            "{executable_extension}": ".exe" if "windows" in ctx.os.name else "",
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
