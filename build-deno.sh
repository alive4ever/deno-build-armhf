set -e
HOME="/home/$(whoami)"
cd $HOME
umask 022
DENO_VERSION="v2.5.5"
V8_VERSION="v140.2.0"
CLANG_VERSION="19"
PYTHON_VERSION="3.13"
export CLANG_BASE_PATH="/usr/lib/llvm-$CLANG_VERSION"
PATH="$CLANG_BASE_PATH/bin:$PATH"
PREFIX="arm-linux-gnueabihf"
CLANG_TARGET="armv7-unknown-linux-gnu"
export CC="clang -target $CLANG_TARGET -fuse-ld=lld"
export CXX="clang++ -target $CLANG_TARGET -fuse-ld=lld"
PLATFORM="$($CC -dumpmachine)"
export RUST_WRAPPER="sccache"
export RUST_BACKTRACE=1
export V8_FROM_SOURCE=1
export SCCACHE="$(command -v sccache)"
export LIBCLANG_PATH="/usr/lib/llvm-$CLANG_VERSION/lib"
export EXTRA_GN_ARGS="clang_version=\"$CLANG_VERSION\" target_cpu=\"arm\" v8_target_cpu=\"arm\" host_toolchain=\"//build/toolchain/linux/unbundle:default\" custom_toolchain=\"//build/toolchain/linux/unbundle:default\" v8_enable_pointer_compression=\"false\""
export PRINT_GN_ARGS=1
RUST_TARGET="armv7-unknown-linux-gnueabihf"
export CARGO_CFG_TARGET_ARCH="$RUST_TARGET"
export CARGO_BUILD_TARGET="$RUST_TARGET"

curl -L -o rustup-install.sh https://sh.rustup.rs
sh rustup-install.sh -y -t "$RUST_TARGET" --default-toolchain 1.90.0
. $HOME/.cargo/env
rustc --version
cargo --version
rustup target add "$RUST_TARGET"
curl -L -o uv-install.sh https://astral.sh/uv/install.sh
sh uv-install.sh
. $HOME/.local/bin/env
uv --version
uv python install "$PYTHON_VERSION"
python"$PYTHON_VERSION" --version
uv venv
. ./.venv/bin/activate
uv pip install -U setuptools pip jinja2
pip --version
git clone --depth=1 --branch="$V8_VERSION" https://github.com/denoland/rusty_v8
cd ./rusty_v8
git config -f .gitmodules submodule.v8.shallow true
git submodule update --init --recursive
cd -
git clone --depth=1 --branch="$DENO_VERSION" https://github.com/denoland/deno
cd ./deno
mkdir -p /tmp/hosttmp/deno_deb
cargo build --target "$RUST_TARGET" --release
echo "Build succeeded at $(date -u)"
podman run --rm -v ./target/release/deno:/bin/deno arm32v7/busybox deno run tests/testdata/run/002_hello.ts
echo "Hello test succeeded"
TGZNAME="deno-"$DENO_VERSION"-"$PLATFORM".tar.gz"
tar --numeric-owner -C ./target/release/ -cf - . | gzip -n > /tmp/hosttmp/deno_deb/"$TGZNAME"
(cd /tmp/hosttmp/deno_deb && sha256sum "$TGZNAME" | tee "$TGZNAME".sha256sum && cd -)
cargo install cargo-deb
cargo deb --target "$RUST_TARGET"
DEBNAME=$(basename $(find ./target/debian -name '*.deb'))
cp -v ./target/debian/"$DEBNAME" /tmp/hosttmp/deno_deb/
(cd /tmp/hosttmp/deno_deb && sha256sum "$DEBNAME" | tee "$DEBNAME".sha256sum && cd -)
