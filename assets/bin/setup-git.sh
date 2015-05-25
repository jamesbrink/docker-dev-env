#!/bin/bash
# Setup script for git
echo "Configuring git"
cd /home/$USER_NAME/
git config --global color.ui true
git config --global user.name "${FULL_NAME}"
git config --global user.email "${EMAIL_ADDRESS}"
echo -e "\n" | ssh-keygen -t rsa -C "${EMAIL_ADDRESS}" -N ''
