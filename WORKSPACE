# workspace(
#     name = "buildbuddy_toolchain",
# )

load(":deps.bzl", "buildbuddy_deps")

buildbuddy_deps()
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "io_buildbuddy_buildbuddy_toolchain",
    integrity = "sha256-8a6zG52+4MM07qUI9oD6tcBreNUe8dvn1Cljwc3v6fM=",
    strip_prefix = "buildbuddy-toolchain-v0.0.2",
    urls = ["https://github.com/buildbuddy-io/buildbuddy-toolchain/releases/download/v0.0.2/buildbuddy-toolchain-v0.0.2.tar.gz"],
)