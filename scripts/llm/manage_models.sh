#!/bin/bash
# Model management script for llama.cpp

set -e

# Configuration
CONFIG_FILE="$(dirname "$0")/../../config/llm_config.json"
MODELS_DIR="$HOME/llm-workspace/models"
SERVER_SCRIPT="$HOME/llm-workspace/start_server.sh"

# Color output
print_style() {
    if [ "$2" == "info" ] ; then
        COLOR="96m"
    elif [ "$2" == "success" ] ; then
        COLOR="92m"
    elif [ "$2" == "warning" ] ; then
        COLOR="93m"
    elif [ "$2" == "error" ] ; then
        COLOR="91m"
    else
        COLOR="0m"
    fi
    echo -e "\033[${COLOR}$1\033[0m"
}

# Parse JSON config
get_model_info() {
    local model=$1
    local field=$2
    jq -r ".models.\"$model\".$field // empty" "$CONFIG_FILE"
}

# List available models
list_models() {
    print_style "=== Available Models ===" "info"
    jq -r '.models | to_entries[] | "\(.key):\n  Parameters: \(.value.parameters)\n  Size: \(.value.size)\n  Context: \(.value.context_size)\n  Description: \(.value.description)\n"' "$CONFIG_FILE"
    
    print_style "\n=== Downloaded Models ===" "success"
    if [ -d "$MODELS_DIR" ]; then
        ls -lh "$MODELS_DIR"/*.gguf 2>/dev/null || echo "No models downloaded yet"
    else
        echo "Models directory not found"
    fi
}

# Download a model
download_model() {
    local model=$1
    
    if [ -z "$model" ]; then
        print_style "Please specify a model name" "error"
        list_models
        exit 1
    fi
    
    local url=$(get_model_info "$model" "url")
    local filename=$(get_model_info "$model" "filename")
    
    if [ -z "$url" ] || [ -z "$filename" ]; then
        print_style "Model '$model' not found in configuration" "error"
        exit 1
    fi
    
    mkdir -p "$MODELS_DIR"
    local filepath="$MODELS_DIR/$filename"
    
    if [ -f "$filepath" ]; then
        print_style "Model $model already downloaded at $filepath" "info"
        read -p "Re-download? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    print_style "Downloading $model..." "info"
    print_style "URL: $url" "info"
    print_style "Destination: $filepath" "info"
    
    wget -O "$filepath" "$url" --show-progress
    
    print_style "✅ Model $model downloaded successfully!" "success"
}

# Switch active model
switch_model() {
    local model=$1
    
    if [ -z "$model" ]; then
        print_style "Please specify a model name" "error"
        list_models
        exit 1
    fi
    
    local filename=$(get_model_info "$model" "filename")
    local context=$(get_model_info "$model" "context_size")
    
    if [ -z "$filename" ]; then
        print_style "Model '$model' not found in configuration" "error"
        exit 1
    fi
    
    local filepath="$MODELS_DIR/$filename"
    
    if [ ! -f "$filepath" ]; then
        print_style "Model $model not downloaded yet" "error"
        read -p "Download it now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            download_model "$model"
        else
            exit 1
        fi
    fi
    
    # Update the start_server.sh script
    if [ -f "$SERVER_SCRIPT" ]; then
        # Backup current script
        cp "$SERVER_SCRIPT" "$SERVER_SCRIPT.bak"
        
        # Update model path
        sed -i '' "s|-m .*\.gguf|-m $filepath|g" "$SERVER_SCRIPT"
        
        # Update context size if specified
        if [ ! -z "$context" ]; then
            sed -i '' "s|--ctx-size [0-9]*|--ctx-size $context|g" "$SERVER_SCRIPT"
        fi
        
        # Ensure server listens on all interfaces
        sed -i '' "s|--host 127\.0\.0\.1|--host 0.0.0.0|g" "$SERVER_SCRIPT"
        
        print_style "✅ Switched to model: $model" "success"
        print_style "Model file: $filepath" "info"
        print_style "Context size: $context" "info"
        
        # Restart server if running
        if pgrep -f "llama-server" > /dev/null; then
            print_style "Restarting server with new model..." "warning"
            pkill -f "llama-server"
            sleep 2
            nohup "$SERVER_SCRIPT" > /dev/null 2>&1 &
            sleep 5
            if curl -s http://localhost:8080/health | grep -q "ok"; then
                print_style "✅ Server restarted with $model" "success"
            fi
        else
            print_style "Server not running. Start it with: $SERVER_SCRIPT" "info"
        fi
    else
        print_style "Server script not found at $SERVER_SCRIPT" "error"
        exit 1
    fi
}

# Test current model
test_model() {
    print_style "Testing current model..." "info"
    
    if ! curl -s http://localhost:8080/health | grep -q "ok"; then
        print_style "Server not running. Starting..." "warning"
        "$SERVER_SCRIPT"
        sleep 5
    fi
    
    # Test with a simple prompt
    response=$(curl -s http://localhost:8080/v1/chat/completions \
        -H "Content-Type: application/json" \
        -d '{
            "messages": [{"role": "user", "content": "What is 2+2? Answer in one word."}],
            "temperature": 0.7,
            "max_tokens": 10
        }' | jq -r '.choices[0].message.content // empty')
    
    if [ ! -z "$response" ]; then
        print_style "✅ Model is working!" "success"
        print_style "Response: $response" "info"
    else
        print_style "❌ Model test failed" "error"
    fi
}

# Benchmark model
benchmark_model() {
    print_style "Benchmarking current model..." "info"
    
    if [ ! -f "$HOME/llm-workspace/llama.cpp/llama-bench" ]; then
        print_style "Building benchmark tool..." "info"
        cd "$HOME/llm-workspace/llama.cpp"
        make llama-bench
    fi
    
    # Get current model from server script
    model_path=$(grep -o '\--model.*\.gguf' "$SERVER_SCRIPT" | cut -d' ' -f2)
    
    if [ -f "$model_path" ]; then
        print_style "Benchmarking: $model_path" "info"
        "$HOME/llm-workspace/llama.cpp/llama-bench" \
            -m "$model_path" \
            -p 512 \
            -n 128 \
            -ngl -1
    else
        print_style "Model file not found" "error"
    fi
}

# Main menu
case "${1:-}" in
    list)
        list_models
        ;;
    download)
        download_model "$2"
        ;;
    switch)
        switch_model "$2"
        ;;
    test)
        test_model
        ;;
    benchmark)
        benchmark_model
        ;;
    *)
        print_style "LLM Model Manager" "info"
        print_style "=================" "info"
        echo
        echo "Usage: $0 {list|download|switch|test|benchmark} [model_name]"
        echo
        echo "Commands:"
        echo "  list               - List available and downloaded models"
        echo "  download <model>   - Download a specific model"
        echo "  switch <model>     - Switch to a different model"
        echo "  test               - Test the current model"
        echo "  benchmark          - Benchmark the current model"
        echo
        echo "Examples:"
        echo "  $0 list"
        echo "  $0 download qwen2.5-7b"
        echo "  $0 switch gemma2-9b"
        echo "  $0 test"
        echo
        echo "Recommended models for 16GB Mac Mini:"
        echo "  - qwen2.5-7b     : Best balance of speed and capability (4.68GB)"
        echo "  - gemma2-9b      : Excellent reasoning (5.44GB)"
        echo "  - qwen2.5-14b    : Maximum capability (8.7GB, may be slower)"
        echo "  - deepseek-coder : Best for coding tasks (3.82GB)"
        ;;
esac