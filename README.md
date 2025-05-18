# Uploader
A simple shell script that attempts to bypass extension blacklists for file uploads. If no arguments are provided it will default to interactive mode.

## Usage
Specify your IP address & your listener's port for the Reverse Shell payload.

./uploader.sh 123.45.67.890 1337

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
