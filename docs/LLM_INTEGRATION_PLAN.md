# LLM (llama.cpp) Integration Plan for MacOS Setup

## Overview
This document outlines the integration of llama.cpp and local LLM capabilities into the existing MacOS ansible/bash setup infrastructure. The goal is to seamlessly add LLM support while maintaining consistency with the current architecture.

## Current Setup Analysis

### Existing Structure
- **Main playbook**: `ansible/macos_setup.yml` - orchestrates all setup tasks
- **Package management**: `config/packages.json` - centralized package definitions
- **Task modules**: `ansible/tasks/` - individual task files for specific components
- **Configuration**: JSON-based configuration files in `config/`
- **Feature flags**: Used to enable/disable specific features

### Integration Points
1. Package installation via Homebrew
2. Task-based ansible modules
3. Configuration management via JSON files
4. Service management (launchd integration)

## Proposed Changes

### 1. Package Configuration Updates

**File**: `config/packages.json`
```json
Add to brew_packages:
- {"name": "cmake", "description": "Cross-platform make"} (already exists)
- {"name": "git", "description": "Distributed revision control system"} (already exists)
- {"name": "wget", "description": "Internet file retriever"} (already exists)
- {"name": "python@3.12", "description": "Interpreted, interactive, object-oriented programming language"} (already exists)
```

### 2. New Configuration File

**File**: `config/llm_config.json`
```json
{
  "llm_settings": {
    "enabled": true,
    "install_dir": "~/llm-workspace",
    "models_dir": "~/llm-workspace/models",
    "logs_dir": "~/llm-workspace/logs",
    "default_model": "tinyllama",
    "server_port": 8080,
    "server_host": "127.0.0.1",
    "auto_start": true,
    "metal_acceleration": true
  },
  "models": {
    "tinyllama": {
      "url": "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf",
      "filename": "tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf",
      "size": "637MB",
      "context_size": 2048,
      "description": "Lightweight model for basic tasks"
    }
  },
  "feature_flags": {
    "install_llama_cpp": true,
    "download_models": true,
    "setup_service": true,
    "install_client_tools": true
  }
}
```

### 3. New Ansible Task Module

**File**: `ansible/tasks/llama_cpp.yml`
```yaml
---
- name: LLama.cpp Installation and Configuration
  block:
    - name: Create LLM workspace directories
      file:
        path: "{{ item }}"
        state: directory
        mode: '0755'
      loop:
        - "{{ ansible_env.HOME }}/llm-workspace"
        - "{{ ansible_env.HOME }}/llm-workspace/models"
        - "{{ ansible_env.HOME }}/llm-workspace/logs"
    
    - name: Clone llama.cpp repository
      git:
        repo: https://github.com/ggerganov/llama.cpp.git
        dest: "{{ ansible_env.HOME }}/llm-workspace/llama.cpp"
        version: master
    
    - name: Build llama.cpp with Metal support
      shell: |
        cd {{ ansible_env.HOME }}/llm-workspace/llama.cpp
        mkdir -p build && cd build
        cmake .. -DLLAMA_METAL=ON
        cmake --build . --config Release -j$(sysctl -n hw.ncpu)
      args:
        creates: "{{ ansible_env.HOME }}/llm-workspace/llama.cpp/build/bin/llama-cli"
    
    - name: Download default model
      get_url:
        url: "{{ llm_config.models.tinyllama.url }}"
        dest: "{{ ansible_env.HOME }}/llm-workspace/models/{{ llm_config.models.tinyllama.filename }}"
        mode: '0644'
      when: llm_config.feature_flags.download_models
    
    - name: Install Python client dependencies
      pip:
        name: requests
        state: present
        executable: "{{ ansible_env.HOME }}/.local/bin/uv"
        extra_args: "--system --break-system-packages"
      when: use_uv
    
    - name: Deploy LLM management scripts
      template:
        src: "{{ item.src }}"
        dest: "{{ item.dest }}"
        mode: "{{ item.mode }}"
      loop:
        - { src: "llm_manager.sh.j2", dest: "{{ ansible_env.HOME }}/.local/bin/llm-manager", mode: "0755" }
        - { src: "llm_client.py.j2", dest: "{{ ansible_env.HOME }}/.local/bin/llm-client", mode: "0755" }
    
    - name: Setup launchd service for LLM server
      template:
        src: com.llama.server.plist.j2
        dest: "{{ ansible_env.HOME }}/Library/LaunchAgents/com.llama.server.plist"
        mode: '0644'
      when: llm_config.feature_flags.setup_service
    
    - name: Load LLM server service
      command: launchctl load -w {{ ansible_env.HOME }}/Library/LaunchAgents/com.llama.server.plist
      when: llm_config.feature_flags.setup_service and llm_config.llm_settings.auto_start
```

### 4. Template Files

**File**: `ansible/templates/llm_manager.sh.j2`
- Modified version of current `llm_manager.sh`
- Server URL changed to `127.0.0.1:{{ llm_config.llm_settings.server_port }}`
- Paths use ansible variables
- Local-only testing (no remote SSH)

**File**: `ansible/templates/llm_client.py.j2`
- Modified version of current `llm_client.py`
- Default server: `http://127.0.0.1:{{ llm_config.llm_settings.server_port }}`
- Remove remote-specific code
- Add local health checks

**File**: `ansible/templates/com.llama.server.plist.j2`
- Launchd configuration template
- Uses ansible variables for paths and settings
- Local execution only

### 5. Main Playbook Integration

**Update**: `ansible/macos_setup.yml`
```yaml
Add to vars_files:
  - "../config/llm_config.json"

Add to vars:
  install_llama_cpp: "{{ llm_config.feature_flags.install_llama_cpp | default(false) }}"

Add to tasks section:
  # Include LLama.cpp setup
  - name: Setup LLama.cpp and local LLM
    include_tasks: tasks/llama_cpp.yml
    when: install_llama_cpp
    tags: [llm, llama-cpp, ai]
```

### 6. Shell Script Modifications

**Current Scripts to Modify**:
1. `llm_manager.sh` → Convert to local-only operation
   - Remove SSH commands
   - Use localhost/127.0.0.1 instead of remote IP
   - Adjust paths to use local directories

2. `llm_client.py` → Simplify for local use
   - Default to `http://127.0.0.1:8080`
   - Remove remote connection logic
   - Add local service status checks

3. Create wrapper script: `~/.local/bin/llm`
   ```bash
   #!/bin/bash
   # Simple wrapper for local LLM interaction
   exec python3 ~/.local/bin/llm-client "$@"
   ```

### 7. Testing Strategy

**Local Testing Script**: `test_llm_setup.sh`
```bash
#!/bin/bash
# Test script for local LLM setup

echo "Testing LLM Setup..."

# Check if llama.cpp is built
if [ -f ~/llm-workspace/llama.cpp/build/bin/llama-cli ]; then
    echo "✅ llama.cpp is built"
else
    echo "❌ llama.cpp not found"
    exit 1
fi

# Check if model exists
if [ -f ~/llm-workspace/models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf ]; then
    echo "✅ Model downloaded"
else
    echo "❌ Model not found"
    exit 1
fi

# Check if server is running
if curl -s http://127.0.0.1:8080/health | grep -q "ok"; then
    echo "✅ Server is running"
else
    echo "❌ Server not responding"
fi

# Test inference
response=$(curl -s -X POST http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Say hello"}],"max_tokens":10}')

if echo "$response" | grep -q "choices"; then
    echo "✅ Inference working"
else
    echo "❌ Inference failed"
fi

echo "Test complete!"
```

## Implementation Steps

1. **Phase 1: Core Setup**
   - Create `config/llm_config.json`
   - Create `ansible/tasks/llama_cpp.yml`
   - Create template files

2. **Phase 2: Script Adaptation**
   - Modify existing scripts for local-only operation
   - Create ansible templates from modified scripts
   - Add wrapper scripts for convenience

3. **Phase 3: Integration**
   - Update main playbook
   - Add feature flags
   - Test with existing setup

4. **Phase 4: Testing**
   - Run ansible playbook with LLM tasks
   - Verify service startup
   - Test local inference

## Benefits of This Approach

1. **Consistency**: Follows existing ansible/JSON configuration pattern
2. **Modularity**: LLM setup is optional via feature flags
3. **Local-First**: No dependency on remote machines
4. **Maintainability**: Uses existing infrastructure
5. **Extensibility**: Easy to add more models or features

## Migration from Current Setup

For users with the current remote setup:
1. Stop remote server: `ssh dev@192.168.1.208 "pkill llama-server"`
2. Run ansible playbook locally: `ansible-playbook ansible/macos_setup.yml --tags llm`
3. Verify local service: `llm --mode health`

## Future Enhancements

1. **Model Management UI**: Web interface for model selection
2. **Multiple Model Support**: Easy switching between models
3. **Performance Monitoring**: Track inference speeds and resource usage
4. **Integration with IDE**: VSCode/Neovim plugins for local LLM
5. **Batch Processing**: Support for processing multiple prompts