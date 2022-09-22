#!/bin/bash

banner() {
  echo "
            ______         __                _____   __ __   
           |      |.--.--.|  |--.-----.----.|     |_|__|  |_ 
           |   ---||  |  ||  _  |  -__|   _||       |  |   _|
           |______||___  ||_____|_____|__|  |_______|__|____|
                   |_____|                                   "
  echo
}

# set executable, define root, make working dir, CD into it
set -e
root=$PWD
mkdir -p Lab
cd Lab

# agreements + downloads
download() {
    set -e
    echo "
 ╔══════════════════════════════════════════════════════════════════════╗
║〤| By executing this script you agree to the PHP License, the Ngrok |〤║
║〤|  license, and the licenses of all packages used in this project. |〤║
║〤|     Press Ctrl+C if you do not agree to any of these licenses.   |〤║
║〤|                      Press Enter to agree.                       |〤║
 ╚══════════════════════════════════════════════════════════════════════╝"
    read -s agree_text
    echo "
 ╔══════════════════════════════════════════════════════════════════════╗
║〤|        Thank you for agreeing, the download will now begin.      |〤║
║〤|            Downloading Ngrok (For localhost tunneling)           |〤║"
    wget -O ngrok.zip -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
    echo "║〤|             Unzipping Ngrok and deleting the zip file            |〤║"
    unzip -q ngrok.zip 
    rm -rf ngrok.zip
    echo "║〤|              Touching Index.php for quick start...              |〤║" 
    touch index.php
    echo "<?php
echo 'CyberLit Default Lab Setup ~EDIT ME!';" > index.php
    echo " ╚══════════════════════════════════════════════════════════════════════╝"
    echo
    echo
}

# lab requirements checks with reponses
require() {
    if [ ! $1 $2 ]; then
        clear
        banner
        echo "                   $3"
        sleep 0.25
        echo "〤━━━━━━━━━━━━━━━━━━━━━━━━━Running Download...━━━━━━━━━━━━━━━━━━━━━━━━━〤"
        download
    fi
}
require_executable() {
    require_file "$1"
    chmod +x "$1"
}
require_file() { require -f $1 "File $1 required but not found"; }
require_dir()  { require -d $1 "Directory $1 required but not found"; }
require_env()  {
    var=`python3 -c "import os;print(os.getenv('$1',''))"`
    if [ -z "${var}" ]; then
        echo "〤━━━━━━━━━━━━━━━━━━━━━━━━━━Environment Variables━━━━━━━━━━━━━━━━━━━━━━━━━━〤"
        echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        echo "|〤| Environment variable $1 not set. "
        echo "|〤| In your .env file, add a line with:"
        echo "|〤| $1= and then right after the = add"
        echo "|〤| $2"
        echo 〤━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━〤
        exit
    fi
    eval "$1=$var"
}

# actual requirements check
require_executable "ngrok"
require_file "index.php"
require_env "ngrok_token" "your ngrok authtoken from https://dashboard.ngrok.com"
require_env "ngrok_region" "your region, one of:
|〤| us - United States (Ohio)
|〤| eu - Europe (Frankfurt)
|〤| ap - Asia/Pacific (Singapore)
|〤| au - Australia (Sydney)
|〤| sa - South America (Sao Paulo)
|〤| jp - Japan (Tokyo)
|〤| in - India (Mumbai)" 

# start tunnel
sleep 2
clear
banner
echo "〤━━━━━━━━━━━━━━━━━━━━━━━━━━ Starting Tunnel ━━━━━━━━━━━━━━━━━━━━━━━━━━〤"
echo "|〤| Starting ngrok tunnel in region $ngrok_region"
./ngrok authtoken $ngrok_token
./ngrok tcp -region $ngrok_region --log=stdout 1025 > $root/status.log &
echo "|〤| Tunnel Up!"
echo "Server is now being tunnelled!" > $root/status.log

# start lab
php -S 0.0.0.0:80 index.php