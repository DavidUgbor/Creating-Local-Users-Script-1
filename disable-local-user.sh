#!/bin/bash

# Display usage
usage() {
  echo "Usage: ${0} [-dra] USER [USERN]" >&2
  echo "Disable a local Linux account." >&2
  echo "  -d  Deletes accounts instead of disabling them." >&2
  echo "  -r  Removes the home directory associated with the account(s)." >&2
  echo "  -a  Creates an archive of the home directory associated with the accounts(s)." >&2
  exit 1
}

# Must be root
if [[ "${UID}" -ne 0 ]]
then
  echo "Please run with sudo or as root." >&2
  exit 1
fi

DELETE_USER=false
REMOVE_OPTION=false
ARCHIVE=false

# Parse options
while getopts dra OPTION
do
  case ${OPTION} in
    d) DELETE_USER=true ;;
    r) REMOVE_OPTION=true ;;
    a) ARCHIVE=true ;;
    ?) usage ;;
  esac
done

shift $((OPTIND -1))

# Need at least one user
if [[ "${#}" -lt 1 ]]
then
  usage
fi

ARCHIVE_DIR="/archive"

# Loop through users
for USER_NAME in "$@"
do
  echo "Processing user: ${USER_NAME}"

  USER_ID=$(id -u ${USER_NAME} 2>/dev/null)

  # Check UID
  if [[ "${USER_ID}" -lt 1000 ]]
  then
    echo "Refusing to remove the ${USER_NAME} account with UID ${USER_ID}." >&2
    continue
  fi

  # Archive if needed
  if [[ "${ARCHIVE}" = true ]]
  then
    if [[ ! -d "${ARCHIVE_DIR}" ]]
    then
      echo "Creating ${ARCHIVE_DIR} directory."
      mkdir -p ${ARCHIVE_DIR}
    fi

    HOME_DIR="/home/${USER_NAME}"
    ARCHIVE_FILE="${ARCHIVE_DIR}/${USER_NAME}.tgz"

    if [[ -d "${HOME_DIR}" ]]
    then
      echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
      tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &>/dev/null
    fi
  fi

  # Delete user
  if [[ "${DELETE_USER}" = true ]]
  then
    userdel ${REMOVE_OPTION:+-r} ${USER_NAME} &>/dev/null

    if [[ "${?}" -ne 0 ]]
    then
      echo "The account ${USER_NAME} was NOT deleted." >&2
    else
      echo "The account ${USER_NAME} was deleted."
    fi
  else
    # Disable user
    chage -E 0 ${USER_NAME} &>/dev/null

    if [[ "${?}" -ne 0 ]]
    then
      echo "The account ${USER_NAME} was NOT disabled." >&2
    else
      echo "The account ${USER_NAME} was disabled."
    fi
  fi

done