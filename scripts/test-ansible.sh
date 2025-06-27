#!/bin/bash

# Test script to validate Ansible setup

echo "Testing Ansible setup..."

# Check if ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible not found. Install with: pip install ansible"
    exit 1
fi

# Install required collections
echo "Installing Ansible collections..."
ansible-galaxy collection install -r ansible/requirements.yml

# Test playbook syntax
echo "Testing playbook syntax..."
ansible-playbook ansible/macos_setup.yml --syntax-check

# Dry run test
echo "Running dry-run test..."
ansible-playbook ansible/macos_setup.yml --check --diff

echo "✅ Ansible setup test complete"