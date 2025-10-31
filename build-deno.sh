set -e
HOME="/home/$(whoami)"
cd $HOME
umask 022
DENO_VERSION="v2.5.5"
V8_VERSION="v140.2.0"
PREFIX="arm-linux-gnueabihf"
PATH="/usr/${PREFIX}/bin:$PATH"
export CC="$PREFIX-gcc"
export CXX="$PREFIX-g++"
PLATFORM="$($CC -dumpmachine)"
export V8_FROM_SOURCE=1
export GN="$(command -v gn)"
export NINJA="$(command -v ninja)"
export SCCACHE="$(command -v sccache)"
CLANG_VERSION=$(clang -dumpversion | cut -d . -f 1)
export DISABLE_CLANG=1
export GN_ARGS="target_cpu=\"arm\" v8_target_cpu=\"arm\""
export PRINT_GN_ARGS=1
export TARGET="armv6-unknown-linux-gnueabihf"

curl -L -o rustup-install.sh https://sh.rustup.rs
sh rustup-install.sh -y
. $HOME/.cargo/env
rustc --version
cargo --version
rustup target add "$TARGET"
git clone --depth=1 --branch="$V8_VERSION" https://github.com/denoland/rusty_v8
cd ./rusty_v8
git config -f .gitmodules submodule.v8.shallow true
git submodule update --init --recursive
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
