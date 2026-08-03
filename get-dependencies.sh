#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	go              \
	cmake           \
	pkgconf         \
	qt6-declarative \
	qt6-svg         \
	qt6-tools       \
	openvpn

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package riseup-vpn

echo "Building riseup-vpn from source..."
echo "---------------------------------------------------------------"
git clone https://0xacab.org/leap/bitmask-vpn.git ./bitmask-vpn && (
	cd ./bitmask-vpn

	git fetch --tags origin
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta' | head -1)
	git checkout "$TAG"
	echo "$TAG" > ~/version

	# use pkexec from PATH instead of hardcoded polkit agent paths
	git apply ../pkexec-polkit.patch

	# follow the XDG Base Directory spec for the config dirs
	# honor XDG_CONFING_HOME instead of hardcoding ~/.config
	git apply ../xdg-config-dirs.patch

	PROVIDER=riseup make vendor
	PROVIDER=riseup LRELEASE=/usr/lib/qt6/bin/lrelease RELEASE=yes make build

	install -Dm644 gui/resources/riseup-icon.svg          /usr/share/icons/hicolor/scalable/apps/riseup-vpn.svg
	install -Dm644 providers/riseup/assets/icon.png       /usr/share/icons/hicolor/128x128/apps/riseup-vpn.png
	install -Dm644 build/riseup/debian/riseup-vpn.desktop /usr/share/applications/riseup-vpn.desktop
	install -Dm644 helpers/se.leap.bitmask.policy         /usr/share/polkit-1/actions/se.leap.bitmask.policy
	install -Dm755 build/qt/release/riseup-vpn            /usr/bin/riseup-vpn
)
# overwrite bitmask-root with our bash rewrite
cp -v ./bitmask-root.sh /usr/bin/bitmask-root
chmod +x /usr/bin/bitmask-root
