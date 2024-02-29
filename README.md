# BuildBuddy RBE Toolchain

Currently supports Linux C/C++ (including CGO) & Java builds on Ubuntu 16.04
or Ubuntu 20.04 (**experimental**).

## Usage instructions

Add the following lines to your `WORKSPACE` file. You'll probably want to pin your version to a specific commit rather than master.

```python
http_archive(
    name = "io_buildbuddy_buildbuddy_toolchain",
    sha256 = "e899f235b36cb901b678bd6f55c1229df23fcbc7921ac7a3585d29bff2bf9cfd",
    strip_prefix = "buildbuddy-toolchain-fd351ca8f152d66fc97f9d98009e0ae000854e8f",
    urls = ["https://github.com/buildbuddy-io/buildbuddy-toolchain/archive/fd351ca8f152d66fc97f9d98009e0ae000854e8f.tar.gz"],
)

load("@io_buildbuddy_buildbuddy_toolchain//:deps.bzl", "buildbuddy_deps")

buildbuddy_deps()

load("@io_buildbuddy_buildbuddy_toolchain//:rules.bzl", "buildbuddy")

buildbuddy(name = "buildbuddy_toolchain")
```

Now you can use the toolchain in your BuildBuddy RBE builds. For example:

```
bazel build server \
    --remote_executor=remote.buildbuddy.io \
    --extra_execution_platforms=@buildbuddy_toolchain//:platform \
    --host_platform=@buildbuddy_toolchain//:platform \
    --platforms=@buildbuddy_toolchain//:platform \
    --crosstool_top=@buildbuddy_toolchain//:toolchain
```

## Java support

If you need Java support, you just need to add a few more flags:

```
--javabase=@buildbuddy_toolchain//:javabase
--host_javabase=@buildbuddy_toolchain//:javabase
--java_toolchain=@buildbuddy_toolchain//:java_toolchain
```

## GCC / Clang selection

By default, the RBE images are configured to use GCC. If you would rather
use Clang / LLVM, set `llvm = True` in the toolchain repository rule:

```python
buildbuddy(name = "buildbuddy_toolchain", llvm = True)
```

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

### Ubuntu 20.04 image (**experimental**)

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

- For more advanced use cases, check out Bazel's [bazel-toolchains repo](https://github.com/bazelbuild/bazel-toolchains) and the [docs on configuring C++ toolchains](https://docs.bazel.build/versions/master/tutorial/cc-toolchain-config.html).
- Many thanks to the team at Grail who's [LLVM toolchain repo](https://github.com/grailbio/bazel-toolchain) served as the basis for this repo.
- Major props to the team at VSCO who's [toolchain repo](https://github.com/vsco/bazel-toolchains) paved the way for using LLVM as a Bazel toolchain.
