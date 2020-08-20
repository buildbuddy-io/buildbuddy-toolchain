load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def buildbuddy_deps():
    maybe(
        http_archive,
        name = "rules_cc",
        sha256 = "b6f34b3261ec02f85dbc5a8bdc9414ce548e1f5f67e000d7069571799cb88b25",
        strip_prefix = "rules_cc-726dd8157557f1456b3656e26ab21a1646653405",
        urls = ["https://github.com/bazelbuild/rules_cc/archive/726dd8157557f1456b3656e26ab21a1646653405.tar.gz"],
    )
