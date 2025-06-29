#!/bin/bash

# WoW 3.3.5a Addon Deployment Script - Public Version
# This script copies addons from development to WoW directory for testing
# 
# CONFIGURATION REQUIRED:
# Edit the paths below to match your system setup

# =============================================================================
# CONFIGURATION - EDIT THESE PATHS FOR YOUR SYSTEM
# =============================================================================

# Development directory (where this repository is located)
DEV_DIR="$(pwd)/addons"

# WoW AddOns directory (where WoW looks for addons)
# Common locations:
# Windows: "C:/Program Files (x86)/World of Warcraft/Interface/AddOns"
# macOS: "/Applications/World of Warcraft/Interface/AddOns"
# Linux: "~/.wine/drive_c/Program Files (x86)/World of Warcraft/Interface/AddOns"
WOW_ADDONS_DIR=""

# Backup directory (where old versions are stored)
BACKUP_DIR="$(pwd)/backups"

# =============================================================================
# END CONFIGURATION
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_config() {
    echo -e "${BLUE}[CONFIG]${NC} $1"
}

# Check if configuration is set up
check_configuration() {
    if [ -z "$WOW_ADDONS_DIR" ]; then
        print_error "WoW AddOns directory not configured!"
        echo ""
        print_config "Please edit this script and set WOW_ADDONS_DIR to your WoW Interface/AddOns path:"
        echo ""
        print_config "Common locations:"
        print_config "  Windows: C:/Program Files (x86)/World of Warcraft/Interface/AddOns"
        print_config "  macOS: /Applications/World of Warcraft/Interface/AddOns"
        print_config "  Linux: ~/.wine/drive_c/Program Files (x86)/World of Warcraft/Interface/AddOns"
        echo ""
        exit 1
    fi
}

# Check if directories exist
check_directories() {
    if [ ! -d "$DEV_DIR" ]; then
        print_error "Development directory not found: $DEV_DIR"
        print_config "Make sure you're running this script from the repository root"
        exit 1
    fi

    if [ ! -d "$WOW_ADDONS_DIR" ]; then
        print_error "WoW AddOns directory not found: $WOW_ADDONS_DIR"
        print_config "Please check your WOW_ADDONS_DIR path in the script configuration"
        exit 1
    fi
}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to backup existing addon
backup_addon() {
    local addon_name=$1
    local backup_path="$BACKUP_DIR/${addon_name}_$(date +%Y%m%d_%H%M%S)"
    
    if [ -d "$WOW_ADDONS_DIR/$addon_name" ]; then
        print_status "Backing up existing $addon_name..."
        cp -r "$WOW_ADDONS_DIR/$addon_name" "$backup_path"
        print_status "Backup created: $backup_path"
    fi
}

# Function to deploy a single addon
deploy_addon() {
    local addon_name=$1
    local dev_addon_path="$DEV_DIR/$addon_name"
    local wow_addon_path="$WOW_ADDONS_DIR/$addon_name"
    
    if [ ! -d "$dev_addon_path" ]; then
        print_warning "Addon $addon_name not found in development directory"
        return 1
    fi
    
    # Check if addon has .toc file
    if [ ! -f "$dev_addon_path/$addon_name.toc" ]; then
        print_warning "Addon $addon_name missing .toc file, skipping..."
        return 1
    fi
    
    # Backup existing addon
    backup_addon "$addon_name"
    
    # Remove existing addon if it exists
    if [ -d "$wow_addon_path" ]; then
        print_status "Removing existing $addon_name..."
        rm -rf "$wow_addon_path"
    fi
    
    # Copy new addon
    print_status "Deploying $addon_name..."
    cp -r "$dev_addon_path" "$wow_addon_path"
    
    if [ $? -eq 0 ]; then
        print_status "Successfully deployed $addon_name"
    else
        print_error "Failed to deploy $addon_name"
        return 1
    fi
}

# Function to list available addons
list_addons() {
    print_status "Available addons in development directory:"
    echo ""
    for addon_dir in "$DEV_DIR"/*; do
        if [ -d "$addon_dir" ]; then
            addon_name=$(basename "$addon_dir")
            if [ -f "$addon_dir/$addon_name.toc" ]; then
                echo "  ✓ $addon_name"
            else
                echo "  ⚠ $addon_name (missing .toc file)"
            fi
        fi
    done
    echo ""
}

# Main script logic
main() {
    echo "=========================================="
    echo "WoW 3.3.5a Addon Deployment Script"
    echo "=========================================="
    echo ""
    
    # Check configuration
    check_configuration
    
    # Check directories
    check_directories
    
    # Show current configuration
    print_config "Development directory: $DEV_DIR"
    print_config "WoW AddOns directory: $WOW_ADDONS_DIR"
    print_config "Backup directory: $BACKUP_DIR"
    echo ""
    
    if [ $# -eq 0 ]; then
        # Show help and available addons
        echo "Usage: $0 [addon_name] or $0 --all"
        echo ""
        echo "Options:"
        echo "  --all     Deploy all available addons"
        echo "  --list    List available addons"
        echo "  [name]    Deploy specific addon"
        echo ""
        list_addons
        exit 0
    fi
    
    case "$1" in
        --all)
            print_status "Deploying all addons..."
            for addon_dir in "$DEV_DIR"/*; do
                if [ -d "$addon_dir" ]; then
                    addon_name=$(basename "$addon_dir")
                    deploy_addon "$addon_name"
                fi
            done
            ;;
        --list)
            list_addons
            ;;
        *)
            # Deploy specific addon(s)
            for addon_name in "$@"; do
                deploy_addon "$addon_name"
            done
            ;;
    esac
    
    echo ""
    print_status "Deployment complete!"
    print_status "Use /reload in WoW to test your addons"
    echo ""
    print_config "Remember to enable the addons in WoW's AddOns menu"
}

# Run main function
main "$@" 