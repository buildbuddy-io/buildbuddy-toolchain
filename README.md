# BuildBuddy RBE Toolchain

Currently supports Linux C/C++ (including CGO) & Java builds on Ubuntu 16.04.

## Usage instructions

Add the following lines to your `WORKSPACE` file. You'll probably want to pin your version to a specific commit rather than master.
```
http_archive(
    name = "io_buildbuddy_buildbuddy_toolchain",
    sha256 = "a2a5cccec251211e2221b1587af2ce43c36d32a42f5d881737db3b546a536510",
    strip_prefix = "buildbuddy-toolchain-829c8a574f706de5c96c54ca310f139f4acda7dd",
    urls = ["https://github.com/buildbuddy-io/buildbuddy-toolchain/archive/829c8a574f706de5c96c54ca310f139f4acda7dd.tar.gz"],
)

load("@io_buildbuddy_buildbuddy_toolchain//:deps.bzl", "buildbuddy_deps")

buildbuddy_deps()

load("@io_buildbuddy_buildbuddy_toolchain//:rules.bzl", "buildbuddy")

buildbuddy(name = "buildbuddy_toolchain")
```

Now you can use the toolchain in your BuildBuddy RBE builds. For example:
```
bazel build server --remote_executor=cloud.buildbuddy.io --crosstool_top=@buildbuddy_toolchain//:toolchain
```

If you need Java 8 support, you just need to add a few more flags:
```
--javabase=@buildbuddy_toolchain//:javabase_jdk8
--host_javabase=@buildbuddy_toolchain//:javabase_jdk8
--java_toolchain=@buildbuddy_toolchain//:toolchain_jdk8
```

## Coming soon

Ubuntu 18.04, and Darwin (Mac) support are on our roadmap.

## Additional resources

- For more advanced use cases, check out Bazel's [bazel-toolchains repo](https://github.com/bazelbuild/bazel-toolchains) and the [docs on configuring C++ toolchains](https://docs.bazel.build/versions/master/tutorial/cc-toolchain-config.html).
- Many thanks to the team at Grail who's [LLVM toolchain repo](https://github.com/grailbio/bazel-toolchain) served as the basis for this repo.
- Major props to the team at VSCO who's [toolchain repo](https://github.com/vsco/bazel-toolchains) paved the way for using LLVM as a Bazel toolchain.
