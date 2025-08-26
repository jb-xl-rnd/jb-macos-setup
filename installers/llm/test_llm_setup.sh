#!/bin/bash

# Test script for local LLM setup
set -e

echo "================================================"
echo "Testing Local LLM Setup"
echo "================================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Test 1: Check if llama.cpp is built
echo -n "Checking llama.cpp build... "
if [ -f ~/llm-workspace/llama.cpp/build/bin/llama-cli ]; then
    success "llama.cpp is built"
else
    error "llama.cpp not found at ~/llm-workspace/llama.cpp/build/bin/llama-cli"
fi

# Test 2: Check if model exists
echo -n "Checking for downloaded models... "
if ls ~/llm-workspace/models/*.gguf >/dev/null 2>&1; then
    success "Models found:"
    ls -lh ~/llm-workspace/models/*.gguf | awk '{print "  " $9 " (" $5 ")"}'
else
    warning "No models found in ~/llm-workspace/models/"
fi

# Test 3: Check if Python environment exists
echo -n "Checking Python environment... "
if [ -d ~/llm-workspace/llm-venv ]; then
    success "Python venv exists"
else
    warning "Python venv not found at ~/llm-workspace/llm-venv"
fi

# Test 4: Check if scripts are installed
echo -n "Checking installed scripts... "
scripts_found=0
for script in llm llm-manager llm-client; do
    if [ -f ~/.local/bin/$script ]; then
        ((scripts_found++))
    fi
done

if [ $scripts_found -eq 3 ]; then
    success "All scripts installed"
else
    warning "Some scripts missing ($scripts_found/3 found)"
fi

# Test 5: Check if launchd service is configured
echo -n "Checking launchd service... "
if [ -f ~/Library/LaunchAgents/com.llama.server.plist ]; then
    success "Service plist exists"
    
    # Check if service is loaded
    if launchctl list | grep -q "com.llama.server"; then
        success "Service is loaded"
    else
        warning "Service exists but not loaded"
    fi
else
    warning "Service plist not found"
fi

# Test 6: Check if server is running
echo -n "Checking server status... "
if curl -s http://127.0.0.1:8080/health 2>/dev/null | grep -q "ok"; then
    success "Server is running at http://127.0.0.1:8080"
    
    # Test 7: Test inference
    echo -n "Testing inference API... "
    response=$(curl -s -X POST http://127.0.0.1:8080/v1/chat/completions \
        -H "Content-Type: application/json" \
        -d '{"messages":[{"role":"user","content":"Say hello in 5 words or less"}],"max_tokens":20}' 2>/dev/null)
    
    if echo "$response" | grep -q "choices"; then
        success "Inference API working"
        echo "  Response preview: $(echo "$response" | grep -o '"content":"[^"]*"' | head -1)"
    else
        warning "Inference API not responding correctly"
    fi
else
    warning "Server not running at http://127.0.0.1:8080"
    echo "  Start with: llm-manager server start"
fi

# Test 8: Test CLI tools
echo -n "Testing CLI tools... "
if [ -f ~/.local/bin/llm ]; then
    if ~/.local/bin/llm --mode health >/dev/null 2>&1; then
        success "CLI tools working"
    else
        warning "CLI tools installed but not working properly"
    fi
else
    warning "CLI tools not found"
fi

echo ""
echo "================================================"
echo "Test Summary:"
echo "================================================"

if [ -f ~/llm-workspace/llama.cpp/build/bin/llama-cli ] && \
   ls ~/llm-workspace/models/*.gguf >/dev/null 2>&1 && \
   curl -s http://127.0.0.1:8080/health 2>/dev/null | grep -q "ok"; then
    success "LLM setup is fully functional!"
    echo ""
    echo "Quick start commands:"
    echo "  llm --prompt \"Your question here\"     # Ask a question"
    echo "  llm --interactive                      # Interactive chat"
    echo "  llm-manager list                       # List models"
    echo "  llm-manager server status             # Check server"
else
    warning "LLM setup is partially complete"
    echo ""
    echo "To complete setup, run:"
    echo "  ansible-playbook ansible/macos_setup.yml --tags llm"
fi

echo "================================================"