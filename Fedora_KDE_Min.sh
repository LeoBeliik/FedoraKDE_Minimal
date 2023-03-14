#!/bin/bash

# Need for super user
if ! [ $(id -u) = 0 ]; then
  echo "You forgot sudo"
  exit 1
fi

# Make backup of the dnf configs
cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.bak

# Add custom configs to dnf.conf
echo '# Custom dnf configs' >> /etc/dnf/dnf.conf
echo fastestmirror=True >> /etc/dnf/dnf.conf
echo max_parallel_downloads=10 >> /etc/dnf/dnf.conf
echo defaultyes=True >> /etc/dnf/dnf.conf
echo keepcache=True >> /etc/dnf/dnf.conf

# Enable Zawertun's KDE for latest updates
dnf copr enable @zawertun/kde -y

dnf update -y

# Install rpm fusion
dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

dnf groupupdate core -y

# Codecs Install
dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y

dnf groupupdate sound-and-video -y

dnf swap mesa-va-drivers mesa-va-drivers-freeworld -y
dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld -y

# Min install of KDE (ish)
dnf install @"base-x" @"Fonts" @"Hardware Support" breeze-gtk breeze-icon-theme colord-kde dolphin kcm_systemd kde-gtk-config kde-settings-pulseaudio kde-style-breeze kdnssd kf5-baloo-file khotkeys kmenuedit konsole5 kscreen kscreenlocker ksysguard kwin plasma-breeze plasma-desktop plasma-nm plasma-pa plasma-user-manager plasma-workspace plasma-workspace-geolocation qt5-qtbase-gui qt5-qtdeclarative sddm sddm-breeze firefox -y

# Set SDDM as greeter
systemctl enable sddm
systemctl set-default graphical.target

# Clean unused packages
dnf remove plasma-welcome*
dnf remove qt-qdbusviewer*
dnf autoremove -y

# Done
reboot
