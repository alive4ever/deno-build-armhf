export DEBIAN_FRONTEND="noninteractive"
DEBIAN_CODENAME="bookworm"
apt-get update
apt-get build-dep -y chromium
apt-get install -y $(cat /tmp/hosttmp/chroot-packages.txt | tr \, \\n)
useradd -m -G sudo -s /bin/bash builder
passwd -d builder
