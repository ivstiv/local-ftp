#!/bin/sh

#H#
#H# local-ftp.sh — Local FTP server using Docker
#H#
#H# Examples:
#H#   ./local-ftp.sh
#H#   ./local-ftp.sh --user admin --password secret
#H#   ./local-ftp.sh --ftp-port false         # disable FTP/FTPS
#H#   ./local-ftp.sh --sftp-port 2022         # custom SFTP port
#H#
#H# Options:
#H#   --user      <username>        FTP username (default: user)
#H#   --password  <password>        FTP password (default: pass)
#H#   --ftp-port  <port | false>    FTP port (default: 2121) or false to disable
#H#   --sftp-port <port | false>    SFTP port (default: 2222) or false to disable
#H#   --http-port <port | false>    HTTP port (default: 8080) or false to disable
#H#   --directory <path>            Directory to share (default: current directory)
#H#   -h --help                     Shows this message
#H#
#H# For feedback or feature requests, please open an issue on the repository:
#H#   - https://github.com/ivstiv/local-ftp
#H#

FTP_USER="user"
FTP_PASS="pass"
FTP_PORT="2121"
SFTP_PORT="2222"
HTTP_PORT="8080"
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
    --ftp-port)
      FTP_PORT="$2"
      shift 2
      ;;
    --sftp-port)
      SFTP_PORT="$2"
      shift 2
      ;;
    --http-port)
      HTTP_PORT="$2"
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
      echo "Usage: $0 --help to show help"
      exit 1
      ;;
  esac
done

FTP_DIR_ABS=$(realpath "$FTP_DIR")
LOCAL_IP=$(getLocalIP)

print_color "$BLUE" "======================================================="
print_color "$GREEN" "Starting server with:"
print_color "$GREEN" "  - User: $FTP_USER"
print_color "$GREEN" "  - Password: $FTP_PASS"
[ "$FTP_PORT"  != "false" ] && print_color "$GREEN" "  - FTP Port: $FTP_PORT"
[ "$SFTP_PORT" != "false" ] && print_color "$GREEN" "  - SFTP Port: $SFTP_PORT"
[ "$HTTP_PORT" != "false" ] && print_color "$GREEN" "  - HTTP Port: $HTTP_PORT"
print_color "$GREEN" "  - Directory: $FTP_DIR_ABS"
print_color "$GREEN" "  - Local IP: $LOCAL_IP"
[ "$FTP_PORT"  != "false" ] && print_color "$GREEN" "  - FTP URL: ftp://$FTP_USER:$FTP_PASS@$LOCAL_IP:$FTP_PORT"
[ "$SFTP_PORT" != "false" ] && print_color "$GREEN" "  - SFTP URL: sftp://$FTP_USER:$FTP_PASS@$LOCAL_IP:$SFTP_PORT"
[ "$HTTP_PORT" != "false" ] && print_color "$GREEN" "  - HTTP URL: http://$LOCAL_IP:$HTTP_PORT"
print_color "$BLUE" "======================================================="

PORT_FLAGS=""
CLI_FLAGS=""
ENV_FLAGS="-e SFTPGO_FTPD__BINDINGS__0__FORCE_PASSIVE_IP=${LOCAL_IP}"

if [ "$FTP_PORT" != "false" ]; then
  PORT_FLAGS="$PORT_FLAGS -p ${FTP_PORT}:2121 -p 30000-30009:30000-30009"
  CLI_FLAGS="$CLI_FLAGS --ftpd-port 2121"
  ENV_FLAGS="$ENV_FLAGS \
    -e SFTPGO_FTPD__PASSIVE_PORT_RANGE__START=30000 \
    -e SFTPGO_FTPD__PASSIVE_PORT_RANGE__END=30009"
else
  CLI_FLAGS="$CLI_FLAGS --ftpd-port -1"
fi

if [ "$SFTP_PORT" != "false" ]; then
  PORT_FLAGS="$PORT_FLAGS -p ${SFTP_PORT}:2222"
  CLI_FLAGS="$CLI_FLAGS --sftpd-port 2222"
else
  CLI_FLAGS="$CLI_FLAGS --sftpd-port -1"
fi

if [ "$HTTP_PORT" != "false" ]; then
  PORT_FLAGS="$PORT_FLAGS -p ${HTTP_PORT}:8080"
  CLI_FLAGS="$CLI_FLAGS --httpd-port 8080"
else
  CLI_FLAGS="$CLI_FLAGS --httpd-port -1"
fi

# don't double quote the flag variables
# we need them to word split so docker sees them
# as separate arguments
# shellcheck disable=SC2086
docker run --rm -it \
  $PORT_FLAGS \
  $ENV_FLAGS \
  -v "${FTP_DIR_ABS}":/srv/data \
  drakkan/sftpgo:latest \
  sftpgo portable \
    --directory /srv/data \
    --username "${FTP_USER}" \
    --password "${FTP_PASS}" \
    $CLI_FLAGS

