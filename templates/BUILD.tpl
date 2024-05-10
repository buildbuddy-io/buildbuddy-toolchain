load(
    "@bazel_tools//tools/jdk:default_java_toolchain.bzl",
    %{jvm_opts_import}
    "default_java_toolchain",
    "java_runtime_files",
)
load("@rules_cc//cc:defs.bzl", "cc_toolchain", "cc_toolchain_suite")
load("@io_buildbuddy_buildbuddy_toolchain//:rules.bzl", "buildbuddy_cc_toolchain")
load(":cc_toolchain_config.bzl", "cc_toolchain_config")
load(":llvm_cc_toolchain_config.bzl", "llvm_cc_toolchain_config")
load(":windows_cc_toolchain_config.bzl", windows_cc_toolchain_config = "cc_toolchain_config")

package(default_visibility = ["//visibility:public"])

# Some targets may need to directly depend on these files.
exports_files(glob(["bin/*", "lib/*"], allow_empty = True))

## Platforms

alias(
    name = "platform", 
    actual = "%{default_platform}",
)

platform(
    name = "platform_linux",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
        "@bazel_tools//tools/cpp:clang",
    ],
    exec_properties = {
        "OSFamily": "Linux",
        "container-image": "%{default_container_image}",
        "dockerNetwork": "%{default_docker_network}",
    },
)

platform(
    name = "platform_linux_arm64",
    constraint_values = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
        "@bazel_tools//tools/cpp:clang",
    ],
    exec_properties = {
        "OSFamily": "Linux",
        "container-image": "%{default_container_image}",
        "dockerNetwork": "%{default_docker_network}",
    },
)

platform(
    name = "platform_darwin",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:macos",
        "@bazel_tools//tools/cpp:clang",
    ],
    exec_properties = {
        "OSFamily": "Darwin",
        "container-image": "none",
        "dockerNetwork": "%{default_docker_network}",
    },
)

platform(
    name = "platform_darwin_arm64",
    constraint_values = [
        "@platforms//cpu:aarch64",
        "@platforms//os:osx",
        "@bazel_tools//tools/cpp:clang",
    ],
    exec_properties = {
        "OSFamily": "Darwin",
        "Arch": "arm64",
        "container-image": "none",
        "dockerNetwork": "%{default_docker_network}",
    },
)

platform(
    name = "platform_windows",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:windows",
        "@bazel_tools//tools/cpp:msvc",
    ],
    exec_properties = {
        "OSFamily": "Windows",
    },
)

## Java %{java_version}

java_runtime(
    name = "javabase",
    srcs = [],
    java_home = "/usr/lib/jvm/java-%{java_version}-openjdk-amd64",
)

default_java_toolchain(
    name = "java_toolchain",
    jvm_opts = %{jvm_opts},
    source_version = "%{java_version}",
    target_version = "%{java_version}",
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
    name = "ubuntu_cc_toolchain_suite",
    toolchains = {
        "k8|compiler": ":ubuntu_local_cc_toolchain",
        "k8": ":ubuntu_local_cc_toolchain",
    },
)

toolchain(
    name = "ubuntu_cc_toolchain",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
        "@bazel_tools//tools/cpp:clang",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":ubuntu_local_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

cc_toolchain(
    name = "ubuntu_local_cc_toolchain",
    toolchain_identifier = "local",
    toolchain_config = ":ubuntu_cc_toolchain_config",
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

cc_toolchain_config(
    name = "ubuntu_cc_toolchain_config",
    cpu = "k8",
    compiler = "compiler",
    toolchain_identifier = "local",
    host_system_name = "local",
    target_system_name = "local",
    target_libc = "local",
    abi_version = "local",
    abi_libc_version = "local",
    cxx_builtin_include_directories = [
        "/usr/lib/gcc/x86_64-linux-gnu/%{gcc_version}/include",
        "/usr/local/include",
        "/usr/lib/gcc/x86_64-linux-gnu/%{gcc_version}/include-fixed",
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
        "/usr/include/c++/%{gcc_version}",
        "/usr/include/x86_64-linux-gnu/c++/%{gcc_version}",
        "/usr/include/c++/%{gcc_version}/backward",
        %{extra_cxx_builtin_include_directories}
    ],
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
    cxx_flags = ["-std=c++17"],
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

llvm_cc_toolchain_config(
    name = "llvm_cc_toolchain_config",
    cpu = "k8",
)

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
    srcs = glob(
        [
            "include/c++/**",
            "lib/clang/%{llvm_version}/include/**",
        ],
        allow_empty = True,
    ),
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
        allow_empty = True,
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

## Windows MSVC Toolchain

filegroup(
    name = "msvc_compiler_files",
    srcs = [":include_directory_paths_msvc"],
)

windows_cc_toolchain_config(
    name = "msvc_toolchain_config",
    cpu = "x64_windows",
    compiler = "msvc-cl",
    host_system_name = "local",
    target_system_name = "local",
    target_libc = "msvcrt",
    abi_version = "local",
    abi_libc_version = "local",
    toolchain_identifier = "msvc_toolchain_config",
    msvc_env_tmp = "C:\\Users\\User\\AppData\\Local\\Temp",
    msvc_env_path = ";".join([
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\Common7\\IDE\\",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\Common7\\IDE\\CommonExtensions\\Microsoft\\FSharp\\Tools",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\Common7\\IDE\\CommonExtensions\\Microsoft\\TeamFoundation\\Team Explorer",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\Common7\\IDE\\CommonExtensions\\Microsoft\\TestWindow",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\Common7\\IDE\\VC\\Linux\\bin\\ConnectionManagerExe",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\Common7\\IDE\\VC\\VCPackages",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\Common7\\Tools\\",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\MSBuild\\Current\\bin\\Roslyn",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\Team Tools\\DiagnosticsHub\\Collector",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\VC\\Tools\\MSVC\\%{msvc_version}\\bin\\HostX64\\x64",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\\\MSBuild\\Current\\Bin\\amd64",
    ]),
    msvc_env_include = ";".join([
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Include\\%{windows_kits_version}\\cppwinrt",
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Include\\%{windows_kits_version}\\shared",
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Include\\%{windows_kits_version}\\um",
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Include\\%{windows_kits_version}\\winrt",
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Include\\%{windows_kits_version}\\ucrt",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\VC\\Auxiliary\\VS\\include",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\VC\\Tools\\MSVC\\%{msvc_version}\\include",
    ]),
    msvc_env_lib = ";".join([
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Lib\\%{windows_kits_version}\\um\\x64",
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Lib\\%{windows_kits_version}\\ucrt\\x64",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\VC\\Tools\\MSVC\\%{msvc_version}\\lib\\x64",
    ]),
    msvc_cl_path = "C:/Program Files/Microsoft Visual Studio/%{msvc_release}/%{msvc_edition}/VC/Tools/MSVC/%{msvc_version}/bin/HostX64/x64/cl.exe",
    msvc_ml_path = "C:/Program Files/Microsoft Visual Studio/%{msvc_release}/%{msvc_edition}/VC/Tools/MSVC/%{msvc_version}/bin/HostX64/x64/ml64.exe",
    msvc_link_path = "C:/Program Files/Microsoft Visual Studio/%{msvc_release}/%{msvc_edition}/VC/Tools/MSVC/%{msvc_version}/bin/HostX64/x64/link.exe",
    msvc_lib_path = "C:/Program Files/Microsoft Visual Studio/%{msvc_release}/%{msvc_edition}/VC/Tools/MSVC/%{msvc_version}/bin/HostX64/x64/lib.exe",
    cxx_builtin_include_directories = [
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Include\\%{windows_kits_version}\\cppwinrt",
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Include\\%{windows_kits_version}\\shared",
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Include\\%{windows_kits_version}\\um",
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Include\\%{windows_kits_version}\\winrt",
        "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}\\Include\\%{windows_kits_version}\\ucrt",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\VC\\Auxiliary\\VS\\include",
        "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}\\VC\\Tools\\MSVC\\%{msvc_version}\\include",
    ],
    tool_paths = {
        "ar": "C:/Program Files/Microsoft Visual Studio/%{msvc_release}/%{msvc_edition}/VC/Tools/MSVC/%{msvc_version}/bin/HostX64/x64/lib.exe",
        "ml": "C:/Program Files/Microsoft Visual Studio/%{msvc_release}/%{msvc_edition}/VC/Tools/MSVC/%{msvc_version}/bin/HostX64/x64/ml64.exe",
        "cpp": "C:/Program Files/Microsoft Visual Studio/%{msvc_release}/%{msvc_edition}/VC/Tools/MSVC/%{msvc_version}/bin/HostX64/x64/cl.exe",
        "gcc": "C:/Program Files/Microsoft Visual Studio/%{msvc_release}/%{msvc_edition}/VC/Tools/MSVC/%{msvc_version}/bin/HostX64/x64/cl.exe",
        "gcov": "wrapper/bin/msvc_nop.bat",
        "ld": "C:/Program Files/Microsoft Visual Studio/%{msvc_release}/%{msvc_edition}/VC/Tools/MSVC/%{msvc_version}/bin/HostX64/x64/link.exe",
        "nm": "wrapper/bin/msvc_nop.bat",
        "objcopy": "wrapper/bin/msvc_nop.bat",
        "objdump": "wrapper/bin/msvc_nop.bat",
        "strip": "wrapper/bin/msvc_nop.bat",
    },
    archiver_flags = ["/MACHINE:X64"],
    default_link_flags = ["/MACHINE:X64"],
    dbg_mode_debug_flag = "/DEBUG:FULL",
    fastbuild_mode_debug_flag = "/DEBUG:FASTLINK",
    supports_parse_showincludes = True,
)

cc_toolchain(
    name = "msvc_toolchain",
    toolchain_identifier = "msvc_toolchain_config",
    toolchain_config = ":msvc_toolchain_config",
    all_files = ":empty",
    ar_files = ":empty",
    as_files = ":msvc_compiler_files",
    compiler_files = ":msvc_compiler_files",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = True,
)

toolchain(
    name = "windows_msvc_cc_toolchain",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:windows",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:windows",
    ],
    toolchain = ":msvc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
