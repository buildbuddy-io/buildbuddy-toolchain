load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def buildbuddy_deps():
    maybe(
        http_archive,
        name = "rules_cc",
        sha256 = "d75a040c32954da0d308d3f2ea2ba735490f49b3a7aa3e4b40259ca4b814f825",
        urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.10-rc1/rules_cc-0.0.10-rc1.tar.gz"],
    )
