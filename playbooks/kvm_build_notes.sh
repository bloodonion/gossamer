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

#create new bridge
sudo nmcli connection add type bridge con-name br0 ifname br0
# add a physical interface to the bridge
sudo nmcli connection add type bridge-slave ifname <interfaceName> master br0
# modify connection to use dhcp for ip address -- stay static ?
sudo nmcli connection modify br0 ipv4.method auto
# or... ooorr
sudo nmcli connection modify br0 ipv4.addresses [IP_address/subnet]
sudo nmcli connection modify br0 ipv4.gateway [gateway]
sudo nmcli connection modify br0 ipv4.dns [DNS]
sudo nmcli connection modify br0 ipv4.method manual


# bring bridge up 
sudo nmcli connection up br0
# verify
ip addr show br0

# CREATE VM
sudo yum -y install virt-install
#Adjust user permissions to allow hypervisor to use the iso
sudo setfacl -m u:qemu:x [file_location]

sudo virt-install --name=ubuntu --ram=3072 --vcpus=2 --file=/var/lib/libvirt/images/ubuntu.img,size=20 --cdrom=Downloads/ubuntu-24.04.1-desktop-amd64.iso --network bridge=br0


# --name=	Custom name of the VM
# --ram=	Allocated RAM
# --vcpu=	Number of virtual CPUs
# --file=	Disk file/image location
# --size=	Allocated file size of the VM
# --cdrom=	Installation media
# --network bridge=	Network used for the VM