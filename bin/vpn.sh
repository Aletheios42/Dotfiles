#!/bin/bash

# ProtonVPN Switcher
# Usage: vpn [country_code|off|list|status]

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to expand a 2-letter country code to full config name
expand_country_code() {
    local code=$1
    
    if [[ ${#code} -eq 2 ]]; then
        local configs=$(sudo find /etc/openvpn/client/ -maxdepth 1 -name "${code}-*.conf" | sort)
        
        if [ -z "$configs" ]; then
            echo ""  # No match found
        elif [ $(echo "$configs" | wc -l) -eq 1 ]; then
            # Only one config for this country, use it
            basename "$(echo "$configs")" .conf
        else
            # Multiple matches, use the first one
            # You could modify this to show a selection menu if desired
            basename "$(echo "$configs" | head -n 1)" .conf
        fi
    else
        # Return the original input if it's not a 2-letter code
        echo "$code"
    fi
}

# List available VPN configurations
list_available_vpns() {
    echo -e "${BLUE}Available VPN configurations:${NC}"
    
    # Get ProtonVPN configs from client directory
    configs=$(sudo find /etc/openvpn/client/ -maxdepth 1 -name "*protonvpn*.conf" | sort)
    
    if [ -z "$configs" ]; then
        echo -e "${RED}No ProtonVPN configurations found!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Code    Country             Server${NC}"
    echo -e "${YELLOW}----    -------             ------${NC}"    

    for config in $configs; do
        filename=$(basename "$config" .conf)
        country_code=$(echo "$filename" | cut -d'-' -f1)
        
        case "$country_code" in
            nl) country="Netherlands" ;;
            us) country="United States" ;;
            jp) country="Japan" ;;
            *) country="Unknown" ;;
        esac
        
        printf "${GREEN}%-6s${NC}  %-18s  ${YELLOW}%s${NC}\n" "$country_code" "$country" "$filename"
    done
    
    return 0
}

# Check if a VPN is running
is_vpn_running() {
    if systemctl is-active --quiet openvpn-client@*; then
        current_vpn=$(systemctl list-units --state=active | grep openvpn-client@ | awk '{print $1}' | sed 's/openvpn-client@//g' | sed 's/\.service//g')
        echo -e "${GREEN}Currently connected to:${NC} $current_vpn"
        return 0
    else
        echo -e "${RED}No VPN is currently active${NC}"
        return 1
    fi
}

# Connect to a VPN
connect_to_vpn() {
    local config=$1
    
    # Check if config exists
    if ! sudo test -f "/etc/openvpn/client/${config}.conf"; then
        echo -e "${RED}Error: Configuration file for ${config} not found!${NC}"
        list_available_vpns
        return 1
    fi
    
    # Stop any running VPN connections
    echo -e "${YELLOW}Stopping any active VPN connections...${NC}"
    sudo systemctl stop openvpn-client@*
    
    # Start the new VPN connection
    echo -e "${YELLOW}Connecting to ${config}...${NC}"
    sudo systemctl start openvpn-client@${config}
    
    # Check if connection was successful
    sleep 2
    if systemctl is-active --quiet openvpn-client@${config}; then
        echo -e "${GREEN}Successfully connected to ${config}${NC}"
        
        # Get IP info
        echo -e "${BLUE}Fetching connection details...${NC}"
        sleep 1
        ip_info=$(curl -s ipinfo.io)
        ip=$(echo "$ip_info" | grep -o '"ip": "[^"]*' | cut -d'"' -f4)
        country=$(echo "$ip_info" | grep -o '"country": "[^"]*' | cut -d'"' -f4)
        city=$(echo "$ip_info" | grep -o '"city": "[^"]*' | cut -d'"' -f4)
        org=$(echo "$ip_info" | grep -o '"org": "[^"]*' | cut -d'"' -f4)
        
        echo -e "${BLUE}Connection Details:${NC}"
        echo -e "${GREEN}IP:${NC} $ip"
        echo -e "${GREEN}Location:${NC} $city, $country"
        echo -e "${GREEN}Provider:${NC} $org"
        
        return 0
    else
        echo -e "${RED}Failed to connect to ${config}${NC}"
        systemctl status openvpn-client@${config} | head -n 15
        return 1
    fi
}

# Disconnect from VPN
disconnect_vpn() {
    echo -e "${YELLOW}Disconnecting from VPN...${NC}"
    sudo systemctl stop openvpn-client@*
    
    sleep 1
    if ! systemctl is-active --quiet openvpn-client@*; then
        echo -e "${GREEN}Successfully disconnected from VPN${NC}"
        return 0
    else
        echo -e "${RED}Failed to disconnect from VPN${NC}"
        return 1
    fi
}

# Main script logic
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}      ProtonVPN Country Switcher        ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check current VPN status
is_vpn_running
echo ""

# Process command line arguments
if [ -n "$1" ]; then
    case "$1" in
        off)
            disconnect_vpn
            exit $?
            ;;
        list)
            list_available_vpns
            exit $?
            ;;
        status)
            is_vpn_running
            exit $?
            ;;
        help|--help|-h)
            echo -e "${BLUE}Usage:${NC}"
            echo -e "  ${GREEN}vpn${NC}              # Interactive mode"
            echo -e "  ${GREEN}vpn nl${NC}           # Connect to Netherlands"
            echo -e "  ${GREEN}vpn us${NC}           # Connect to US" 
            echo -e "  ${GREEN}vpn jp${NC}           # Connect to Japan"
            echo -e "  ${GREEN}vpn off${NC}          # Disconnect"
            echo -e "  ${GREEN}vpn list${NC}         # Show available countries"
            echo -e "  ${GREEN}vpn status${NC}       # Show current status"
            exit 0
            ;;
        *)
            # Expand country code if needed
            expanded_config=$(expand_country_code "$1")
            
            if [ -z "$expanded_config" ]; then
                echo -e "${RED}No configuration found for '$1'${NC}"
                list_available_vpns
                exit 1
            fi
            
            connect_to_vpn "$expanded_config"
            exit $?
            ;;
    esac
fi

# Interactive mode
echo -e "${YELLOW}Options:${NC}"
echo -e "  ${GREEN}1${NC}) Connect to a country"
echo -e "  ${GREEN}2${NC}) Disconnect VPN"
echo -e "  ${GREEN}3${NC}) List available countries"
echo -e "  ${GREEN}4${NC}) Exit"
echo ""

read -p "Enter your choice [1-4]: " choice
echo ""

case $choice in
    1)
        list_available_vpns
        echo ""
        read -p "Enter country code or full server name: " selection
        
        if [[ ${#selection} -eq 2 ]]; then
            configs=$(sudo find /etc/openvpn/client/ -maxdepth 1 -name "${selection}-*.conf" | sort)
            
            if [ -z "$configs" ]; then
                echo -e "${RED}No configurations found for country code '$selection'${NC}"
                exit 1
            elif [ $(echo "$configs" | wc -l) -eq 1 ]; then
                selection=$(basename "$(echo "$configs")" .conf)
            else
                echo -e "${YELLOW}Multiple servers found for $selection:${NC}"
                i=1
                for config in $configs; do
                    echo -e "  ${GREEN}$i${NC}) $(basename "$config" .conf)"
                    i=$((i+1))
                done
                
                read -p "Enter server number: " server_num
                selection=$(basename "$(echo "$configs" | sed -n "${server_num}p")" .conf)
            fi
        fi
        
        connect_to_vpn "$selection"
        ;;
    2)
        disconnect_vpn
        ;;
    3)
        list_available_vpns
        ;;
    4)
        echo -e "${BLUE}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

exit 0
