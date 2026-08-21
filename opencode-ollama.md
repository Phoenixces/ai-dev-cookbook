# OpenCode + Ollama: Free & Unlimited Local Model Setup

Run powerful models locally — no API keys, no cost, no limits. Ollama serves models locally; OpenCode connects to it as a provider.

---

## 1. Install Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Verify it's running:

```bash
ollama list
```

---

## 2. Pull Models

```bash
# Lightweight coder — fast, low RAM (~1.9 GB)
ollama pull qwen2.5-coder:3b

# Stronger reasoning model (~4.7 GB)
ollama pull qwen2.5-coder:7b

# Stronger reasoning model (~4.7 GB)
ollama pull qwen3:4b

# Stronger reasoning model (~4.7 GB)
ollama pull deepseek-r1:8b
```

Free RAM immediately after inference stops (useful when running IDEs alongside):

```bash
launchctl setenv OLLAMA_KEEP_ALIVE "0s"
```

---

## 3. Configure OpenCode

File: `~/.config/opencode/config.json`

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen3:4b": {
          "name": "qwen3:4b",
          "tool_call": true,
          "limit": {
            "context": 16384,
            "output": 4096
          }
        },
        "llama3.2:latest": {
          "name": "llama3.2:latest",
          "tool_call": true,
          "limit": {
            "context": 16384,
            "output": 4096
          }
        }
      }
    }
  }
}
```

---

## 4. Launch OpenCode

```bash
opencode .
```

Inside OpenCode, switch models with `/model` — pick any Ollama model you pulled.

---

## Model Reference

| Model | Size | Best for |
|-------|------|----------|
| `qwen2.5-coder:3b` | ~1.9 GB | Fast autocomplete, low RAM machines |
| `deepseek-r1:8b` | ~4.7 GB | Reasoning, multi-step coding tasks |
| `deepseek-r1:14b` | ~8 GB | Stronger reasoning, needs 16 GB+ RAM |
| `llama3.2:3b` | ~2 GB | General chat, lightweight tasks |
| `codellama:7b` | ~3.8 GB | Code generation, completions |

Pull any model: `ollama pull <model-name>`  
Browse all: https://ollama.com/library

---

## Tips

- Ollama runs at `http://localhost:11434` by default — OpenCode connects to it via the OpenAI-compatible `/v1` endpoint.
- Add more models to the config `models` block as you pull them.
- `OLLAMA_KEEP_ALIVE "0s"` frees GPU/RAM instantly after each request — good for machines with limited memory.
- No internet needed after pulling models. Fully offline.

---

## Ollama Cloud — Run Massive Models Without a Local GPU

Ollama Cloud streams huge models (480B+) from remote servers. No download, no local VRAM needed. Sign in once, then use any cloud model the same way as local ones.

### Step 1: Sign In

```bash
ollama signin
```

Opens browser to authenticate. One-time setup.

### Step 2: Run Cloud Models

Append `:cloud` to the model name — Ollama streams it remotely instead of running locally:

```bash
# 480B coding model — runs on Ollama's servers
ollama run qwen3-coder:480b-cloud

# 120B open-source reasoning model
ollama run gpt-oss:120b-cloud
```

No `ollama pull` needed. Starts immediately.

### Step 3: Use in OpenCode

Add cloud models to your config the same way as local ones:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "name": "Ollama",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen2.5-coder:3b": { "name": "qwen2.5-coder:3b" },
        "deepseek-r1:8b": { "name": "deepseek-r1:8b" },
        "qwen3-coder:480b-cloud": { "name": "qwen3-coder:480b-cloud" },
        "gpt-oss:120b-cloud": { "name": "gpt-oss:120b-cloud" }
      }
    }
  }
}
```

Switch between local and cloud models via `/model` inside OpenCode.

### Alternative: API Key for External Tools

For Docker containers, web UIs, or automation tools that need direct cloud access without the local Ollama daemon:

1. Generate an API key at https://ollama.com/settings/keys
2. Export it:

```bash
export OLLAMA_API_KEY="your_api_key_here"
```

3. Point tools at the cloud endpoint directly:

```
Base URL:  https://ollama.com/v1
API Key:   your_api_key_here
```

Works with any OpenAI-compatible client.