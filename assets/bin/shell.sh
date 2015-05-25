#!/bin/bash
# First time setup
if [ -a /runSetup ]; then
  rm /runSetup
  echo "Running first time setup"
  ln -s /home/_docker_staging /home/$USER_NAME
  echo "Creating user $USER_NAME"
  useradd -g users -s /bin/bash -d /home/$USER_NAME $USER_NAME
  echo "Setting permissions on /home/$USER_NAME"
  cp -r /home/$USER_NAME/projects/dotfiles/{.bash_profile,.vimrc,.git,.gradle,.tmux.conf} /home/$USER_NAME/
  chown -R $USER_NAME:users /home/$USER_NAME
  su -c /local/opt/docker-assets/bin/setup-git.sh james
fi

su - $USER_NAME
