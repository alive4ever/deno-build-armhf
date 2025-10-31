export DEBIAN_FRONTEND="noninteractive"
echo "deb http://apt.llvm.org/trixie/ llvm-toolchain-trixie-21 main" > /etc/apt/sources.list.d/llvm.list
curl -sSL https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
apt update
apt install -y lld-21 clang-21 clang-tools-21 clang-tidy-21 clang-format-21 libclang-21-dev
useradd -m -G sudo -s /bin/bash builder
passwd -d builder
