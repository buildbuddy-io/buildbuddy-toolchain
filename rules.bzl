load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@rules_cc//cc:defs.bzl", _cc_toolchain = "cc_toolchain")

def _buildbuddy_toolchain_impl(rctx):
    repo_path = str(rctx.path(""))
    relative_path_prefix = "external/%s/" % rctx.name
    toolchain_path_prefix = relative_path_prefix

    # Select the correct default platform.
    if rctx.os.name == "mac os x":
        if rctx.os.arch == "aarch64":
            default_platform = "platform_darwin_arm64"
        else:
            default_platform = "platform_darwin"
    else:
        default_platform = "platform_linux"

    default_container_image = rctx.attr.container_image
    if default_container_image is None or default_container_image == "":
        if rctx.os.arch == "aarch64":
            default_container_image = UBUNTU22_04_ARM64_IMAGE
        else:
            default_container_image = UBUNTU20_04_IMAGE

    substitutions = {
        "%{toolchain_path_prefix}": toolchain_path_prefix,
        "%{tools_path_prefix}": "",
        "%{debug_toolchain_path_prefix}": relative_path_prefix,
        "%{sysroot_path}": "",
        "%{sysroot_prefix}": "",
        "%{sysroot_label}": "",
        "%{makevars_ld_flags}": "-fuse-ld=lld",
        "%{linux_gnu_include_dirname}": "aarch64-linux-gnu" if rctx.os.arch == "aarch64" else "x86_64-linux-gnu",
        "%{k8_additional_cxx_builtin_include_directories}": "",
        "%{default_cc_toolchain_suite}": "@local_config_cc//:toolchain" if rctx.os.name == "mac os x" else ":ubuntu_cc_toolchain_suite",
        "%{default_cc_toolchain}": ":ubuntu_cc_toolchain",
        "%{gcc_version}": rctx.attr.gcc_version,
        "%{default_container_image}": default_container_image,
        "%{default_docker_network}": "off",
        "%{default_platform}": default_platform,
        "%{platform_local_arch_target}": "aarch64" if rctx.os.arch == "aarch64" else "x86_64",
        "%{java_version}": rctx.attr.java_version,
        # Handle removal of JDK8_JVM_OPTS in bazel 6.0.0:
        # https://github.com/bazelbuild/bazel/commit/3a0a4f3b6931fbb6303fc98eec63d4434d8aece4
        "%{jvm_opts_import}": '"JDK8_JVM_OPTS",' if native.bazel_version and native.bazel_version < "6.0.0" and rctx.attr.java_version == "8" else "",
        "%{jvm_opts}": "JDK8_JVM_OPTS" if native.bazel_version and native.bazel_version < "6.0.0" and rctx.attr.java_version == "8" else '["-Xbootclasspath/p:$(location @remote_java_tools//:javac_jar)"]',
        "%{msvc_edition}": rctx.attr.msvc_edition,
        "%{msvc_release}": rctx.attr.msvc_release,
        "%{msvc_version}": rctx.attr.msvc_version,
        "%{windows_kits_release}": rctx.attr.windows_kits_release,
        "%{windows_kits_version}": rctx.attr.windows_kits_version,
    }
    rctx.template(
        "bin/cc_wrapper.sh",  # Co-located with the linker to help rules_go.
        Label("//templates:cc_wrapper.sh.tpl"),
        substitutions,
    )
    substitutions["%{extra_cxx_builtin_include_directories}"] = "\n".join(['%s"%s",' % (" " * 8, x) for x in rctx.attr.extra_cxx_builtin_include_directories])
    rctx.template(
        "BUILD",
        Label("//templates:BUILD.tpl"),
        substitutions,
    )
    rctx.symlink(
        Label("//templates:cc_toolchain_config.bzl"),
        "cc_toolchain_config.bzl",
    )
    rctx.symlink(
        Label("//templates:windows_cc_toolchain_config.bzl"),
        "windows_cc_toolchain_config.bzl",
    )
    rctx.symlink(
        Label("//templates:include_directory_paths_msvc"),
        "include_directory_paths_msvc",
    )

    if not rctx.os.name.lower().startswith("windows"):
        rctx.symlink("/usr/bin/ar", "bin/ar")
        rctx.symlink("/usr/bin/ld", "bin/ld")
        rctx.symlink("/usr/bin/ld.gold", "bin/ld.gold")

    # Repository implementation functions can be restarted, keep expensive ops at the end.
    if rctx.attr.llvm:
        print("BuildBuddy toolchain LLVM support is deprecated.\nPlease use https://github.com/bazel-contrib/toolchains_llvm/ instead.")

