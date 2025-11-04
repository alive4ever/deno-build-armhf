set -e
umask 022
DEBIAN_CODENAME="bookworm"
sudo apt update
sudo apt install -y mmdebstrap systemd-container debian-archive-keyring
cat << EOL > /tmp/debian.sources
deb https://deb.debian.org/debian/ $DEBIAN_CODENAME main contrib
deb-src https://deb.debian.org/debian/ $DEBIAN_CODENAME main contrib
deb https://deb.debian.org/debian/ $DEBIAN_CODENAME-updates main contrib
deb-src https://deb.debian.org/debian/ $DEBIAN_CODENAME-updates main contrib
deb https://security.debian.org/debian-security/ $DEBIAN_CODENAME-security main contrib
deb-src https://security.debian.org/debian-security/ $DEBIAN_CODENAME-security main contrib
EOL
cat /tmp/debian.sources | sudo mmdebstrap --keyring=/usr/share/keyrings --arch=arm64 --include "$(</tmp/chroot-packages.txt)" "$DEBIAN_CODENAME" /var/lib/machines/arm64-debian -
echo "Container successfully created"

