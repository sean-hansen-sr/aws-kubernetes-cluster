#!/bin/bash
set -euxo pipefail

# Define Kubernetes version (major.minor)
K8S_VERSION="v1.31"

# Disable swap immediately and permanently
swapoff -a
sed -i -E '/ swap / s/^(.*)$/#\1/' /etc/fstab

# Load required kernel modules
modprobe overlay
modprobe br_netfilter

# Enable kernel modules and IP forwarding permanently
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Set system networking parameters
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl settings without rebooting
sysctl --system

apt update
apt upgrade -y
apt install -y containerd

# Configure containerd to use systemd cgroup
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml > /dev/null
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Force containerd to use the multi-arch pause image to prevent execution errors
sed -i 's|sandbox_image = "registry.k8s.io/pause:.*"|sandbox_image = "registry.k8s.io/pause:3.10"|g' /etc/containerd/config.toml

# Restart containerd to apply changes
systemctl restart containerd
systemctl enable containerd

# Install package prerequisites
apt install -y apt-transport-https ca-certificates curl gpg

# Download the public signing key for the Kubernetes package repositories
# Note: Adjust the version (v1.31, v1.32, etc.) depending on your target version
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the repository to your system sources
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

# Install the components
apt update
apt upgrade
apt update && apt install -y conntrack
apt install -y kubelet kubeadm kubectl

# Pin the versions so apt upgrade doesn't break your cluster
apt-mark hold kubelet kubeadm kubectl