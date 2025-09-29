# Building a C++ binary with the BuildBuddy Toolchain

## Build locally, send build events to BuildBuddy UI

```
bazel build //:main \
    --bes_results_url=https://app.buildbuddy.io/invocation/ \
    --bes_backend=grpcs://remote.buildbuddy.io \
    --experimental_platform_in_output_dir
```

## Create a BuildBuddy API key for Remote Build Execution (RBE)
1. Login to or sign up for your [BuildBuddy account](https://app.buildbuddy.io/).
2. Visit the [quickstart page](https://app.buildbuddy.io/docs/setup/), check "Enable remote execution", and copy your API key.
3. Set a `BUILDBUDDY_API_KEY` environment variable.

## Build remotely for Linux x86_64

```
bazel build //:main \
    --bes_results_url=https://app.buildbuddy.io/invocation/ \
    --bes_backend=grpcs://remote.buildbuddy.io \
    --remote_executor=grpcs://remote.buildbuddy.io \
    --platforms=@toolchains_buildbuddy//platforms:linux_x86_64 \
    --extra_execution_platforms=@toolchains_buildbuddy//platforms:linux_x86_64 \
    --experimental_platform_in_output_dir \
    --remote_header="x-buildbuddy-api-key=${BUILDBUDDY_API_KEY}"
```

## Build remotely for Linux arm64

```
bazel build //:main \
    --bes_results_url=https://app.buildbuddy.io/invocation/ \
    --bes_backend=grpcs://remote.buildbuddy.io \
    --remote_executor=grpcs://remote.buildbuddy.io \
    --platforms=@toolchains_buildbuddy//platforms:linux_arm64 \
    --extra_execution_platforms=@toolchains_buildbuddy//platforms:linux_arm64 \
    --experimental_platform_in_output_dir \
    --remote_header="x-buildbuddy-api-key=${BUILDBUDDY_API_KEY}"
```
