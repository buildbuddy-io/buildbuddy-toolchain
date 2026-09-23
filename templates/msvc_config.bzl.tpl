MSVC_ROOT = "C:\\Program Files\\Microsoft Visual Studio\\%{msvc_release}\\%{msvc_edition}"
MSVC_TOOLS_ROOT = MSVC_ROOT + "\\VC\\Tools\\MSVC\\%{msvc_version}"

WINDOWS_KITS_ROOT = "C:\\Program Files (x86)\\Windows Kits\\%{windows_kits_release}"
WINDOWS_KITS_INCLUDE_ROOT = WINDOWS_KITS_ROOT + "\\Include\\%{windows_kits_version}"
WINDOWS_KITS_LIB_ROOT = WINDOWS_KITS_ROOT + "\\Lib\\%{windows_kits_version}"

MSVC_ENV_TMP = "%{msvc_env_tmp}"

MSVC_ENV_PATHS = [
    MSVC_ROOT + "\\Common7\\IDE\\",
    MSVC_ROOT + "\\Common7\\IDE\\CommonExtensions\\Microsoft\\FSharp\\Tools",
    MSVC_ROOT + "\\Common7\\IDE\\CommonExtensions\\Microsoft\\TeamFoundation\\Team Explorer",
    MSVC_ROOT + "\\Common7\\IDE\\CommonExtensions\\Microsoft\\TestWindow",
    MSVC_ROOT + "\\Common7\\IDE\\VC\\Linux\\bin\\ConnectionManagerExe",
    MSVC_ROOT + "\\Common7\\IDE\\VC\\VCPackages",
    MSVC_ROOT + "\\Common7\\Tools\\",
    MSVC_ROOT + "\\MSBuild\\Current\\bin\\Roslyn",
    MSVC_ROOT + "\\Team Tools\\DiagnosticsHub\\Collector",
    MSVC_TOOLS_ROOT + "\\bin\\HostX64\\x64",
    MSVC_ROOT + "\\MSBuild\\Current\\Bin\\amd64",
]

MSVC_BUILTIN_INCLUDE_PATHS = [
    # keep sorted
    WINDOWS_KITS_INCLUDE_ROOT + "\\cppwinrt",
    WINDOWS_KITS_INCLUDE_ROOT + "\\shared",
    WINDOWS_KITS_INCLUDE_ROOT + "\\ucrt",
    WINDOWS_KITS_INCLUDE_ROOT + "\\um",
    WINDOWS_KITS_INCLUDE_ROOT + "\\winrt",
    MSVC_ROOT + "\\VC\\Auxiliary\\VS\\include",
    MSVC_TOOLS_ROOT + "\\include",
]

MSVC_ENV_LIB_PATHS = [
    WINDOWS_KITS_LIB_ROOT + "\\um\\x64",
    WINDOWS_KITS_LIB_ROOT + "\\ucrt\\x64",
    MSVC_TOOLS_ROOT + "\\lib\\x64",
]
