set -e
HOME="/home/$(whoami)"
cd $HOME
umask 022
DENO_VERSION="v2.5.5"
PLATFORM="$(cc -dumpmachine)"
git clone --depth=1 --branch="$DENO_VERSION" https://github.com/denoland/deno
curl -L -o rustup-install.sh https://sh.rustup.rs
sh rustup-install.sh -y
rustc --version
cargo --version
cd ./deno
mkdir -p /tmp/hosttmp/deno_deb
cargo build --release
./target/release/deno run tests/testdata/run/002_hello.ts
TGZNAME="deno-"$DENO_VERSION"-"$PLATFORM".tar.gz"
tar --numeric-owner -C ./target/release/ -cf - . | gzip -n > /tmp/hosttmp/deno_deb/"$TGZNAME"
(cd /tmp/hosttmp/deno_deb && sha256sum "$TGZNAME" | tee "$TGZNAME".sha256sum && cd -)
cargo install cargo-deb
cargo deb 
DEBNAME=$(basename $(find ./target/debian -name '*.deb'))
cp -v ./target/debian/"$DEBNAME" /tmp/hosttmp/deno_deb/
(cd /tmp/hosttmp/deno_deb && sha256sum "$DEBNAME" | tee "$DEBNAME".sha256sum && cd -)
