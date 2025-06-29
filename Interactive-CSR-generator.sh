#!/bin/bash
# Interactive-CSR-generator.sh
# This script interactively creates a CSR file.
# It will generate a RSA key, a configuration file, and then output the CSR.

DIVIDER="================================================================================="

echo -e "$DIVIDER"

#  Step 1: Display ASCII Art 
cat <<'EOF'
 _______  _______  ______        _______  _______  __    _ 
|       ||       ||    _ |      |       ||       ||  |  | |
|       ||  _____||   | ||      |    ___||    ___||   |_| |
|       || |_____ |   |_||_     |   | __ |   |___ |       |
|      _||_____  ||    __  |    |   ||  ||    ___||  _    |
|     |_  _____| ||   |  | |    |   |_| ||   |___ | | |   |
|_______||_______||___|  |_|    |_______||_______||_|  |__|
EOF


echo -e "$DIVIDER"

#  Step 2: Ask for CSR Directory 
default_dir="$HOME/USER/CSR"
read -p "Enter CSR directory [Default: $default_dir]: " user_csr_dir
CSR_DIR="${user_csr_dir:-$default_dir}"
if [ ! -d "$CSR_DIR" ]; then
    mkdir -p "$CSR_DIR"
    echo "Directory $CSR_DIR was created."
else
    echo "Directory $CSR_DIR already exists."
fi

echo ""

# --- Step 3: Ask for CSR Type (Wildcard vs. Standard) ---
read -p $'Enter 1 for wildcard (*.example.com)\nEnter 2 for standard (example.com)\n\n1 OR 2? [Default is 1] : ' csr_type
csr_type=${csr_type:-1}

# Validate the input: only 1 or 2 are allowed.
if [[ "$csr_type" != "1" && "$csr_type" != "2" ]]; then
    echo "Error: Invalid input. Must be 1 for wildcard or 2 for standard."
    exit 1
fi

#  Step 4: Ask for the Domain Name 
if [ "$csr_type" -eq 1 ]; then
    echo "You have chosen a wildcard CSR. The domain must start with '*.'"
else
    echo "You have chosen a standard CSR. The domain must NOT start with '*.'"
fi

read -p "Enter the domain name: " domain_name
#  Step 5: Trim whitespace 
domain_name=$(echo "$domain_name" | xargs)

#  Validate the entered domain based on chosen type 
if [ "$csr_type" -eq 1 ]; then
    if [[ "$domain_name" != \*.* ]]; then
        echo "Error: For a wildcard CSR, the domain must start with '*.'"
        exit 1
    fi
else
    if [[ "$domain_name" =~ ^\*\..+ ]]; then
        echo "Error: For a standard CSR, the domain should not start with '*.'"
        exit 1
    fi
fi

# If a wildcard domain was provided, change "*.example.com" to "star.example.com" for the CSR file name.
if [ "$csr_type" -eq 1 ]; then
    effective_domain=$(echo "$domain_name" | sed 's/^\*\./star./')
else
    effective_domain="$domain_name"
fi

echo -e "\n$DIVIDER\nCSR is being created in $CSR_DIR/$effective_domain \n$DIVIDER\n"

#  Step 6: Confirm the Entered Domain 
read -p "Is the entered domain '$domain_name' correct? (Y/N) [Default Y]: " confirm
confirm=${confirm:-Y}
# Validate that the input is one of Y, y, N, or n.
if [[ ! "$confirm" =~ ^[YyNn]$ ]]; then
    echo "Error: Invalid input. Must be Y or N."
    exit 1
fi

if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo "Aborted by user."
    exit 1
fi
echo ""

#  Step 7: Create Domain Directory 
DOMAIN_DIR="$CSR_DIR/$effective_domain"
if [ -d "$DOMAIN_DIR" ]; then
    echo "Error: Directory $DOMAIN_DIR already exists. Exiting to avoid overwriting."
    exit 1
else
    mkdir -p "$DOMAIN_DIR"
    echo -e "$DIVIDER\nDirectory $DOMAIN_DIR created.\n$DIVIDER\n"
fi

cd "$DOMAIN_DIR" || { echo "Failed to enter directory $DOMAIN_DIR"; exit 1; }

#  Step 8: Create RSA 2048 Key echo "Error: Directory $DOMAIN_DIR already exists. Exiting to avoid overwriting."
echo -e "$DIVIDER\nCreating RSA 2048 Key for $domain_name ...\n"
if openssl genpkey -algorithm RSA -out "$effective_domain.key" -pkeyopt rsa_keygen_bits:2048; then
    echo -e "\nCreation of RSA 2048 Key for $domain_name was successful.\n$DIVIDER"
else
    echo "Error: Failed to create RSA key."
    exit 1
fi
echo ""

#  Step 9: Create CSR Configuration File 
CONFIG_FILE="$domain_name.csr.cnf"
if [ "$csr_type" -eq 1 ]; then
    # For wildcard CSR, process DNS.1 by removing the "*." prefix.
    processed_domain="${domain_name#*.}"
    cat > "$CONFIG_FILE" <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = v3_req

[ dn ]
CN = $domain_name
C = C
ST = ST
L = L
O = O
OU = OU

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $processed_domain
DNS.2 = $domain_name
EOF
else
    # For standard CSR
    cat > "$CONFIG_FILE" <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = v3_req

[ dn ]
CN = $domain_name
C = C
ST = ST
L = L
O = O
OU = OU

[ v3_req ]
keyUsage=keyEncipherment, dataEncipherment
extendedKeyUsage=serverAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $domain_name
DNS.2 = www.$domain_name
EOF
fi
echo -e "$DIVIDER\nConfiguration file $CONFIG_FILE created.\n$DIVIDER"

#  Step 10: Create the CSR 
echo -e "\n$DIVIDER\nCreating CSR for $domain_name ...\n"


if openssl req -new -key "$effective_domain.key" -out "$effective_domain.csr" -config "$CONFIG_FILE"; then
    echo -e "CSR for $domain_name created successfully as $effective_domain.csr.\n$DIVIDER"
else
    echo "Error: Failed to create CSR."
    exit 1
fi
echo ""

#  Step 11: Display the Created CSR
echo -e "$DIVIDER\nOperation completed. Outputting your $CSR_DIR/$effective_domain.csr :\n\n"
openssl req -text -noout -verify -in "$effective_domain.csr"
echo -e "\n$DIVIDER"

#  Step 12: Exit Script 
exit 0