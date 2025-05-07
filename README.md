# Local FTP Server

A simple shell script to quickly start a local FTP server using Docker.

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
  ./local-ftp.sh --port 2121 --directory /path/to/share

Options:
  --user <username>      FTP username (default: user)
  --password <password>  FTP password (default: pass)
  --port <port>          FTP port (default: 2121)
  --directory <path>     Directory to share (default: current directory)
  -h --help              Shows this message
```

## How It Works

The script uses the [stilliard/pure-ftpd](https://github.com/stilliard/docker-pure-ftpd) Docker image to run a containerized FTP server, making your specified directory available via FTP.
