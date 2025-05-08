# Local FTP Server

A zero-config shell script to quickly start a local FTP server using Docker to share files around your local network. You can choose to transport the files via FTP, SFTP, or a web interface. (SFTP being the most secure option of course.)

## Installation

### Option 1: Clone the repository

```bash
# Clone the repository
git clone https://github.com/ivstiv/local-ftp.git
cd local-ftp

# Make the script executable
chmod +x local-ftp.sh
```

### Option 2: Download the script directly

```bash
# Download the script
curl -O https://raw.githubusercontent.com/ivstiv/local-ftp/main/local-ftp.sh

# Make the script executable
chmod +x local-ftp.sh
```

### Option 3: Install system-wide

```bash
# Download the script
sudo curl -o /usr/local/bin/local-ftp https://raw.githubusercontent.com/ivstiv/local-ftp/main/local-ftp.sh

# Make the script executable
sudo chmod +x /usr/local/bin/local-ftp
```

After installing system-wide, you can run it from anywhere with:

```bash
local-ftp
```

## Requirements

- Docker
- Basic shell utilities (`ip`, `realpath`)

## Usage

```bash
local-ftp.sh — Local FTP server using Docker

Examples:
  ./local-ftp.sh
  ./local-ftp.sh --user admin --password secret
  ./local-ftp.sh --ftp-port false         # disable FTP/FTPS
  ./local-ftp.sh --sftp-port 2022         # custom SFTP port

Options:
  --user      <username>        FTP username (default: user)
  --password  <password>        FTP password (default: pass)
  --ftp-port  <port | false>    FTP port (default: 2121) or false to disable
  --sftp-port <port | false>    SFTP port (default: 2222) or false to disable
  --http-port <port | false>    HTTP port (default: 8080) or false to disable
  --directory <path>            Directory to share (default: current directory)
  -h --help                     Shows this message
```

## How It Works

The script uses the [drakkan/sftpgo](https://github.com/drakkan/sftpgo) Docker image to run a containerized FTP, SFTP, and HTTP server in [portable mode](https://docs.sftpgo.com/2.6/cli/#portable-mode), making your specified directory available via FTP, SFTP, and a web interface to the local network.
