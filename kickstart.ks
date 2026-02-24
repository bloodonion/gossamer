# Rocky Linux 9 Kickstart - Install OS on the 400 GB NVMe drive (dynamic detection)
# Save as e.g. rocky9-400g.ks

%pre --interpreter=/bin/sh --log=/tmp/ks-pre.log
# Find the ~400 GB NVMe drive (the only one between ~300-500 GB)
BOOTDISK=""
for dev in /dev/nvme*n1; do
  if [ -b "$dev" ]; then
    size=$(blockdev --getsize64 "$dev" 2>/dev/null || echo 0)
    size_gb=$((size / 1024 / 1024 / 1024))
    if [ "$size_gb" -ge 300 ] && [ "$size_gb" -le 500 ]; then
      BOOTDISK=$(basename "$dev")
      echo "Found 400 GB boot drive: $BOOTDISK" >&2
      break
    fi
  fi
done

# Fallback: use the first NVMe if nothing matches (should never happen)
if [ -z "$BOOTDISK" ]; then
  echo "WARNING: No 400 GB drive found - using first NVMe" >&2
  BOOTDISK=$(ls /dev/nvme*n1 2>/dev/null | head -n 1 | xargs basename)
fi

# Write the dynamic storage section
cat > /tmp/storage.ks << EOF
# === DYNAMIC STORAGE CONFIG - OS on 400 GB drive only ===
ignoredisk --only-use=$BOOTDISK
zerombr
clearpart --all --initlabel --drives=$BOOTDISK --disklabel=gpt

# Bootloader on the correct drive (works for both UEFI and legacy)
bootloader --location=boot --boot-drive=$BOOTDISK --append="crashkernel=auto rhgb quiet"

# Automatic LVM partitioning (standard Rocky 9 layout: /boot/efi, /boot, /, swap, /home on large disk)
autopart --type=lvm
EOF
%end

# Include the dynamic storage commands right here
%include /tmp/storage.ks

# =============================================
# Rest of the Kickstart (customise as needed)
# =============================================

install
# Change to your preferred mirror or use "cdrom" if installing from ISO/USB
url --url="https://download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/"
repo --name="AppStream" --baseurl="https://download.rockylinux.org/pub/rocky/9/AppStream/x86_64/os/"

lang en_US.UTF-8
keyboard --vckeymap=us --xlayouts=us
timezone Australia/Sydney --isUtc   # or UTC if you prefer

# Network (DHCP on first interface - change if you need static)
network --bootproto=dhcp --device=link --activate --hostname=rocky9-server

# Root password - CHANGE THIS!
rootpw --plaintext ChangeThisToAStrongPassword123!

firewall --enabled --service=ssh
selinux --enforcing
services --enabled=sshd
firstboot --disable
reboot

%packages
@^minimal-environment
openssh-server
%end

# Optional %post - example: log which drive was used
%post
echo "OS was installed on /dev/$BOOTDISK (400 GB drive)" > /root/install-drive.log
%end
