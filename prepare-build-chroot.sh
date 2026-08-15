set -e
export DEBIAN_FRONTEND="noninteractive"
DEBIAN_CODENAME="trixie"
umask 022
dpkg --add-architecture armhf
curl -L https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/apt.llvm.org.asc] https://apt.llvm.org/trixie/ llvm-toolchain-trixie-21 main
deb-src [signed-by=/etc/apt/trusted.gpg.d/apt.llvm.org.asc] https://apt.llvm.org/trixie/ llvm-toolchain-trixie-21 main
' | tee /etc/apt/sources.list.d/llvm.list
apt-get update
apt-get install -y $(cat /tmp/hosttmp/chroot-packages.txt | tr \, \\n)
apt-get update
apt-get install -y clang-21 lld-21 lldb-21
apt-get install -y libc6:armhf libstdc++6:armhf lib32gcc-s1 lib32stdc++6 libglib2.0-dev:armhf zlib1g-dev:armhf libzstd-dev:armhf lib32ncurses-dev libncurses-dev:armhf libncursesw6:armhf linux-headers-armmp:armhf
useradd -m -G sudo -s /bin/bash builder
passwd -d builder
