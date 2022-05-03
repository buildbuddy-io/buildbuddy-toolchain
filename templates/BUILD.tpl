package(default_visibility = ["//visibility:public"])

load("@rules_cc//cc:defs.bzl", "cc_toolchain", "cc_toolchain_suite")

exports_files(["Makevars"])

# Some targets may need to directly depend on these files.
exports_files(glob(["bin/*", "lib/*"]))

# Platform

alias(
    name = "platform", 
    actual = "%{default_platform}",
)

platform(
    name = "platform_linux",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
    ],
    exec_properties = {
        "OSFamily": "Linux",
        "container-image": "%{default_docker_image}",
    },
)

platform(
    name = "platform_darwin",
    constraint_values = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:osx",
        "@bazel_tools//tools/cpp:clang",
    ],
    exec_properties = {
        "OSFamily": "Darwin",
        "container-image": "none",
    },
)

platform(
    name = "platform_darwin_arm64",
    constraint_values = [
        "@bazel_tools//platforms:aarch64",
        "@bazel_tools//platforms:osx",
        "@bazel_tools//tools/cpp:clang",
    ],
    exec_properties = {
        "OSFamily": "Darwin",
        "Arch": "arm64",
        "container-image": "none",
    },
)

## Java 8

java_runtime(
    name = "javabase_jdk8",
    srcs = [],
    java_home = "/usr/lib/jvm/java-8-openjdk-amd64",
)

load(
    "@bazel_tools//tools/jdk:default_java_toolchain.bzl",
    "JDK8_JVM_OPTS",
    "default_java_toolchain",
    "java_runtime_files",
)

default_java_toolchain(
    name = "toolchain_jdk8",
    jvm_opts = JDK8_JVM_OPTS,
    source_version = "8",
    target_version = "8",
)

## Defaults

alias(
    name = "toolchain", 
    actual="%{default_cc_toolchain_suite}"
)

alias(
    name = "cc_toolchain", 
    actual="%{default_cc_toolchain}"
)


## CC

cc_toolchain_suite(
    name = "ubuntu1604_cc_toolchain_suite",
    toolchains = {
        "k8|compiler": ":ubuntu1604_local_cc_toolchain",
        "k8": ":ubuntu1604_local_cc_toolchain",
    },
)

toolchain(
    name = "ubuntu1604_cc_toolchain",
    exec_compatible_with = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@bazel_tools//tools/cpp:clang",
    ],
    target_compatible_with = [
        "@bazel_tools//platforms:linux",
        "@bazel_tools//platforms:x86_64",
    ],
    toolchain = ":ubuntu1604_local_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

cc_toolchain(
    name = "ubuntu1604_local_cc_toolchain",
    toolchain_identifier = "local",
    toolchain_config = ":ubuntu1604_cc_toolchain_config",
    all_files = ":compiler_deps",
    ar_files = ":compiler_deps",
    as_files = ":compiler_deps",
    compiler_files = ":compiler_deps",
    dwp_files = ":empty",
    linker_files = ":compiler_deps",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
)

load(":cc_toolchain_config.bzl", "cc_toolchain_config")

cc_toolchain_config(
    name = "ubuntu1604_cc_toolchain_config",
    cpu = "k8",
    compiler = "compiler",
    toolchain_identifier = "local",
    host_system_name = "local",
    target_system_name = "local",
    target_libc = "local",
    abi_version = "local",
    abi_libc_version = "local",
    cxx_builtin_include_directories = ["/usr/lib/gcc/x86_64-linux-gnu/5/include",
    "/usr/local/include",
    "/usr/lib/gcc/x86_64-linux-gnu/5/include-fixed",
    "/usr/include/x86_64-linux-gnu",
    "/usr/include",
    "/usr/include/c++/5",
    "/usr/include/x86_64-linux-gnu/c++/5",
    "/usr/include/c++/5/backward"],
    tool_paths = {"ar": "/usr/bin/ar",
        "ld": "/usr/bin/ld",
        "cpp": "/usr/bin/cpp",
        "gcc": "/usr/bin/gcc",
        "dwp": "/usr/bin/dwp",
        "gcov": "/usr/bin/gcov",
        "nm": "/usr/bin/nm",
        "objcopy": "/usr/bin/objcopy",
        "objdump": "/usr/bin/objdump",
        "strip": "/usr/bin/strip"},
    compile_flags = ["-U_FORTIFY_SOURCE",
    "-fstack-protector",
    "-Wall",
    "-Wunused-but-set-parameter",
    "-Wno-free-nonheap-object",
    "-fno-omit-frame-pointer"],
    opt_compile_flags = ["-g0",
    "-O2",
    "-D_FORTIFY_SOURCE=1",
    "-DNDEBUG",
    "-ffunction-sections",
    "-fdata-sections"],
    dbg_compile_flags = ["-g"],
    cxx_flags = ["-std=c++0x"],
    link_flags = ["-fuse-ld=gold",
    "-Wl,-no-as-needed",
    "-Wl,-z,relro,-z,now",
    "-B/usr/bin",
    "-pass-exit-codes",
    "-lstdc++",
    "-lm"],
    link_libs = [],
    opt_link_flags = ["-Wl,--gc-sections"],
    unfiltered_compile_flags = ["-fno-canonical-system-headers",
    "-Wno-builtin-macro-redefined",
    "-D__DATE__=\"redacted\"",
    "-D__TIMESTAMP__=\"redacted\"",
    "-D__TIME__=\"redacted\""],
    coverage_compile_flags = ["--coverage"],
    coverage_link_flags = ["--coverage"],
    supports_start_end_lib = True,
)

