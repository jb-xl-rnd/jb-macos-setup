#!/usr/bin/env python3

"""
LLM Client for interacting with llama.cpp server
Compatible with OpenAI API format
"""

import json
import requests
import sys
import argparse
from typing import Optional, List, Dict

class LLMClient:
    def __init__(self, base_url: str = "http://192.168.1.208:8080"):
        self.base_url = base_url
        self.headers = {"Content-Type": "application/json"}
    
    def health_check(self) -> bool:
        """Check if the server is running"""
        try:
            response = requests.get(f"{self.base_url}/health", timeout=5)
            return response.json().get("status") == "ok"
        except:
            return False
    
    def chat(self, 
             messages: List[Dict[str, str]], 
             temperature: float = 0.7,
             max_tokens: int = 512,
             stream: bool = False) -> Dict:
        """Send a chat completion request"""
        payload = {
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "stream": stream
        }
        
        response = requests.post(
            f"{self.base_url}/v1/chat/completions",
            headers=self.headers,
            json=payload,
            stream=stream
        )
        
        if stream:
            return self._handle_stream(response)
        else:
            return response.json()
    
    def _handle_stream(self, response):
        """Handle streaming responses"""
        for line in response.iter_lines():
            if line:
                line = line.decode('utf-8')
                if line.startswith("data: "):
                    data = line[6:]
                    if data != "[DONE]":
                        try:
                            chunk = json.loads(data)
                            if chunk.get("choices") and len(chunk["choices"]) > 0:
                                content = chunk["choices"][0].get("delta", {}).get("content")
                                if content:
                                    print(content, end="", flush=True)
                        except (json.JSONDecodeError, KeyError, IndexError):
                            pass
        print()  # New line at the end
    
    def completion(self, prompt: str, temperature: float = 0.7, max_tokens: int = 512) -> str:
        """Simple completion API"""
        payload = {
            "prompt": prompt,
            "temperature": temperature,
            "n_predict": max_tokens
        }
        
        response = requests.post(
            f"{self.base_url}/completion",
            headers=self.headers,
            json=payload
        )
        
        return response.json().get("content", "")
    
    def models(self) -> List[str]:
        """List available models"""
        try:
            response = requests.get(f"{self.base_url}/v1/models")
            return response.json()
        except:
            return []

def main():
    parser = argparse.ArgumentParser(description="LLM Client for llama.cpp server")
    parser.add_argument("--server", default="http://192.168.1.208:8080", 
                        help="Server URL (default: http://192.168.1.208:8080)")
    parser.add_argument("--mode", choices=["chat", "completion", "health", "models"], 
                        default="chat", help="Operation mode")
    parser.add_argument("--prompt", "-p", type=str, help="Prompt text")
    parser.add_argument("--system", "-s", type=str, default="You are a helpful assistant.",
                        help="System prompt for chat mode")
    parser.add_argument("--temperature", "-t", type=float, default=0.7, 
                        help="Temperature (0.0-1.0)")
    parser.add_argument("--max-tokens", "-m", type=int, default=512, 
                        help="Maximum tokens to generate")
    parser.add_argument("--stream", action="store_true", help="Stream the response")
    parser.add_argument("--interactive", "-i", action="store_true", 
                        help="Interactive chat mode")
    
    args = parser.parse_args()
    
    client = LLMClient(args.server)
    
    if args.mode == "health":
        if client.health_check():
            print("✅ Server is healthy")
        else:
            print("❌ Server is not responding")
            sys.exit(1)
    
    elif args.mode == "models":
        models = client.models()
        print("Available models:")
        print(json.dumps(models, indent=2))
    
    elif args.mode == "completion":
        if not args.prompt:
            print("Error: --prompt is required for completion mode")
            sys.exit(1)
        
        result = client.completion(args.prompt, args.temperature, args.max_tokens)
        print(result)
    
    elif args.mode == "chat":
        if args.interactive:
            # Interactive chat mode
            print("Interactive chat mode. Type 'exit' to quit.")
            messages = [{"role": "system", "content": args.system}]
            
            while True:
                try:
                    user_input = input("\n> ")
                    if user_input.lower() in ['exit', 'quit']:
                        break
                    
                    messages.append({"role": "user", "content": user_input})
                    
                    if args.stream:
                        print("Assistant: ", end="")
                        client.chat(messages, args.temperature, args.max_tokens, stream=True)
                        # For simplicity, we'll append a placeholder message
                        messages.append({"role": "assistant", "content": "[response]"})
                    else:
                        response = client.chat(messages, args.temperature, args.max_tokens)
                        assistant_msg = response["choices"][0]["message"]["content"]
                        print(f"Assistant: {assistant_msg}")
                        messages.append({"role": "assistant", "content": assistant_msg})
                
                except KeyboardInterrupt:
                    print("\nExiting...")
                    break
        else:
            # Single prompt mode
            if not args.prompt:
                print("Error: --prompt is required for chat mode (or use --interactive)")
                sys.exit(1)
            
            messages = [
                {"role": "system", "content": args.system},
                {"role": "user", "content": args.prompt}
            ]
            
            if args.stream:
                client.chat(messages, args.temperature, args.max_tokens, stream=True)
            else:
                response = client.chat(messages, args.temperature, args.max_tokens)
                print(response["choices"][0]["message"]["content"])

if __name__ == "__main__":
    main()