export DEBIAN_FRONTEND="noninteractive"
DEBIAN_CODENAME="bookworm"
apt-get update
apt-get build-dep -y chromium
useradd -m -G sudo -s /bin/bash builder
passwd -d builder
