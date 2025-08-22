#!/bin/bash
# Direct LLM installation script (no ansible, no popups)

set -e

echo "=== Direct LLM Installation ==="
echo "This script installs llama.cpp without triggering permission popups"

# Prevent sleep
caffeinate -dims bash << 'INSTALL'

# Setup environment
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export HOMEBREW_NO_AUTO_UPDATE=1

echo "=== Step 1: Installing cmake if needed ==="
if ! command -v cmake &> /dev/null; then
    echo "Installing cmake..."
    brew install cmake
else
    echo "cmake already installed"
fi

echo "=== Step 2: Creating directories ==="
mkdir -p ~/llm-workspace/models
mkdir -p ~/llm-workspace/logs
cd ~/llm-workspace

echo "=== Step 3: Cloning llama.cpp ==="
if [ ! -d "llama.cpp" ]; then
    git clone https://github.com/ggerganov/llama.cpp.git
else
    cd llama.cpp
    git pull
    cd ..
fi

echo "=== Step 4: Building llama.cpp ==="
cd llama.cpp
rm -rf build
mkdir -p build
cd build

# Build with CMake (already installed via brew)
cmake .. -DLLAMA_METAL=ON -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release -j$(sysctl -n hw.ncpu)

echo "=== Step 5: Downloading Qwen 2.5 7B model ==="
cd ~/llm-workspace/models
if [ ! -f "Qwen2.5-7B-Instruct-Q4_K_M.gguf" ]; then
    echo "Downloading Qwen 2.5 7B model (4.92GB - this will take a while)..."
    curl -L -o Qwen2.5-7B-Instruct-Q4_K_M.gguf \
        https://huggingface.co/bartowski/Qwen2.5-7B-Instruct-GGUF/resolve/main/Qwen2.5-7B-Instruct-Q4_K_M.gguf
else
    echo "Model already downloaded"
fi

echo "=== Step 6: Creating launch script ==="
cat > ~/llm-workspace/start_server.sh << 'SCRIPT'
#!/bin/bash
cd ~/llm-workspace
./llama.cpp/build/bin/llama-server \
    -m models/Qwen2.5-7B-Instruct-Q4_K_M.gguf \
    --host 0.0.0.0 \
    --port 8080 \
    -ngl -1 \
    --ctx-size 32768 \
    --parallel 4 \
    --cont-batching \
    --flash-attn \
    > logs/server.log 2>&1 &

echo $! > logs/server.pid
echo "Server started with PID $(cat logs/server.pid)"
echo "Model: Qwen 2.5 7B"
echo "Access at: http://0.0.0.0:8080"
SCRIPT
chmod +x ~/llm-workspace/start_server.sh

echo "=== Step 7: Creating test script ==="
cat > ~/llm-workspace/test_llm.sh << 'TEST'
#!/bin/bash
echo "Testing LLM server..."

# Start server if not running
if ! curl -s http://127.0.0.1:8080/health | grep -q "ok"; then
    echo "Starting server..."
    ~/llm-workspace/start_server.sh
    sleep 5
fi

# Test health
if curl -s http://127.0.0.1:8080/health | grep -q "ok"; then
    echo "✅ Server is healthy"
    
    # Test inference
    echo "Testing inference..."
    response=$(curl -s -X POST http://127.0.0.1:8080/v1/chat/completions \
        -H "Content-Type: application/json" \
        -d '{"messages":[{"role":"user","content":"Say hello"}],"max_tokens":20}')
    
    if echo "$response" | grep -q "choices"; then
        echo "✅ Inference working"
        echo "Response: $(echo "$response" | grep -o '"content":"[^"]*"' | head -1)"
    else
        echo "❌ Inference failed"
    fi
else
    echo "❌ Server not responding"
fi
TEST
chmod +x ~/llm-workspace/test_llm.sh

echo "=== Step 8: Starting server ==="
~/llm-workspace/start_server.sh

sleep 5

echo "=== Step 9: Testing setup ==="
~/llm-workspace/test_llm.sh

echo "=== Installation Complete ==="
echo ""
echo "Commands:"
echo "  Start server: ~/llm-workspace/start_server.sh"
echo "  Test setup:   ~/llm-workspace/test_llm.sh"
echo "  Server URL:   http://127.0.0.1:8080"
echo ""

INSTALL