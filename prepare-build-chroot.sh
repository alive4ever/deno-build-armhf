export DEBIAN_FRONTEND="noninteractive"
DEBIAN_CODENAME="bookworm"
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
echo 'deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-21 main
deb-src http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-21 main
' | tee /etc/apt/sources.list.d/llvm.list
apt-get update
apt-get install -y $(cat /tmp/hosttmp/chroot-packages.txt | tr \, \\n)
apt-get install -y clang-21 lld-21 lldb-21
useradd -m -G sudo -s /bin/bash builder
passwd -d builder
