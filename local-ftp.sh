#!/bin/sh

#H#
#H# local-ftp.sh — Local FTP server using Docker
#H#
#H# Examples:
#H#   ./local-ftp.sh
#H#   ./local-ftp.sh --user admin --password secret
#H#   ./local-ftp.sh --port 2121 --directory /path/to/share
#H#
#H# Options:
#H#   --user <username>      FTP username (default: user)
#H#   --password <password>  FTP password (default: pass)
#H#   --port <port>          FTP port (default: 2121)
#H#   --directory <path>     Directory to share (default: current directory)
#H#   -h --help              Shows this message
#H#

FTP_USER="user"
FTP_PASS="pass"
FTP_PORT="2121"
FTP_DIR="."

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#
# Functions
#
help() {
  sed -rn 's/^#H# ?//;T;p' "$0"
}

print_color() {
  color=$1
  text=$2
  printf "%b%s%b\n" "$color" "$text" "$NC"
}

getLocalIP() {
  # Get the primary local IP address
  ip route get 1 | awk '{print $7; exit}' 2>/dev/null || hostname -I | awk '{print $1}'
}

checkDependencies() {
  mainShellPID="$$"
  printf "docker\nrealpath\nip\n" | while IFS= read -r program; do
    if ! [ -x "$(command -v "$program")" ]; then
      print_color "$ORANGE" "Error: $program is not installed." >&2
      kill -9 "$mainShellPID" 
    fi
  done
}

# Check dependencies first
checkDependencies

# Parse command line arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --user)
      FTP_USER="$2"
      shift 2
      ;;
    --password)
      FTP_PASS="$2"
      shift 2
      ;;
    --port)
      FTP_PORT="$2"
      shift 2
      ;;
    --directory)
      FTP_DIR="$2"
      shift 2
      ;;
    -h|--help)
      help
      exit 0
      ;;
    *)
      print_color "$ORANGE" "Unknown parameter: $1"
      echo "Usage: $0 [--user username] [--password password] [--port port] [--directory path]"
      exit 1
      ;;
  esac
done

FTP_DIR_ABS=$(realpath "$FTP_DIR")
LOCAL_IP=$(getLocalIP)

print_color "$BLUE" "================================================"
print_color "$GREEN" "Starting FTP server with:"
print_color "$BLUE" "  - User: $FTP_USER"
print_color "$BLUE" "  - Password: $FTP_PASS"
print_color "$BLUE" "  - Port: $FTP_PORT"
print_color "$BLUE" "  - Directory: $FTP_DIR_ABS"
print_color "$BLUE" "  - Local IP: $LOCAL_IP"
print_color "$BLUE" "  - FTP URL: ftp://$FTP_USER:$FTP_PASS@$LOCAL_IP:$FTP_PORT"
print_color "$BLUE" "================================================"

docker run --rm -it \
  -p "${FTP_PORT}":21 \
  -p 30000-30009:30000-30009 \
  -v "${FTP_DIR_ABS}":/home/ftpuser/shared \
  -e PUBLICHOST="${LOCAL_IP}" \
  -e FTP_USER_NAME="${FTP_USER}" \
  -e FTP_USER_PASS="${FTP_PASS}" \
  -e FTP_USER_HOME=/home/ftpuser/shared \
  stilliard/pure-ftpd

