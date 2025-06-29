#!/bin/bash

# WoW 3.3.5a Addon Deployment Script
# This script copies addons from development to WoW directory for testing

# Configuration
DEV_DIR="/run/media/tobarisu/Omega/project_mods/wow_addon_dev/addons"
WOW_ADDONS_DIR="/run/media/tobarisu/Epsilon/ProjectEpoch/World.of.Warcraft.3.3.5a.Truewow/Data/enUS/Interface/AddOns"
BACKUP_DIR="/run/media/tobarisu/Omega/project_mods/wow_addon_dev/backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if directories exist
if [ ! -d "$DEV_DIR" ]; then
    print_error "Development directory not found: $DEV_DIR"
    exit 1
fi

if [ ! -d "$WOW_ADDONS_DIR" ]; then
    print_error "WoW AddOns directory not found: $WOW_ADDONS_DIR"
    exit 1
fi

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

# Main deployment logic
if [ $# -eq 0 ]; then
    # Deploy all addons
    print_status "Deploying all addons..."
    for addon_dir in "$DEV_DIR"/*; do
        if [ -d "$addon_dir" ]; then
            addon_name=$(basename "$addon_dir")
            deploy_addon "$addon_name"
        fi
    done
else
    # Deploy specific addon(s)
    for addon_name in "$@"; do
        deploy_addon "$addon_name"
    done
fi

print_status "Deployment complete!"
print_status "Use /reload in WoW to test your addons" 