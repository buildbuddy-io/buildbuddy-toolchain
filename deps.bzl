load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def buildbuddy_deps():
    maybe(
        http_archive,
        name = "rules_cc",
        integrity = "sha256-q8YF3YUPgTuzcAS3fbIBBqGTEalrLaHJK3idpSnSj+E=",
        urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.17/rules_cc-0.0.17.tar.gz"],
    )
