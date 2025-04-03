#!/bin/bash

# Dotfiles Deployment Script
# This script creates symbolic links from your dotfiles repository to your home directory

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Get the absolute path of the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d%H%M%S)"
LOGFILE="$DOTFILES_DIR/deploy.log"

# Function to log messages
log() {
    echo -e "${2:-$BLUE}$1${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

# Function to create backup of existing file/directory
backup() {
    local path="$1"
    if [ -e "$path" ] && [ ! -L "$path" ]; then
        mkdir -p "$BACKUP_DIR"
        log "Backing up $path to $BACKUP_DIR" "$YELLOW"
        mv "$path" "$BACKUP_DIR/"
        return 0
    elif [ -L "$path" ]; then
        log "Removing existing symlink $path" "$YELLOW"
        rm "$path"
        return 0
    fi
    return 1
}

# Function to create symbolic links
create_link() {
    local source="$1"
    local target="$2"
    
    # Make sure source exists
    if [ ! -e "$source" ]; then
        log "Source does not exist: $source" "$RED"
        return 1
    fi
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Backup existing file/directory
    backup "$target"
    
    # Create symbolic link
    ln -s "$source" "$target"
    
    if [ $? -eq 0 ]; then
        log "Created symlink: $target -> $source" "$GREEN"
        return 0
    else
        log "Failed to create symlink: $target -> $source" "$RED"
        return 1
    fi
}

# Function to deploy bin scripts
deploy_bin_scripts() {
    log "Deploying bin scripts..." "$BLUE"
    
    mkdir -p "$HOME/bin"
    
    for script in "$DOTFILES_DIR"/bin/*; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            script_name=$(basename "$script")
            create_link "$script" "$HOME/bin/$script_name"
        fi
    done
}

# Function to deploy bash configurations
deploy_bash_configs() {
    log "Deploying bash configurations..." "$BLUE"
    
    create_link "$DOTFILES_DIR/bash/bashrc" "$HOME/.bashrc"
    create_link "$DOTFILES_DIR/bash/bash_profile" "$HOME/.bash_profile"
    create_link "$DOTFILES_DIR/bash/bash_logout" "$HOME/.bash_logout"
    create_link "$DOTFILES_DIR/bash/profile" "$HOME/.profile"
    
    # Create directory for bash functions if it doesn't exist
    mkdir -p "$HOME/.bash_functions"
    create_link "$DOTFILES_DIR/bash/bash_functions" "$HOME/.bash_functions/functions"
    create_link "$DOTFILES_DIR/bash/sb_functions" "$HOME/.bash_functions/sb_functions"
}

# Function to deploy vim configurations
deploy_vim_configs() {
    log "Deploying vim configurations..." "$BLUE"
    
    mkdir -p "$HOME/.vim/autoload"
    create_link "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
    create_link "$DOTFILES_DIR/vim/plug.vim" "$HOME/.vim/autoload/plug.vim"
}

# Function to deploy neovim configurations
deploy_nvim_configs() {
    log "Deploying neovim configurations..." "$BLUE"
    
    mkdir -p "$HOME/.config/nvim"
    mkdir -p "$HOME/.config/nvim/lua"
    
    # Link the init.lua file
    if [ -f "$DOTFILES_DIR/nvim/init.lua" ] && [ ! -L "$DOTFILES_DIR/nvim/init.lua" ]; then
        create_link "$DOTFILES_DIR/vim/init.lua" "$HOME/.config/nvim/init.lua"
    else
        create_link "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"
    fi
    
    # Link the lua directory structure
    if [ -d "$DOTFILES_DIR/nvim/lua" ]; then
        for dir in "$DOTFILES_DIR"/nvim/lua/*; do
            if [ -d "$dir" ]; then
                dir_name=$(basename "$dir")
                mkdir -p "$HOME/.config/nvim/lua/$dir_name"
                
                for file in "$dir"/*; do
                    if [ -f "$file" ]; then
                        file_name=$(basename "$file")
                        create_link "$file" "$HOME/.config/nvim/lua/$dir_name/$file_name"
                    elif [ -d "$file" ]; then
                        subdir_name=$(basename "$file")
                        mkdir -p "$HOME/.config/nvim/lua/$dir_name/$subdir_name"
                        
                        for subfile in "$file"/*; do
                            if [ -f "$subfile" ]; then
                                subfile_name=$(basename "$subfile")
                                create_link "$subfile" "$HOME/.config/nvim/lua/$dir_name/$subdir_name/$subfile_name"
                            fi
                        done
                    fi
                done
            fi
        done
    fi
    
    # Link any other files in the nvim directory
    for file in "$DOTFILES_DIR"/nvim/*.{json,md}; do
        if [ -f "$file" ]; then
            file_name=$(basename "$file")
            create_link "$file" "$HOME/.config/nvim/$file_name"
        fi
    done
}

# Function to deploy i3 configurations
deploy_i3_configs() {
    log "Deploying i3 configurations..." "$BLUE"
    
    mkdir -p "$HOME/.config/i3"
    mkdir -p "$HOME/.config/i3statusbar"
    
    create_link "$DOTFILES_DIR/i3/config" "$HOME/.config/i3/config"
    create_link "$DOTFILES_DIR/i3statusbar/i3status.conf" "$HOME/.config/i3statusbar/i3status.conf"
}

# Function to deploy kitty configurations
deploy_kitty_configs() {
    log "Deploying kitty configurations..." "$BLUE"
    
    mkdir -p "$HOME/.config/kitty"
    create_link "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
}

# Function to deploy tmux configurations
deploy_tmux_configs() {
    log "Deploying tmux configurations..." "$BLUE"
    
    mkdir -p "$HOME/.config/tmux/plugins"
    create_link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    
    # Check if TPM (Tmux Plugin Manager) is installed
    if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
        log "Installing Tmux Plugin Manager (TPM)..." "$YELLOW"
        git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
    fi
}

# Function to deploy other configurations
deploy_other_configs() {
    log "Deploying other configurations..." "$BLUE"
    
    # picom
    mkdir -p "$HOME/.config/picom"
    create_link "$DOTFILES_DIR/picom/picom.conf" "$HOME/.config/picom/picom.conf"
    
    # ranger
    mkdir -p "$HOME/.config/ranger"
    create_link "$DOTFILES_DIR/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"
    
    # zathura
    mkdir -p "$HOME/.config/zathura"
    create_link "$DOTFILES_DIR/zathura/zathurarc" "$HOME/.config/zathura/zathurarc"
    
    # systemd user services
    mkdir -p "$HOME/.config/systemd/user"
    for service in "$DOTFILES_DIR"/systemd/user/*.service; do
        if [ -f "$service" ]; then
            service_name=$(basename "$service")
            create_link "$service" "$HOME/.config/systemd/user/$service_name"
        fi
    done
    
    # OBS
    mkdir -p "$HOME/.config/obs"
    for file in "$DOTFILES_DIR"/obs/*; do
        if [ -f "$file" ]; then
            file_name=$(basename "$file")
            create_link "$file" "$HOME/.config/obs/$file_name"
        fi
    done
}

# Main function to deploy all configurations
deploy_all() {
    log "Starting deployment of dotfiles from: $DOTFILES_DIR" "$BLUE"
    
    deploy_bin_scripts
    deploy_bash_configs
    deploy_vim_configs
    deploy_nvim_configs
    deploy_i3_configs
    deploy_kitty_configs
    deploy_tmux_configs
    deploy_other_configs
    
    log "Deployment completed!" "$GREEN"
    
    if [ -d "$BACKUP_DIR" ]; then
        log "Backup of original files created at: $BACKUP_DIR" "$YELLOW"
    fi
    
    log "You may need to source your bash configuration: source ~/.bashrc" "$YELLOW"
    log "For tmux, press prefix + I (capital I) to install plugins after starting tmux" "$YELLOW"
}

# Function to display menu and handle user choice
show_menu() {
    echo -e "${BLUE}=== Dotfiles Deployment Menu ===${NC}"
    echo -e "1) Deploy all configurations"
    echo -e "2) Deploy bin scripts only"
    echo -e "3) Deploy bash configurations only"
    echo -e "4) Deploy vim configurations only"
    echo -e "5) Deploy neovim configurations only"
    echo -e "6) Deploy i3 configurations only"
    echo -e "7) Deploy kitty configurations only"
    echo -e "8) Deploy tmux configurations only"
    echo -e "9) Deploy other configurations only"
    echo -e "0) Exit"
    
    read -p "Enter your choice [0-9]: " choice
    
    case $choice in
        1) deploy_all ;;
        2) deploy_bin_scripts ;;
        3) deploy_bash_configs ;;
        4) deploy_vim_configs ;;
        5) deploy_nvim_configs ;;
        6) deploy_i3_configs ;;
        7) deploy_kitty_configs ;;
        8) deploy_tmux_configs ;;
        9) deploy_other_configs ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid choice. Please try again.${NC}" ;;
    esac
}

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    log "Do not run this script as root!" "$RED"
    exit 1
fi

# Create log file
touch "$LOGFILE"

# Main execution
if [ "$1" = "--all" ]; then
    deploy_all
else
    show_menu
fi
