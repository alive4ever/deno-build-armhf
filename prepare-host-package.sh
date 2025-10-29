set -e
umask 022
sudo apt update
sudo apt upgrade -y
sudo apt install -y mmdebstrap systemd-container debian-archive-keyring
( cd /var/tmp/ && \
	curl -sSLO http://raspbian.raspberrypi.com/raspbian/pool/main/r/raspbian-archive-keyring/raspbian-archive-keyring_20120528.4_all.deb && \
	sudo apt install -y ./raspbian-archive-keyring_20120528.4_all.deb && \
	cd - )
RASPBIAN_KEYRING="/usr/share/keyrings/raspbian-archive-keyring.gpg"
if ! [ -r "$RASPBIAN_KEYRING" ]; then
echo "Unable to access $RASPBIAN_KEYRING"
exit 255
fi
sudo mmdebstrap --arch=armhf --keyring="$RASPBIAN_KEYRING" --include sudo,curl,build-essential,devscripts,clang,protobuf-compiler,python3,python3-venv,ninja-build,generate-ninja,cmake,git,nodejs trixie /var/lib/machines/armhf-raspbian http://raspbian.raspberrypi.com/raspbian
echo "Container successfully created"

