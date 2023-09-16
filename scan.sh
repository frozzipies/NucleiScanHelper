#!/bin/bash

# Define the output directory path
output="./output"

# Check if the output directory already exists
if [ ! -d "$output" ]; then
    # If it doesn't exist, create it
    mkdir "$output"
    echo "Created output directory: $output"
fi

# Clear the terminal screen
clear

echo " _   _            _      _  _____                 _    _      _                 "
echo "| \ | |          | |    (_)/ ____|               | |  | |    | |                "
echo "|  \| |_   _  ___| | ___ _| (___   ___ __ _ _ __ | |__| | ___| |_ __   ___ _ __"
echo "| . \` | | | |/ __| |/ _ \ |\___ \ / __/ _\` | '_ \|  __  |/ _ \ | '_ \ / _ \ '__|"
echo "| |\  | |_| | (__| |  __/ |____) | (_| (_| | | | | |  | |  __/ | |_) |  __/ |   "
echo "|_| \_|\__,_|\___|_|\___|_|_____/ \___\__,_|_| |_|_|  |_|\___|_| .__/ \___|_|   "
echo "                                                              | |                "
echo "                                                              |_|                "

# Ask the user for a domain to scan and save it as a variable
read -p "Enter the domain you want to scan: " domain

# Add a line break for better readability
echo

# Display menu options
echo "Select an option:"
echo "1. Scan only the Domain"
echo "2. Scan all of the Subdomains"
read -p "Enter your choice (1 or 2): " choice

# Process user's choice
case $choice in
    1)
        echo "You chose to scan only the Domain: $domain"
        echo # Line break
        # Ask the user for the output file name and save it as a variable
        read -p "Enter the output file name: " output_file
        echo "Output file name: $output_file"
        
        # Run the 'nuclei' command with the -u option and the specified options
        nuclei -u "$domain" -o "$output/$output_file" -severity low,medium,high,critical
        
        # Inform the user about the output file location
        echo "Output file from the nuclei scan is saved at: $output/$output_file"
        ;;
    2)
        echo "You chose to scan all Subdomains of: $domain"
        echo # Line break
        # Ask the user for the output file name and save it as a variable
        read -p "Enter the output file name: " output_file
        echo "Output file name: $output_file"
        
        # Run subfinder to find subdomains and save them to a temporary file
        subdomains_file="$output/$output_file.subdomains"
        subfinder -d "$domain" -o "$subdomains_file"
        
        # Count the number of subdomains found by subfinder
        subdomains_count=$(wc -l < "$subdomains_file")
        echo "Subdomains file temporarily saved at: $subdomains_file"
        echo "Number of subdomains found by subfinder: $subdomains_count"
        
        # Run httpx-toolkit to check which subdomains are live and save the results to a temporary file
        httpx_active_file="$output/$output_file.active"
        httpx-toolkit -l "$subdomains_file" -o "$httpx_active_file"
        
        # Count the number of live subdomains found by httpx-toolkit
        live_subdomains_count=$(wc -l < "$httpx_active_file")
        echo "httpx-toolkit results temporarily saved at: $httpx_active_file"
        echo "Number of live subdomains found by httpx-toolkit: $live_subdomains_count"
        
        # Run 'nuclei' on the httpx-toolkit results
        nuclei -l "$httpx_active_file" -ept ssl -severity low,medium,high,critical -o "$output/$output_file"
        
        # Inform the user about the output file location
        echo "Final output file from the nuclei scan is saved at: $output/$output_file"
        
        # Remove the temporary files
        rm "$subdomains_file" "$httpx_active_file"
        ;;
    *)
        echo "Invalid choice. Please select 1 or 2."
        ;;
esac
