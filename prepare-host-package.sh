set -e
umask 022
DEBIAN_CODENAME="trixie"
sudo apt update
sudo apt install -y mmdebstrap systemd-container debian-archive-keyring
cat << EOL > /tmp/debian.sources
deb http://deb.debian.org/debian/ $DEBIAN_CODENAME main contrib
deb-src http://deb.debian.org/debian/ $DEBIAN_CODENAME main contrib
deb http://deb.debian.org/debian/ $DEBIAN_CODENAME-updates main contrib
deb-src http://deb.debian.org/debian/ $DEBIAN_CODENAME-updates main contrib
deb http://security.debian.org/debian-security/ $DEBIAN_CODENAME-security main contrib
deb-src http://security.debian.org/debian-security/ $DEBIAN_CODENAME-security main contrib
EOL
cat /tmp/debian.sources | sudo mmdebstrap --keyring=/usr/share/keyrings --include "$(cat /tmp/chroot-packages.txt)" "$DEBIAN_CODENAME" /var/lib/machines/amd64-debian -
echo "Container successfully created"

