set -e
umask 022
sudo apt update
sudo apt install -y mmdebstrap systemd-container debian-archive-keyring
sudo apt remove -y mmdebstrap
git clone https://gitlab.mister-muffin.de/josch/mmdebstrap.git
chmod a+x ./mmdebstrap/mmdebstrap
sudo mmdebstrap --arch=arm64 --include sudo,curl,build-essential,devscripts,protobuf-compiler,python3,python3-venv,ninja-build,generate-ninja,cmake,git,nodejs,sccache trixie /var/lib/machines/arm64-debian http://deb.debian.org/debian
echo "Container successfully created"

