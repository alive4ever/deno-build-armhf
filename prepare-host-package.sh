set -e
umask 022
DEBIAN_CODENAME="bookworm"
sudo apt update
sudo apt install -y mmdebstrap systemd-container debian-archive-keyring
sudo mmdebstrap --arch=arm64 --include sudo,curl,build-essential,devscripts,protobuf-compiler,python3,python3-venv,ninja-build,generate-ninja,cmake,git,nodejs,sccache,gcc-arm-linux-gnueabihf,podman,pkg-config,lsb-release "$DEBIAN_CODENAME" /var/lib/machines/arm64-debian http://deb.debian.org/debian
echo "Container successfully created"

