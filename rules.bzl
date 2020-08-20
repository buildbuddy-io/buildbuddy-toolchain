load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@rules_cc//cc:defs.bzl", _cc_toolchain = "cc_toolchain")

LLVM_VERSION = "8.0.0"
LLVM_DOWNLOAD_URL = "https://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz"
LLVM_SHA256 = "87b88d620284d1f0573923e6f7cc89edccf11d19ebaec1cfb83b4f09ac5db09c"
LLVM_STRIP_PREFIX = "clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04"

def _buildbuddy_toolchain_impl(rctx):
    repo_path = str(rctx.path(""))
    relative_path_prefix = "external/%s/" % rctx.name
    toolchain_path_prefix = relative_path_prefix

    substitutions = {
        "%{repo_name}": rctx.name,
        "%{llvm_version}": LLVM_VERSION,
        "%{toolchain_path_prefix}": toolchain_path_prefix,
        "%{tools_path_prefix}": "",
        "%{debug_toolchain_path_prefix}": relative_path_prefix,
        "%{sysroot_path}": "",
        "%{sysroot_prefix}": "",
        "%{sysroot_label}": "",
        "%{absolute_paths}": "False",
        "%{makevars_ld_flags}": "-fuse-ld=lld",
        "%{k8_additional_cxx_builtin_include_directories}": "",
        "%{darwin_additional_cxx_builtin_include_directories}": "",
        "%{default_cc_toolchain_suite}": "llvm_cc_toolchain_suite" if rctx.attr.llvm else "ubuntu1604_cc_toolchain_suite",
        "%{default_cc_toolchain}": "llvm_cc_toolchain" if rctx.attr.llvm else "ubuntu1604_cc_toolchain",
        "%{default_docker_image}": rctx.attr.docker_image,
    }

    rctx.template(
        "cc_toolchain_config.bzl",
        Label("//templates:cc_toolchain_config.bzl.tpl"),
        substitutions,
    )
    rctx.template(
        "llvm_cc_toolchain_config.bzl",
        Label("//templates:llvm_cc_toolchain_config.bzl.tpl"),
        substitutions,
    )
    rctx.template(
        "bin/cc_wrapper.sh",  # Co-located with the linker to help rules_go.
        Label("//templates:cc_wrapper.sh.tpl"),
        substitutions,
    )
    rctx.template(
        "Makevars",
        Label("//templates:Makevars.tpl"),
        substitutions,
    )
    rctx.template(
        "BUILD",
        Label("//templates:BUILD.tpl"),
        substitutions,
    )

    rctx.symlink("/usr/bin/ar", "bin/ar")
    rctx.symlink("/usr/bin/ld", "bin/ld")
    rctx.symlink("/usr/bin/ld.gold", "bin/ld.gold")

    # Repository implementation functions can be restarted, keep expensive ops at the end.
    if (rctx.attr.llvm):
        rctx.download_and_extract([LLVM_DOWNLOAD_URL], sha256 = LLVM_SHA256, stripPrefix = LLVM_STRIP_PREFIX)

def buildbuddy_cc_toolchain(name):
    native.filegroup(name = name + "-all-files", srcs = [":all_components"])
    native.filegroup(name = name + "-archiver-files", srcs = [":ar"])
    native.filegroup(name = name + "-assembler-files", srcs = [":as"])
    native.filegroup(name = name + "-compiler-files", srcs = [":compiler_components"])
    native.filegroup(name = name + "-linker-files", srcs = [":linker_components"])
    _cc_toolchain(
        name = name,
        all_files = name + "-all-files",
        ar_files = name + "-archiver-files",
        as_files = name + "-assembler-files",
        compiler_files = name + "-compiler-files",
        dwp_files = ":empty",
        linker_files = name + "-linker-files",
        objcopy_files = ":objcopy",
        strip_files = ":empty",
        supports_param_files = 1,
        toolchain_config = "llvm_cc_toolchain_config",
    )

buildbuddy_toolchain = repository_rule(
    attrs = {
        "llvm": attr.bool(),
        "docker_image": attr.string(),
    },
    local = False,
    implementation = _buildbuddy_toolchain_impl,
)

def buildbuddy(name, llvm = False, docker_image = "none"):
    buildbuddy_toolchain(name = name, llvm = llvm, docker_image = docker_image)

def register_buildbuddy_toolchain(name, llvm = True, docker_image = "none"):
    http_archive(
        name = "rules_cc",
        sha256 = "b6f34b3261ec02f85dbc5a8bdc9414ce548e1f5f67e000d7069571799cb88b25",
        strip_prefix = "rules_cc-726dd8157557f1456b3656e26ab21a1646653405",
        urls = ["https://github.com/bazelbuild/rules_cc/archive/726dd8157557f1456b3656e26ab21a1646653405.tar.gz"],
    )

    buildbuddy_toolchain(name = name, llvm = llvm, docker_image = docker_image)
