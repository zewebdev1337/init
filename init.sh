#########################################################
#                         ADMIN                         #
#########################################################
 
# Switch to admin account
su - admin
 
# Once in admin acct:
# Update
sudo pacman -Syyu
 
# Install desired packages, separated for readability
sudo pacman -S pacman-contrib piper xfce4-whiskermenu-plugin ffmpeg cdrkit xdg-user-dirs zip numlockx
sudo pacman -S xcape ntfs-3g firefox vlc gparted gnome-disk-utility baobab galculator p7zip psensor syncthing nm-connection-editor
# Install virtualization packages, networkmanager is used to create a bridge, (Y) to replace, regarding iptables-nft conflict
sudo pacman -S virt-manager qemu-desktop libvirt edk2-ovmf dnsmasq iptables-nft networkmanager
# sudo pacman -S chromium qbittorrent yt-dlp gftp obs-studio virt-viewer handbrake 
# ristretto
sudo pacman -S libwmf libopenraw libavif libheif libjxl librsvg webp-pixbuf-loader
 
# Install all of VLCs optional dependencies to fix video playback (exclude install kwallet)
sudo pacman -S pcsclite aribb25 aribb24 projectm libgoom2 lirc sdl_image libtiger libkate zvbi lua52-socket libmicrodns protobuf ttf-dejavu smbclient libmtp vcdimager libgme libva-intel-driver libva-vdpau-driver libdc1394
 
# Fix Virt-Manager issues
sudo nano /etc/libvirt/qemu.conf
# Search and uncomment:
#user = "libvirt-qemu"
#group = "libvirt-qemu"
 
# Replace with:
# user = "user"
# group = "libvirt"
sudo systemctl restart libvirtd
sudo usermod -a -G libvirt user
 
# Create network bridge ONLY FOR ETHERNET
sudo systemctl enable --now NetworkManager
nmcli connection add type bridge ifname br0 stp no
nmcli connection add type bridge-slave ifname eno1 master br0
nmcli connection down eno1
nmcli connection up bridge-br0
nmcli connection up bridge-slave-eno1
 
# Create user folders
#xdg-user-dirs-update
 
# Use colab instead since this doesn't support AMD GPUs and ends up using the CPU
# Install demucs
# pip3 install --user -U demucs
# python3 -m demucs -d cpu PATH_TO_AUDIO_FILE_1
 
# Enable Super key
echo "xcape -e 'Super_L=Alt_L|F1'" >> ~/.bashrc
 
# Install yay
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd ..
# Remove yay's source folder
rm -rf ./yay-bin
 
# Install needed AUR packages
# screendimmer still doesn't work
# yay -S screendimmer
# yay -S yandex-browser kotatogram-desktop-bin tartube yacy
# yay -S ttf-vlgothic neo-matrix wmctrl
# Enable yacy service
# systemctl enable --now yacy.service
 
# Clean pacman & yay caches
sudo paccache -rk0
sudo rm -rf ~/.cache/yay/*
 
# Generate Lm_sensors report
# sensors-detect
 
# Enable vfio for GPU
sudo nano /etc/default/grub
# PASTE ON grub FILE: GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 intel_iommu=on vfio-pci.ids=1002:699f,1002:aae0"
 
# Rebuild GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg
 
exit
 
#########################################################
#                          ROOT                         #
#########################################################
 
# Switch to root for operations that can only be done as root
su
 
# Set VFIO
echo 'options vfio-pci ids=1002:699f,1002:aae0
softdep amdgpu pre: vfio-pci' >> /etc/modprobe.d/vfio.conf
 
# Rebuild initramfs
sudo mkinitcpio -p linux
sudo mkinitcpio -p linux-zen
sudo mkinitcpio -p linux-lts
sudo mkinitcpio -p linux-hardened
 
# Set swappiness
echo 'vm.swappiness = 200' >> /etc/sysctl.d/99-swappiness.conf
 
#########################################################
#                          USER                         #
#########################################################
 
# Switch to user for operations that need to be done as non-sudo user
 
echo "xcape -e 'Super_L=Alt_L|F1'" >> ~/.bashrc
systemctl enable --now syncthing.service --user
xfconf-query -c xfwm4 -p /general/easy_click -s none
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
xdg-user-dirs-update

# Enable numlock on boot
#rm -rf ~/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml
#echo '<?xml version="1.0" encoding="UTF-8"?>

#<channel name="keyboards" version="1.0">
#  <property name="Default" type="empty">
#    <property name="Numlock" type="bool" value="true"/>
#    <property name="RestoreNumlock" type="bool" value="true"/>
#  </property>
#</channel>
#' >> ~/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml
