load("//:rules.bzl", bb_macro = "buildbuddy")

buildbuddy = module_extension(lambda _: bb_macro(name = "buildbuddy_toolchains", gcc_version = "13"))
