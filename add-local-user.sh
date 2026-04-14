#!/bin/bash

# Check if root
if [[ "${UID}" -ne 0 ]]
then
  echo "Please run with sudo or as root."
  exit 1
fi

# Get username
read -p "Enter the username to create: " USER_NAME

# Get real name
read -p "Enter the name of the person or application that will be using this account: " COMMENT

# Get password
read -p "Enter the password to use for the account: " PASSWORD

# Create user
useradd -c "${COMMENT}" -m "${USER_NAME}"

# Check if user created
if [[ "${?}" -ne 0 ]]
then
  echo "The account could not be created."
  exit 1
fi

# Set password
echo "${PASSWORD}" | passwd --stdin "${USER_NAME}"

# Check password set
if [[ "${?}" -ne 0 ]]
then
  echo "The password could not be set."
  exit 1
fi

# Force password change
passwd -e "${USER_NAME}"

# Display info
echo
echo "username:"
echo "${USER_NAME}"
echo
echo "password:"
echo "${PASSWORD}"
echo
echo "host:"
hostname