def buildbuddy_cc_toolchain(name):
    print("buildbuddy_cc_toolchain support is deprecated.\nPlease use @buildbuddy_toolchain//:ubuntu_cc_toolchain instead.")

_buildbuddy_toolchain = repository_rule(
    attrs = {
        "llvm": attr.bool(),
        "container_image": attr.string(),
        "java_version": attr.string(),
        "gcc_version": attr.string(),
        "msvc_edition": attr.string(values = ["Community", "Professional", "Enterprise"]),
        "msvc_release": attr.string(),
        "msvc_version": attr.string(),
        "windows_kits_release": attr.string(),
        "windows_kits_version": attr.string(),
        "extra_cxx_builtin_include_directories": attr.string_list(),
    },
    local = False,
    implementation = _buildbuddy_toolchain_impl,
)

# Specifying an empty container_image value means "use the default image."
DEFAULT_IMAGE = ""

UBUNTU16_04_IMAGE = "gcr.io/flame-public/executor-docker-default:enterprise-v1.6.0"

UBUNTU20_04_IMAGE = "gcr.io/flame-public/rbe-ubuntu20-04:latest"

UBUNTU22_04_ARM64_IMAGE = "gcr.io/flame-public/rbe-ubuntu22-04:latest-arm64"

def buildbuddy(
        name,
        container_image = None,
        llvm = False,
        java_version = "",
        gcc_version = "",
        msvc_edition = "Community",
        msvc_release = "2022",
        msvc_version = "14.39.33519",
        windows_kits_release = "10",
        windows_kits_version = "10.0.22621.0",
        extra_cxx_builtin_include_directories = []):
    if java_version != "":
        print("""
WARNING: java_version support in buildbuddy-toolchain is deprecated and will be removed in a future release.
Please visit https://www.buildbuddy.io/docs/rbe-setup#java-toolchain for the recommended Java toolchain setup.""")

    default_tool_versions = _default_tool_versions(container_image)

    _buildbuddy_toolchain(
        name = name,
        container_image = _container_image_prop(container_image),
        llvm = llvm,
        java_version = java_version or default_tool_versions["java"],
        gcc_version = gcc_version or default_tool_versions["gcc"],
        msvc_edition = msvc_edition,
        msvc_release = msvc_release,
        msvc_version = msvc_version,
        windows_kits_release = windows_kits_release,
        windows_kits_version = windows_kits_version,
        extra_cxx_builtin_include_directories = extra_cxx_builtin_include_directories,
    )

def _default_tool_versions(container_image):
    if _is_same_image(container_image, UBUNTU20_04_IMAGE):
        return {"java": "11", "gcc": "9"}

    if _is_same_image(container_image, UBUNTU22_04_ARM64_IMAGE):
        return {"java": "11", "gcc": "9"}

    return {"java": "8", "gcc": "5"}

def _is_same_image(a, b):
    """Returns whether two images are the same, NOT including tag or digest."""
    image_a, _, _ = _split_image(a)
    image_b, _, _ = _split_image(b)

    return image_a == image_b

def _split_image(image):
    if image.startswith("docker://"):
        image = image[len("docker://"):]

    digest = ""
    tag = ""
    if "@" in image:
        image, digest = image.split("@")
    elif ":" in image:
        image, tag = image.split(":")

    return image, tag, digest

def _container_image_prop(image):
    if image is None or image == "" or image == "none":
        return image
    if not image.startswith("docker://"):
        return "docker://" + image
    return image
