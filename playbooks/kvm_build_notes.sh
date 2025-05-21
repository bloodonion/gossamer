#!/bin/bash

# Check for virualization support.
cat /proc/cpuinfo | egrep "vmx|svm"

# Instal

sudo dnf groupinstall "Virtualization Host"

# enablie libvirtd service
sudo systemctl enable --now libvirtd


# installing tools
sudo yum -y install virt-top libguestfs-tools

#verify KVM installation
lsmod | grep kvm

## NETWORKING

sudo nmcli connection show
sudo nmcli connection delete <interface_name>

# delete physical
# make bridge
# add physical to bridge
# assign dhcp or static to bridge

#create new bridge
sudo nmcli connection add type bridge con-name br0 ifname br0

sudo nmcli connection add type bridge-slave ifname eno1 master bridge0
# add a physical interface to the bridge
nmcli c add type bridge-slave ifname eno1 master bridge0
# modify connection to use dhcp for ip address -- stay static ?
sudo nmcli connection modify bridge0 ipv4.method auto
# or... ooorr
sudo nmcli connection modify br0 ipv4.addresses [IP_address/subnet]
sudo nmcli connection modify br0 ipv4.gateway [gateway]
sudo nmcli connection modify br0 ipv4.dns [DNS]
sudo nmcli connection modify br0 ipv4.method manual


# bring bridge up 
sudo nmcli connection up bridge0
# verify
ip addr show bridge0

# download dependancies - sudo dnf download --downloaddir=. --resolve virt-install
# CREATE VM
sudo yum -y install virt-install
#Adjust user permissions to allow hypervisor to use the iso
sudo setfacl -m u:qemu:x [file_location]

sudo virt-install --name=rocky9virt --ram=3072 --vcpus=2 --file=/var/lib/libvirt/images/rocky9virt.img,size=20 --cdrom=--cdrom=/tmp/Rocky-9.5-x86_64-minimal.iso  --network bridge=bridge0
sudo virt-install --name=rocky9virt --ram=3072 --vcpus=2 --disk path=/var/lib/libvirt/images/rocky9virt.img,size=20 --cdrom=/var/lib/libvirt/images/Rocky-9.5-x86_64-minimal.iso --network bridge=bridge0 --boot cdrom,hd --extra-args="ks=file:/ks.cfg"

# --name=	Custom name of the VM
# --ram=	Allocated RAM
# --vcpu=	Number of virtual CPUs
# --file=	Disk file/image location
# --size=	Allocated file size of the VM
# --cdrom=	Installation media
# --network bridge=	Network used for the VM

sudo cat /var/lib/libvirt/dnsmasq/bridge0.leases

arp -an

sudo nmap -sn 192.168.1.0/24

# need a kickstart file or extra options
sudo virsh console rocky9virt


#SE for kickstart 
sudo chcon -t virt_content_t /var/lib/libvirt/images/ks.cfg
sudo mv /tmp/Rocky-9.5-x86_64-minimal.iso /var/lib/libvirt/images/
sudo chcon -t virt_content_t /var/lib/libvirt/images/Rocky-9.5-x86_64-minimal.iso

#advanced kickstart file
part /boot --fstype=ext4 --size=1024
part pv.01 --size=18000 --grow
volgroup vg_root pv.01
logvol / --fstype=ext4 --size=10000 --name=root --vgname=vg_root
logvol swap --fstype=swap --size=2048 --name=swap --vgname=vg_root


sudo cat /var/log/libvirt/qemu/rocky9virt.log

sudo virsh net-list --all
