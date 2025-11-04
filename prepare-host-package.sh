set -e
umask 022
DEBIAN_CODENAME="bookworm"
sudo apt update
sudo apt install -y mmdebstrap systemd-container debian-archive-keyring
cat << EOL > /tmp/debian.sources
Types: deb deb-src
URIs: https://deb.debian.org/debian/
Suites: $DEBIAN_CODENAME $DEBIAN_CODENAME-updates
Components: main contrib
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb deb-src
URIs: https://security.debian.org/debian-security/
Suites: $DEBIAN_CODENAME-security
Components: main contrib
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOL
cat /tmp/debian.sources | sudo mmdebstrap --keyring=/usr/share/keyrings --arch=arm64 --include $(</tmp/chroot-packages.txt) "$DEBIAN_CODENAME" /var/lib/machines/arm64-debian -
echo "Container successfully created"

