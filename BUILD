exports_files(
    glob(
        ["*"],
        exclude = ["BUILD"],
    ),
)

# This filegroup collects all parent workspace files needed by child workspaces
# for integration tests
filegroup(
    name = "local_repository_files",
    srcs = [
        ".bazelversion",
    ] + glob(["*"], exclude = [".bazelversion"]) + [
        "//platforms:all_files",
        "//templates:all_files",
        "//toolchains/cc:all_files",
    ],
    visibility = ["//:__subpackages__"],
)
