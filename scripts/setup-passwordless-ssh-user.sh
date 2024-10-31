#!/bin/bash

# Run this script as root when you first create a new server, so that all is configured for ansible accessing the server.
# This script does the following:
# 2. Add the public key to the 'someuser' user's authorized_keys file
# 3. Set up password-less sudo for the 'someuser' user
# 4. Add the 'someuser' user to the 'root' group

# Function to handle errors
handle_error() {
    echo "Error on line $1"
    exit 1
}

# Trap errors and call the handle_error function
trap 'handle_error $LINENO' ERR

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# read -p "Enter your username: " USERNAME
read -p "Enter the public key (rsa-ssh ...): " USERNAME

# create user USERNAME if it does not exist
if ! id -u $USERNAME > /dev/null 2>&1; then
    useradd -m -s /bin/bash $USERNAME
    echo "User $USERNAME created."
else
    echo "User $USERNAME already exists."
fi

echo "Adding public key to the 'USERNAME' user's authorized_keys file..."

# Add SSH public key to .ssh/authorized_keys

# check if .ssh exists
if [ ! -d /home/${USERNAME}/.ssh ]; then
    mkdir -p /home/${USERNAME}/.ssh
fi

# ask for the public key
read -p "Enter the public key (rsa-ssh ...): " PUBLIC_KEY
# add the public key to the authorized_keys file
echo $PUBLIC_KEY > /home/${USERNAME}/.ssh/authorized_keys

chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh
chmod 700 /home/${USERNAME}/.ssh
chmod 600 /home/${USERNAME}/.ssh/authorized_keys

# Set up password-less sudo for the '${USERNAME}' user
echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}
chmod 440 /etc/sudoers.d/${USERNAME}

# Add the '${USERNAME}' user to the 'root' group
usermod -aG root ${USERNAME}

# Print the user details