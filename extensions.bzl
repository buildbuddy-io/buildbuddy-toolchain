load("//:rules.bzl", bb_macro = "buildbuddy")

def _ext_impl(mctx):
    found_root_modules = False
    root_modules = struct()
    for m in mctx.modules:
        if m.is_root:
            found_root_modules = True
            root_modules = m
            break
    if not found_root_modules:
        fail("buildbuddy must be used in root module")

    if len(root_modules.tags.platform) > 1:
        fail("buildbuddy.platform can only be specified once per module")
    if len(root_modules.tags.gcc_toolchain) > 1:
        fail("buildbuddy.gcc_toolchain can only be specified once per module")
    if len(root_modules.tags.msvc_toolchain) > 1:
        fail("buildbuddy.msvc_toolchain can only be specified once per module")

    macro_args = dict()
    if len(root_modules.tags.platform) == 1:
        macro_args |= {
            "container_image": root_modules.tags.platform[0].container_image,
        }
    if len(root_modules.tags.gcc_toolchain) == 1:
        gcc_toolchain_tag = root_modules.gcc_toolchain[0]
        macro_args |= {
            "gcc_major_version": gcc_toolchain_tag.gcc_major_version,
            "extra_cxx_builtin_include_directories": gcc_toolchain_tag.extra_cxx_builtin_include_directories,
        }
    if len(root_modules.tags.msvc_toolchain) == 1:
        msvc_toolchain_tag = root_modules.msvc_toolchain[0]
        macro_args |= {
            "msvc_edition": msvc_toolchain_tag.msvc_edition,
            "msvc_release": msvc_toolchain_tag.msvc_release,
            "msvc_version": msvc_toolchain_tag.msvc_version,
            "windows_kits_release": msvc_toolchain_tag.windows_kits_release,
            "windows_kits_version": msvc_toolchain_tag.windows_kits_version,
        }

    bb_macro(
        name = "buildbuddy_toolchain",
        **macro_args,
    )

buildbuddy = module_extension(
    implementation = _ext_impl,
    tag_classes = {
        "gcc_toolchain": tag_class(
            attrs = {
                "gcc_major_version": attr.string(),
                "extra_cxx_builtin_include_directories": attr.string_list(),
            },
        ),
        "msvc_toolchain": tag_class(
            attrs = {
                "msvc_edition": attr.string(values = ["Community", "Professional", "Enterprise"]),
                "msvc_release": attr.string(),
                "msvc_version": attr.string(),
                "windows_kits_release": attr.string(),
                "windows_kits_version": attr.string(),
            },
        ),
        "platform": tag_class(
            attrs = {
                "container_image": attr.string(default = ""),
            },
        ),
    },
)
