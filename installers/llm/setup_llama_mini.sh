#!/bin/bash

# Setup script for llama.cpp on Mac Mini
set -e

echo "=== Step 1: Installing Homebrew ==="
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    echo pass | sudo -S true  # Cache sudo
    CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
fi

echo "=== Step 2: Installing build dependencies ==="
/opt/homebrew/bin/brew install cmake git wget python@3.12

echo "=== Step 3: Setting up LLM workspace ==="
mkdir -p ~/llm-workspace
cd ~/llm-workspace

echo "=== Step 4: Cloning llama.cpp ==="
if [ ! -d "llama.cpp" ]; then
    git clone https://github.com/ggerganov/llama.cpp.git
else
    cd llama.cpp
    git pull origin master
    cd ..
fi

echo "=== Step 5: Building llama.cpp with Metal support ==="
cd llama.cpp
make clean
LLAMA_METAL=1 make -j$(sysctl -n hw.ncpu)

echo "=== Step 6: Installing Python dependencies ==="
/opt/homebrew/bin/python3 -m pip install --upgrade pip
/opt/homebrew/bin/python3 -m pip install numpy sentencepiece transformers

echo "=== Build complete! ==="
echo "llama.cpp installed at: ~/llm-workspace/llama.cpp"
ls -la main