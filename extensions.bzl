load("//:rules.bzl", bb_macro = "buildbuddy")

def _impl(mctx):
    pass

buildbuddy = module_extension(lambda _: bb_macro(name = "buildbuddy_toolchain"))
