#########################################################
#                         ADMIN                         #
#########################################################
 
# Switch to admin account
su - admin
 
# Once in admin acct:
# Update
sudo pacman -Syyu
 
# Install desired packages, separated for readability
sudo pacman -S pacman-contrib piper xfce4-whiskermenu-plugin udiskie mkvtoolnix-cli ffmpeg cdrkit xdg-user-dirs zip numlockx unrar vlc gparted samba ntfs-3g firefox gnome-disk-utility baobab galculator p7zip psensor syncthing nm-connection-editor virt-manager qemu-desktop libvirt edk2-ovmf dnsmasq iptables-nft networkmanager libwmf libopenraw libavif libheif libjxl librsvg webp-pixbuf-loader mame-tools pcsclite aribb25 aribb24 projectm libgoom2 lirc sdl_image libtiger libkate zvbi lua52-socket libmicrodns protobuf ttf-dejavu smbclient libmtp vcdimager libgme libva-intel-driver libva-vdpau-driver libdc1394 reflector
# sudo pacman -S chromium qbittorrent yt-dlp gftp obs-studio virt-viewer handbrake 

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
 
# Use colab instead since this doesn't support AMD GPUs and ends up using the CPU
# Install demucs
# pip3 install --user -U demucs
# python3 -m demucs -d cpu PATH_TO_AUDIO_FILE_1
 
# Enable Super key
#echo "xcape -e 'Super_L=Alt_L|F1'" >> ~/.bashrc
 
# Install yay
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd ..
# Remove yay's source folder
rm -rf ./yay-bin
 
# Install needed AUR packages
# screendimmer still doesn't work
yay -S wsdd2
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

mousepad /etc/samba/smb.conf

echo '[Unit]
Description=Automount removable media using udiskie
After=network.target

[Service]
ExecStart=/usr/bin/udiskie -a --no-notify
Restart=always
User=root
Group=root
PermissionsStartOnly=true
ExecStartPre=/bin/chmod -R a+rwX /mnt/storage-hdd
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target' >> /etc/systemd/system/udiskie.service

systemctl enable --now udiskie.service

# Set swappiness
echo 'vm.swappiness = 200' >> /etc/sysctl.d/99-swappiness.conf
 
#########################################################
#                          USER                         #
#########################################################
 
# Switch to user for operations that need to be done as non-sudo user
 
#echo "xcape -e 'Super_L=Alt_L|F1'" >> ~/.bashrc
systemctl enable --now syncthing.service --user
systemctl enable --now smb.service
systemctl enable --now wsdd2.service
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
xfconf-query -c xfwm4 -p /general/theme -s Aguamelon
xfconf-query -c xfwm4 -p /general/easy_click -s none
xdg-user-dirs-update

#########################################################
#                          UTIL                         #
#########################################################

# Fix mirrors (pacman/yay slow download)
# cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bkp
# sudo reflector --country 'United States' --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
