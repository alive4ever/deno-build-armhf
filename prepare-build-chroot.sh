export DEBIAN_FRONTEND="noninteractive"
DEBIAN_CODENAME="bookworm"
echo "deb http://apt.llvm.org/$DEBIAN_CODENAME/ llvm-toolchain-$DEBIAN_CODENAME-20 main" > /etc/apt/sources.list.d/llvm.list
curl -sSL https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
apt-get update
apt-get install -y lld-20 clang-20 clang-tools-20 clang-tidy-20 clang-format-20 libclang-20-dev
apt-get build-dep -y chromium
useradd -m -G sudo -s /bin/bash builder
passwd -d builder
