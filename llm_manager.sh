#!/bin/bash

# LLM Manager Script for llama.cpp
# Provides easy model management and inference

CONFIG_FILE="$HOME/llm_config.json"
LLAMA_CPP_DIR="$HOME/llm-workspace/llama.cpp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to list available models
list_models() {
    print_status "Available models:"
    echo ""
    ls -lh ~/llm-workspace/models/*.gguf 2>/dev/null || echo "No models found in ~/llm-workspace/models/"
    echo ""
    print_status "Configured models (from config):"
    python3 -c "
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)
    for name, info in config['models'].items():
        print(f\"  - {name}: {info['description']} ({info['size']})\")"
}

# Function to download a model
download_model() {
    local model_url="$1"
    local model_name="$2"
    
    if [ -z "$model_url" ] || [ -z "$model_name" ]; then
        print_error "Usage: $0 download <model_url> <model_name>"
        return 1
    fi
    
    print_status "Downloading $model_name..."
    cd ~/llm-workspace/models
    curl -L -o "$model_name" "$model_url"
    print_status "Model downloaded: $model_name"
}

# Function to run inference
run_inference() {
    local model_path="$1"
    local prompt="$2"
    local extra_args="${3:-}"
    
    if [ ! -f "$model_path" ]; then
        # Check if it's a relative path from models directory
        if [ -f "$HOME/llm-workspace/models/$model_path" ]; then
            model_path="$HOME/llm-workspace/models/$model_path"
        else
            print_error "Model not found: $model_path"
            return 1
        fi
    fi
    
    print_status "Running inference with $(basename $model_path)..."
    
    cd "$LLAMA_CPP_DIR/build"
    ./bin/llama-cli \
        -m "$model_path" \
        -p "$prompt" \
        -n 512 \
        --temp 0.7 \
        --top-p 0.95 \
        --repeat-penalty 1.1 \
        -ngl -1 \
        $extra_args
}

# Function to start server
start_server() {
    local model_path="$1"
    local port="${2:-8080}"
    
    if [ ! -f "$model_path" ]; then
        # Check if it's a relative path from models directory
        if [ -f "$HOME/llm-workspace/models/$model_path" ]; then
            model_path="$HOME/llm-workspace/models/$model_path"
        else
            print_error "Model not found: $model_path"
            return 1
        fi
    fi
    
    print_status "Starting server with $(basename $model_path) on port $port..."
    print_status "API will be available at http://0.0.0.0:$port"
    print_status "OpenAI-compatible endpoint: http://0.0.0.0:$port/v1/chat/completions"
    
    cd "$LLAMA_CPP_DIR/build"
    ./bin/llama-server \
        -m "$model_path" \
        --host 0.0.0.0 \
        --port "$port" \
        -c 2048 \
        -ngl -1 \
        --metrics \
        --parallel 4 \
        --cont-batching \
        --flash-attn
}

# Function to test the setup
test_setup() {
    print_status "Testing LLM setup..."
    
    # Check if llama.cpp is built
    if [ ! -f "$LLAMA_CPP_DIR/build/bin/llama-cli" ]; then
        print_error "llama-cli not found. Please build llama.cpp first."
        return 1
    fi
    
    # Check for models
    local model_count=$(ls ~/llm-workspace/models/*.gguf 2>/dev/null | wc -l)
    if [ "$model_count" -eq 0 ]; then
        print_warning "No models found in ~/llm-workspace/models/"
        return 1
    fi
    
    # Run a simple test with the first available model
    local first_model=$(ls ~/llm-workspace/models/*.gguf 2>/dev/null | head -1)
    print_status "Testing with model: $(basename $first_model)"
    
    run_inference "$first_model" "Hello! Please respond with a single sentence." "--n-predict 50"
    
    print_status "Test complete!"
}

# Function to show help
show_help() {
    echo "LLM Manager for llama.cpp"
    echo ""
    echo "Usage: $0 <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  list                              - List available models"
    echo "  download <url> <filename>         - Download a model from URL"
    echo "  inference <model> <prompt>        - Run inference with a model"
    echo "  server <model> [port]            - Start API server (default port: 8080)"
    echo "  test                             - Test the LLM setup"
    echo "  help                             - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 download https://example.com/model.gguf model.gguf"
    echo "  $0 inference tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf \"What is the capital of France?\""
    echo "  $0 server tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf 8080"
    echo "  $0 test"
}

# Main script logic
case "$1" in
    list)
        list_models
        ;;
    download)
        download_model "$2" "$3"
        ;;
    inference)
        run_inference "$2" "$3" "$4"
        ;;
    server)
        start_server "$2" "$3"
        ;;
    test)
        test_setup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac