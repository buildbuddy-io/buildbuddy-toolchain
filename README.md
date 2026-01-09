# BuildBuddy RBE Toolchain

Currently supports Linux C/C++ (including CGO) on Ubuntu 16.04, 20.04, 22.04 and Windows 11 (or newer).

## Usage instructions

For the most up-to-date instructions, see our [Official Documentation](https://buildbuddy.io/docs/rbe-setup).

#### BzlMod

Add the following to your `MODULE.bazel` file:

```python
bazel_dep(name = "toolchains_buildbuddy", version = "0.0.4")

# Use the extension to create toolchain and platform targets
buildbuddy = use_extension("@toolchains_buildbuddy//:extensions.bzl", "buildbuddy")
```

You can build remotely using these flags:

```
bazel build //your:target \
    --enable_bzlmod \
    --lockfile_mode=update \
    --incompatible_strict_action_env \
    --bes_results_url=https://app.buildbuddy.io/invocation/ \
    --bes_backend=grpcs://remote.buildbuddy.io \
    --remote_executor=grpcs://remote.buildbuddy.io \
    --platforms=@toolchains_buildbuddy//platforms:linux_x86_64 \
    --extra_execution_platforms=@toolchains_buildbuddy//platforms:linux_x86_64 \
    --extra_toolchains=@toolchains_buildbuddy//toolchains/cc:ubuntu_gcc_x86_64
```

For customization options, see our [BzlMod Example](https://github.com/buildbuddy-io/buildbuddy-toolchain/tree/master/examples/bzlmod).

#### WORKSPACE

Add the following lines to your `WORKSPACE` file. You'll probably want to pin your version to a specific commit rather than master.

```python
http_archive(
    name = "io_buildbuddy_buildbuddy_toolchain",
    integrity = "sha256-4rtmioGI2dzQey1h0fw7z2exUCCelNv0Uff7uwrQihc=",
    strip_prefix = "buildbuddy-toolchain-v0.0.4",
    urls = ["https://github.com/buildbuddy-io/buildbuddy-toolchain/releases/download/v0.0.4/buildbuddy-toolchain-v0.0.4.tar.gz"],
)

load("@io_buildbuddy_buildbuddy_toolchain//:deps.bzl", "buildbuddy_deps")

buildbuddy_deps()

load("@io_buildbuddy_buildbuddy_toolchain//:rules.bzl", "buildbuddy")

buildbuddy(name = "buildbuddy_toolchain")
```

You can build remotely using these flags:

```
bazel build //your:target \
    --noenable_bzlmod \
    --enable_workspace \
    --incompatible_strict_action_env \
    --bes_results_url=https://app.buildbuddy.io/invocation/ \
    --bes_backend=grpcs://remote.buildbuddy.io \
    --remote_executor=grpcs://remote.buildbuddy.io \
    --platforms=@buildbuddy_toolchain//:platform_linux_x86_64 \
    --extra_execution_platforms=@buildbuddy_toolchain//:platform_linux_x86_64 \
    --extra_toolchains=@buildbuddy_toolchain//:ubuntu_cc_toolchain
```

## Java support

Bazel provides support for Java toolchains out of the box.
You can enabled the Java toolchain with the following flags:

```
--java_language_version=17
--tool_java_language_version=17
--java_runtime_version=remotejdk_17
--tool_java_runtime_version=remotejdk_17
```

Available verions are listed in [Bazel's User Manual](https://bazel.build/docs/user-manual#java-language-version)

If you need a custom Java toolchain, see Bazel's docs on [Java toolchain configuration](https://bazel.build/docs/bazel-and-java#config-java-toolchains).

## Linux image variants

The following Linux images are available for remote execution:

### Ubuntu 16.04 image (**default**)

This image is the default when using the BuildBuddy toolchain. To
reference it explicitly, you can declare the toolchain like this:

```python
load("@io_buildbuddy_buildbuddy_toolchain//:rules.bzl", "buildbuddy", "UBUNTU16_04_IMAGE")

buildbuddy(name = "buildbuddy_toolchain", container_image = UBUNTU16_04_IMAGE)
```

This image includes the following build tools:

- Java 8 (javac 1.8.0_242)
- GCC 5.4.0
- GLIBC 2.23
- Clang/LLVM 11.0.0
- Python 2.7.12 (`python` in `$PATH` uses this version)
- Python 3.6.10
- Go 1.14.1

### Ubuntu 20.04 image

To use Ubuntu 20.04, import the toolchain as follows:

```python
load("@io_buildbuddy_buildbuddy_toolchain//:rules.bzl", "buildbuddy", "UBUNTU20_04_IMAGE")

buildbuddy(name = "buildbuddy_toolchain", container_image = UBUNTU20_04_IMAGE)
```

This image includes the following build tools:

- Java 11.0.17
- GCC 9.4.0
- GLIBC 2.31
- Clang/LLVM 15.0.0
- Python 2.7.18 (`python` in `$PATH` uses this version)
- Python 3.8.10
- Go 1.19.4

### Ubuntu 22.04 image

To use Ubuntu 22.04, import the toolchain as follows:

```python
load("@io_buildbuddy_buildbuddy_toolchain//:rules.bzl", "buildbuddy", "UBUNTU22_04_IMAGE")

buildbuddy(name = "buildbuddy_toolchain", container_image = UBUNTU22_04_IMAGE)
```

This image includes the following build tools:

- GCC 11.4.0
- GLIBC 2.35
- Python 3.10.12

### Ubuntu 24.04 image

To use Ubuntu 24.04, import the toolchain as follows:

```python
load("@io_buildbuddy_buildbuddy_toolchain//:rules.bzl", "buildbuddy", "UBUNTU24_04_IMAGE")

buildbuddy(name = "buildbuddy_toolchain", container_image = UBUNTU24_04_IMAGE)
```

This image includes the following build tools:

- GCC 13.3.0
- GLIBC 2.39
- Python 3.12.3

## Networking

If you need networking, you must enable it for the actions that need it. There
is a performance hit when networking is enabled because networking resources
need to be setup and torn down for each action. Because of the performance hit,
you probably want to enable networking just for the actions that need it by
adding the following exec_properties:

```
+    exec_properties = {
+        "dockerNetwork":"bridge",
+    },
```

## Additional resources

- Check out our official documentation for [RBE Setup](https://www.buildbuddy.io/docs/rbe-setup)
- For more advanced use cases, check out Bazel's [bazel-toolchains repo](https://github.com/bazelbuild/bazel-toolchains) and the [docs on configuring C++ toolchains](https://docs.bazel.build/versions/master/tutorial/cc-toolchain-config.html).
- Many thanks to the maintainers of [LLVM toolchain repo](https://github.com/bazel-contrib/toolchains_llvm), which served as the basis for this repo.
- Major props to the team at VSCO who's [toolchain repo](https://github.com/vsco/bazel-toolchains) paved the way for using LLVM as a Bazel toolchain.

## Other CC toolchains

For advanced users who want to write their own CC toolchain, these existing CC toolchains that can serve as references:

- Bazel's [default local CC toolchains](https://cs.opensource.google/bazel/bazel/+/master:tools/cpp/;drc=bd2da6e977172398bb6612c3a45e91fd1192961a)

- Uber's [Zig-based CC Toolchain](https://github.com/uber/hermetic_cc_toolchain/)

- [LLVM toolchain](https://github.com/bazel-contrib/toolchains_llvm)

- [MUSL toolchain](https://github.com/bazel-contrib/musl-toolchain)

- [GCC toolchain](https://github.com/f0rmiga/gcc-toolchain)

- Apple_support's [XCode toolchain](https://github.com/bazelbuild/apple_support/blob/a40bcaa218ee423168dd3f9af8085e6bacac2f9f/crosstool/cc_toolchain_config.bzl#L14)
