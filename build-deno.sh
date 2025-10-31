set -e
HOME="/home/$(whoami)"
cd $HOME
umask 022
DENO_VERSION="v2.5.5"
V8_VERSION="v140.2.0"
CLANG_VERSION="21"
export CLANG_BASE_PATH="/usr/lib/llvm-$CLANG_VERSION"
PATH="$CLANG_BASE_PATH/bin:$PATH"
PREFIX="arm-linux-gnueabihf"
export CC="clang"
export CXX="clang++"
PLATFORM="$($CC -dumpmachine)"
export V8_FROM_SOURCE=1
export GN="$(command -v gn)"
export NINJA="$(command -v ninja)"
export SCCACHE="$(command -v sccache)"
export LIBCLANG_PATH="/usr/lib/llvm-$CLANG_VERSION/lib"
export EXTRA_GN_ARGS="clang_version=\"$CLANG_VERSION\" target_cpu=\"arm\" v8_target_cpu=\"arm\" host_toolchain=\"//build/toolchain/linux/unbundle:default\" custom_toolchain=\"//build/toolchain/linux/unbundle:default\" v8_enable_pointer_compression=\"false\""
export PRINT_GN_ARGS=1
export TARGET="armv7-unknown-linux-gnueabihf"
export CARGO_CFG_TARGET_ARCH="$TARGET"
export CARGO_BUILD_TARGET="$TARGET"

curl -L -o rustup-install.sh https://sh.rustup.rs
sh rustup-install.sh -y -t "$TARGET" --default-toolchain 1.90.0
. $HOME/.cargo/env
rustc --version
cargo --version
rustup target add "$TARGET"
git clone --depth=1 --branch="$V8_VERSION" https://github.com/denoland/rusty_v8
cd ./rusty_v8
git config -f .gitmodules submodule.v8.shallow true
git submodule update --init --recursive
echo "Patching rusty_v8 BUILD.gn..."
git apply /tmp/hosttmp/compiler-rt-adjust-paths.patch
cd -
git clone --depth=1 --branch="$DENO_VERSION" https://github.com/denoland/deno
cd ./deno
mkdir -p /tmp/hosttmp/deno_deb
cargo build --target "$TARGET" --release
echo "Build succeeded at $(date -u)"
podman run --rm -v ./target/release/deno:/bin/deno arm32v7/busybox deno run tests/testdata/run/002_hello.ts
echo "Hello test succeeded"
TGZNAME="deno-"$DENO_VERSION"-"$PLATFORM".tar.gz"
tar --numeric-owner -C ./target/release/ -cf - . | gzip -n > /tmp/hosttmp/deno_deb/"$TGZNAME"
(cd /tmp/hosttmp/deno_deb && sha256sum "$TGZNAME" | tee "$TGZNAME".sha256sum && cd -)
cargo install cargo-deb
cargo deb --target "$TARGET"
DEBNAME=$(basename $(find ./target/debian -name '*.deb'))
cp -v ./target/debian/"$DEBNAME" /tmp/hosttmp/deno_deb/
(cd /tmp/hosttmp/deno_deb && sha256sum "$DEBNAME" | tee "$DEBNAME".sha256sum && cd -)
