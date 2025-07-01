#!/usr/bin/env python3
"""
WoW Addon Log Exporter
Exports logs from WoW saved variables to local files for debugging
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path

def find_wow_saved_variables():
    """Find WoW SavedVariables directory"""
    possible_paths = [
        # Linux Wine paths
        os.path.expanduser("~/.wine/drive_c/Program Files (x86)/World of Warcraft/WTF/Account/*/SavedVariables/"),
        os.path.expanduser("~/.wine/drive_c/Program Files/World of Warcraft/WTF/Account/*/SavedVariables/"),
        # Windows paths (if running on Windows)
        "C:/Program Files (x86)/World of Warcraft/WTF/Account/*/SavedVariables/",
        "C:/Program Files/World of Warcraft/WTF/Account/*/SavedVariables/",
        # macOS paths
        "/Applications/World of Warcraft/WTF/Account/*/SavedVariables/",
    ]
    
    for pattern in possible_paths:
        import glob
        matches = glob.glob(pattern)
        if matches:
            return matches[0]  # Return first match
    
    return None

def export_bugcatcher_logs(saved_vars_path, output_dir):
    """Export BugCatcher logs to local files"""
    bugcatcher_file = os.path.join(saved_vars_path, "BugCatcher.lua")
    
    if not os.path.exists(bugcatcher_file):
        print(f"BugCatcher.lua not found at {bugcatcher_file}")
        return False
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Read the Lua file and extract data
    try:
        with open(bugcatcher_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Simple parsing - look for BugCatcherDB
        # This is a basic parser, you might need to enhance it
        if "BugCatcherDB" in content:
            print(f"Found BugCatcher data in {bugcatcher_file}")
            
            # Create a timestamped log file
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            log_file = os.path.join(output_dir, f"bugcatcher_logs_{timestamp}.txt")
            
            # Extract log data (this is a simplified approach)
            # In a real implementation, you'd need a proper Lua parser
            with open(log_file, 'w', encoding='utf-8') as f:
                f.write(f"BugCatcher Log Export - {datetime.now().isoformat()}\n")
                f.write("=" * 50 + "\n\n")
                f.write("Note: This is a basic export. For full functionality,\n")
                f.write("use /bugcatcher export in-game to see all logs.\n\n")
                f.write("Raw SavedVariables content:\n")
                f.write("-" * 30 + "\n")
                f.write(content)
            
            print(f"Exported logs to {log_file}")
            return True
        else:
            print("No BugCatcherDB found in the file")
            return False
            
    except Exception as e:
        print(f"Error reading {bugcatcher_file}: {e}")
        return False

def export_all_addon_logs(saved_vars_path, output_dir):
    """Export logs from all addons"""
    if not os.path.exists(saved_vars_path):
        print(f"SavedVariables directory not found: {saved_vars_path}")
        return False
    
    print(f"Scanning for addon logs in: {saved_vars_path}")
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # List all .lua files in SavedVariables
    lua_files = [f for f in os.listdir(saved_vars_path) if f.endswith('.lua')]
    
    if not lua_files:
        print("No .lua files found in SavedVariables directory")
        return False
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    summary_file = os.path.join(output_dir, f"addon_logs_summary_{timestamp}.txt")
    
    with open(summary_file, 'w', encoding='utf-8') as summary:
        summary.write(f"WoW Addon Logs Summary - {datetime.now().isoformat()}\n")
        summary.write("=" * 50 + "\n\n")
        
        for lua_file in lua_files:
            file_path = os.path.join(saved_vars_path, lua_file)
            addon_name = lua_file.replace('.lua', '')
            
            summary.write(f"Addon: {addon_name}\n")
            summary.write(f"File: {lua_file}\n")
            summary.write(f"Size: {os.path.getsize(file_path)} bytes\n")
            summary.write("-" * 30 + "\n")
            
            # Check if it contains log data
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    if any(keyword in content for keyword in ['log', 'Log', 'LOG', 'error', 'Error', 'ERROR']):
                        summary.write("Contains potential log data\n")
                        
                        # Create individual addon log file
                        addon_log_file = os.path.join(output_dir, f"{addon_name}_logs_{timestamp}.txt")
                        with open(addon_log_file, 'w', encoding='utf-8') as f:
                            f.write(f"{addon_name} Log Export - {datetime.now().isoformat()}\n")
                            f.write("=" * 50 + "\n\n")
                            f.write(content)
                        summary.write(f"Exported to: {addon_log_file}\n")
                    else:
                        summary.write("No obvious log data found\n")
            except Exception as e:
                summary.write(f"Error reading file: {e}\n")
            
            summary.write("\n")
    
    print(f"Summary exported to: {summary_file}")
    return True

def main():
    """Main function"""
    print("WoW Addon Log Exporter")
    print("=" * 30)
    
    # Find WoW SavedVariables directory
    saved_vars_path = find_wow_saved_variables()
    
    if not saved_vars_path:
        print("Could not find WoW SavedVariables directory.")
        print("Please specify the path manually:")
        print("python export_logs.py <saved_variables_path> [output_directory]")
        return 1
    
    print(f"Found SavedVariables at: {saved_vars_path}")
    
    # Determine output directory
    if len(sys.argv) > 2:
        output_dir = sys.argv[2]
    else:
        # Default to current directory
        output_dir = "wow_logs"
    
    print(f"Exporting logs to: {output_dir}")
    
    # Export BugCatcher logs specifically
    if export_bugcatcher_logs(saved_vars_path, output_dir):
        print("BugCatcher logs exported successfully")
    else:
        print("No BugCatcher logs found or error occurred")
    
    # Export all addon logs
    if export_all_addon_logs(saved_vars_path, output_dir):
        print("All addon logs exported successfully")
    else:
        print("Error exporting addon logs")
    
    print(f"\nLogs exported to: {os.path.abspath(output_dir)}")
    return 0

if __name__ == "__main__":
    sys.exit(main()) 