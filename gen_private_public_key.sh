#!/bin/bash

# Variables
KEY_NAME="bastion_key"
OUTPUT_DIR="$(pwd)/files"
PRIVATE_KEY_PATH="$OUTPUT_DIR/${KEY_NAME}"
PUBLIC_KEY_PATH="$OUTPUT_DIR/${KEY_NAME}.pub"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f "$PRIVATE_KEY_PATH" -N ""

# Output paths to generated keys
echo "Private key generated and saved to: $PRIVATE_KEY_PATH"
echo "Public key generated and saved to: $PUBLIC_KEY_PATH"
