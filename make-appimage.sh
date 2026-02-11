#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q riseup-vpn | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/128x128/apps/riseup-vpn.png
export DESKTOP=/usr/share/applications/riseup-vpn.desktop
export DEPLOY_SYS_PYTHON=1

# Deploy dependencies
quick-sharun \
	/usr/bin/riseup-vpn \
	/usr/bin/bitmask-root

dst=./AppDir/share/polkit-1/actions
mkdir -p "$dst"
cp -v /usr/share/polkit-1/actions/se.leap.bitmask.policy "$dst"
sed -i -e 's|/usr/sbin|/usr/local/sbin|g' "$dst"/se.leap.bitmask.policy

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
#quick-sharun --test ./dist/*.AppImage
