#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <BaseImageOutputPath> <CloudInitPath> <VMName> <RamAmount> <VCPUs> <DiskSize>"
    echo "Example: $0 /path/to/image/ /path/to/your/cloud-init.yaml vmNameHere 4096 2 20G"
}

# Check if all required arguments are provided
if [ "$#" -ne 6 ]; then
    usage
    exit 1
fi

# Assign arguments to variables
BASE_IMG_DIR="$1"
CLOUD_INIT_FILE="$2"
VM_NAME="$3"
RAM="$4"
VCPUS="$5"
DISK_SIZE="$6"

# Ensure required directories exist
mkdir -p "$BASE_IMG_DIR"

# Install required packages
echo "Installing required packages..."
sudo apt update && sudo apt install -y cloud-image-utils qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst

# Download Ubuntu cloud image
UBUNTU_IMG="$BASE_IMG_DIR/ubuntu-24.04-server-cloudimg-amd64.img"
if [ ! -f "$UBUNTU_IMG" ]; then
    echo "Downloading Ubuntu cloud image..."
    wget https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img -O "$UBUNTU_IMG"
else
    echo "Ubuntu cloud image already exists. Skipping download."
fi

# Resize the image
echo "Resizing the image..."
qemu-img resize "$UBUNTU_IMG" "$DISK_SIZE"

# Create a copy of the base image for the new VM
VM_IMG="$BASE_IMG_DIR/$VM_NAME.img"
cp "$UBUNTU_IMG" "$VM_IMG"

# Create cloud-init ISO
CLOUD_INIT_ISO="$BASE_IMG_DIR/$VM_NAME-cloud-init.iso"
cloud-localds "$CLOUD_INIT_ISO" "$CLOUD_INIT_FILE"

# Create and start the VM
echo "Creating and starting the VM..."
virt-install --name "$VM_NAME" \
    --ram "$RAM" \
    --vcpus "$VCPUS" \
    --disk "$VM_IMG",device=disk,bus=virtio \
    --disk "$CLOUD_INIT_ISO",device=cdrom \
    --os-type linux \
    --os-variant ubuntu24.04 \
    --network bridge=br0 \
    --graphics none \
    --import \
    --noautoconsole

echo "VM creation process completed. You can connect to the VM using:"
echo "virsh console $VM_NAME"