## LLVM toolchain

cc_toolchain_suite(
    name = "llvm_cc_toolchain_suite",
    toolchains = {
        "k8|clang": ":llvm_buildbuddy_cc_toolchain",
        "k8": ":llvm_buildbuddy_cc_toolchain",
    },
)

toolchain(
    name = "llvm_cc_toolchain",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    toolchain = ":llvm_buildbuddy_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)


load(":llvm_cc_toolchain_config.bzl", "llvm_cc_toolchain_config")

llvm_cc_toolchain_config(
    name = "llvm_cc_toolchain_config",
    cpu = "k8",
)

load("@io_buildbuddy_buildbuddy_toolchain//:rules.bzl", "buildbuddy_cc_toolchain")

buildbuddy_cc_toolchain("llvm_buildbuddy_cc_toolchain")

filegroup(
    name = "clang",
    srcs = [
        "bin/clang",
        "bin/clang++",
        "bin/clang-cpp",
    ],
)

filegroup(
    name = "ld",
    srcs = [
        "bin/ld.lld",
        "bin/ld",
        "bin/ld.gold",  # Dummy file on non-linux.
    ],
)

filegroup(
    name = "include",
    srcs = glob([
        "include/c++/**",
        "lib/clang/%{llvm_version}/include/**",
    ]),
)

filegroup(
    name = "lib",
    srcs = glob(
        [
            "lib/lib*.a",
            "lib/clang/%{llvm_version}/lib/**/*.a",
        ],
        exclude = [
            "lib/libLLVM*.a",
            "lib/libclang*.a",
            "lib/liblld*.a",
        ],
    ),
)

filegroup(
    name = "compiler_components",
    srcs = [
        ":clang",
        ":include",
        ":sysroot_components",
    ],
)

filegroup(
    name = "ar",
    srcs = ["bin/llvm-ar"],
)

filegroup(
    name = "as",
    srcs = [
        "bin/clang",
        "bin/llvm-as",
    ],
)

filegroup(
    name = "nm",
    srcs = ["bin/llvm-nm"],
)

filegroup(
    name = "objcopy",
    srcs = ["bin/llvm-objcopy"],
)

filegroup(
    name = "objdump",
    srcs = ["bin/llvm-objdump"],
)

filegroup(
    name = "profdata",
    srcs = ["bin/llvm-profdata"],
)

filegroup(
    name = "dwp",
    srcs = ["bin/llvm-dwp"],
)

filegroup(
    name = "ranlib",
    srcs = ["bin/llvm-ranlib"],
)

filegroup(
    name = "readelf",
    srcs = ["bin/llvm-readelf"],
)

filegroup(
    name = "binutils_components",
    srcs = glob(["bin/*"]),
)

filegroup(
    name = "linker_components",
    srcs = [
        ":clang",
        ":ld",
        ":ar",
        ":lib",
        ":sysroot_components",
    ],
)

filegroup(
    name = "all_components",
    srcs = [
        ":binutils_components",
        ":compiler_components",
        ":linker_components",
    ],
)

filegroup(
    name = "sysroot_components",
    srcs = [%{sysroot_label}],
)

filegroup(
    name = "empty",
    srcs = [],
)

filegroup(
    name = "compiler_deps",
    srcs = glob(["extra_tools/**"], allow_empty = True) # + [":builtin_include_directory_paths"],
)
