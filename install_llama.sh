#!/bin/bash

# Install script for llama.cpp on Mac Mini
set -e

echo "=== Installing Homebrew ==="
if ! command -v brew &> /dev/null; then
    export SUDO_ASKPASS=/tmp/sudo_pass.sh
    echo '#!/bin/bash' > /tmp/sudo_pass.sh
    echo 'echo "pass"' >> /tmp/sudo_pass.sh
    chmod +x /tmp/sudo_pass.sh
    
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed"
fi

echo "=== Installing build dependencies ==="
brew install cmake git wget python@3.12

echo "=== Setting up LLM workspace ==="
mkdir -p ~/llm-workspace
cd ~/llm-workspace

echo "=== Cloning and building llama.cpp ==="
if [ ! -d "llama.cpp" ]; then
    git clone https://github.com/ggerganov/llama.cpp.git
fi

cd llama.cpp
git pull origin master

# Build with Metal support for GPU acceleration
make clean
LLAMA_METAL=1 make -j$(sysctl -n hw.ncpu)

echo "=== Installing Python dependencies ==="
python3 -m pip install --upgrade pip
python3 -m pip install numpy sentencepiece

echo "=== Build complete! ==="
echo "llama.cpp has been installed to ~/llm-workspace/llama.cpp"
echo "Run './main --help' to see available options"