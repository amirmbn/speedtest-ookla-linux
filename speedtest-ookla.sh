#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Speedtest CLI by Ookla${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run this script with sudo${NC}"
    exit 1
fi

# Check if speedtest is already installed
if command -v speedtest &> /dev/null; then
    echo -e "${BLUE}✓ Speedtest is already installed${NC}"
    echo -e "${YELLOW}Skipping installation, running speed test...${NC}"
    echo ""
    echo -e "${YELLOW}To see available servers, run: speedtest --servers${NC}"
    read -p "Enter server ID (press Enter to use auto-select): " SERVER_ID
    echo ""
    
    # Run speed test
    if [ -z "$SERVER_ID" ]; then
        speedtest --accept-license --accept-gdpr
    else
        speedtest --accept-license --accept-gdpr --server-id=$SERVER_ID
    fi
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Speed test completed!${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
fi

# If not installed, proceed with installation
echo -e "${YELLOW}Speedtest not found. Starting installation...${NC}"
echo ""

# Install curl if not present
echo -e "${YELLOW}[1/4] Checking and installing curl...${NC}"
if ! command -v curl &> /dev/null; then
    apt-get update
    apt-get install -y curl
    echo -e "${GREEN}✓ curl installed${NC}"
else
    echo -e "${GREEN}✓ curl already installed${NC}"
fi
echo ""

# Add Ookla repository
echo -e "${YELLOW}[2/4] Adding official Ookla repository...${NC}"
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Repository added successfully${NC}"
else
    echo -e "${RED}✗ Error adding repository${NC}"
    exit 1
fi
echo ""

# Install Speedtest
echo -e "${YELLOW}[3/4] Installing Speedtest CLI...${NC}"

# Update package list first
apt-get update

# Try different package names
if apt-get install -y speedtest 2>/dev/null; then
    echo -e "${GREEN}✓ Speedtest installed successfully${NC}"
elif apt-get install -y speedtest-cli 2>/dev/null; then
    echo -e "${GREEN}✓ Speedtest installed successfully (as speedtest-cli)${NC}"
elif apt-get install -y ookla-speedtest-cli 2>/dev/null; then
    echo -e "${GREEN}✓ Speedtest installed successfully (as ookla-speedtest-cli)${NC}"
else
    echo -e "${RED}✗ Error installing Speedtest${NC}"
    echo -e "${YELLOW}Trying alternative installation method...${NC}"
    
    # Alternative: Direct download from Ookla
    wget -O /tmp/speedtest.tgz https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-$(uname -m).tgz
    tar -xzf /tmp/speedtest.tgz -C /usr/local/bin
    chmod +x /usr/local/bin/speedtest
    rm /tmp/speedtest.tgz
    
    if command -v speedtest &> /dev/null; then
        echo -e "${GREEN}✓ Speedtest installed successfully (via direct download)${NC}"
    else
        echo -e "${RED}✗ All installation methods failed${NC}"
        exit 1
    fi
fi
echo ""

# Get server ID from user
echo -e "${YELLOW}[4/4] Running speed test...${NC}"
echo -e "${YELLOW}(License will be accepted automatically)${NC}"
echo ""
echo -e "${YELLOW}To see available servers, run: speedtest --servers${NC}"
read -p "Enter server ID (press Enter to use auto-select): " SERVER_ID
echo ""

# Run speed test
if [ -z "$SERVER_ID" ]; then
    speedtest --accept-license --accept-gdpr
else
    speedtest --accept-license --accept-gdpr --server-id=$SERVER_ID
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation and test completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}To run speed test again, use:${NC}"
echo -e "${GREEN}speedtest${NC}"
echo -e "${YELLOW}Or run this script again:${NC}"
echo -e "${GREEN}sudo ./install_speedtest.sh${NC}"
echo ""
echo -e "${YELLOW}Useful options:${NC}"
echo -e "  speedtest --servers              # Show list of servers"
echo -e "  speedtest --server-id=xxxxx      # Select specific server"
echo -e "  speedtest --format=json          # JSON output"
echo ""
