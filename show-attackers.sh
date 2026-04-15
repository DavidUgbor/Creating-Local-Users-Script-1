#!/bin/bash

# Check if file is provided and readable
if [[ "${#}" -ne 1 ]] || [[ ! -r "${1}" ]]
then
  echo "Cannot open log file: ${1}" >&2
  exit 1
fi

LOG_FILE="${1}"

# Display CSV header
echo "Count,IP,Location"

# Extract failed login attempts, count IPs
grep "Failed" "${LOG_FILE}" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | while read COUNT IP
do
  if [[ "${COUNT}" -gt 10 ]]
  then
    LOCATION=$(geoiplookup ${IP} | awk -F ", " '{print $2}')
    echo "${COUNT},${IP},${LOCATION}"
  fi
done