# Copyright 2019 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Dependencies for the Rust `bindgen` rules"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//bindgen/3rdparty/crates:defs.bzl", "crate_repositories")

# buildifier: disable=unnamed-macro
def rust_bindgen_dependencies():
    """Declare dependencies needed for bindgen."""

    # nb. The bindgen rule itself should work on any platform.
    _bindgen_clang_repositories()

    crate_repositories()

# buildifier: disable=unnamed-macro
def rust_bindgen_register_toolchains(register_toolchains = True):
    """Registers the default toolchains for the `rules_rust` [bindgen][bg] rules.

    [bg]: https://rust-lang.github.io/rust-bindgen/

    Args:
        register_toolchains (bool, optional): Whether or not to register toolchains.
    """
    if register_toolchains:
        native.register_toolchains(str(Label("//bindgen:default_bindgen_toolchain")))

# buildifier: disable=unnamed-macro
def rust_bindgen_repositories():
    """**Deprecated**: Instead use [rust_bindgen_dependencies](#rust_bindgen_dependencies) and [rust_bindgen_register_toolchains](#rust_bindgen_register_toolchains)"""

    rust_bindgen_dependencies()
    rust_bindgen_register_toolchains()

_COMMON_WORKSPACE = """\
workspace(name = "{}")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_cc",
    urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.1/rules_cc-0.0.1.tar.gz"],
    sha256 = "4dccbfd22c0def164c8f47458bd50e0c7148f3d92002cdb459c2a96a68498241",
)
"""

_CLANG_BUILD_FILE = """\
load("@rules_cc//cc:defs.bzl", "cc_import")

package(default_visibility = ["//visibility:public"])

sh_binary(
    name = "clang",
    srcs = ["bin/clang"],
)

cc_import(
    name = "libclang",
    shared_library = "lib/libclang.{suffix}",
)

alias(
    name = "libclang.so",
    actual = ":libclang",
    deprecation = "Use :libclang instead",
)

cc_import(
    name = "libc++",
    shared_library = "lib/libc++.{suffix}"
)
"""

def _bindgen_clang_repositories():
    # Releases @ http://releases.llvm.org/download.html
    # wait for llvm-15-0-0 for x86_64 uploaded
    # https://discourse.llvm.org/t/llvm-15-0-0-release/65099/9
    maybe(
        http_archive,
        name = "bindgen_clang_x86_64_linux",
        urls = ["https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.0/clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz"],
        strip_prefix = "clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04",
        build_file_content = _CLANG_BUILD_FILE.format(suffix = "so"),
        workspace_file_content = _COMMON_WORKSPACE.format("bindgen_clang_x86_64_linux"),
    )

    maybe(
        http_archive,
        name = "bindgen_clang_x86_64_osx",
        urls = ["https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.0/clang+llvm-15.0.0-x86_64-apple-darwin.tar.xz"],
        strip_prefix = "clang+llvm-15.0.0-x86_64-apple-darwin",
        build_file_content = _CLANG_BUILD_FILE.format(suffix = "dylib"),
        workspace_file_content = _COMMON_WORKSPACE.format("bindgen_clang_x86_64_osx"),
    )

    maybe(
        http_archive,
        name = "bindgen_clang_arm64_osx",
        urls = ["https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.0/clang+llvm-15.0.0-arm64-apple-darwin21.0.tar.xz"],
        strip_prefix = "clang+llvm-15.0.0-arm64-apple-darwin21.0",
        build_file_content = _CLANG_BUILD_FILE.format(suffix = "dylib"),
        workspace_file_content = _COMMON_WORKSPACE.format("bindgen_clang_arm64_osx"),
    )
