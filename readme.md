# 🦙 RunPod AI Stack & Dev Environment

A "bare-metal" style deployment for RunPod (Ubuntu/PyTorch pods). This setup bypasses Docker-in-Docker issues by running services natively, optimizing performance for **Llama 3.x**, **Open WebUI**, and **ComfyUI**.

It also provisions a fully configured development environment (**Zsh, Neovim/Eigengrau, Ranger, Zoxide**) automatically.

## ⚡ Features

- **AI Stack:**
  - **Ollama:** Backend for LLMs (Auto-downloads Llama 3.2 1B for quick checks).
  - **Open WebUI:** ChatGPT-style interface with **Live Voice Chat** support.
  - **ComfyUI:** Node-based Stable Diffusion GUI.
  - **Native Performance:** Runs directly on the host (no nested containers) for max GPU throughput.
- **Dev Environment:**
  - **Shell:** Zsh + Pure Prompt + Antidote + Plugins.
  - **Editor:** Neovim (Latest) + [Eigengrau.nvim](https://github.com/Synchlaire/eigengrau.nvim).
  - **Tools:** `zoxide`, `fzf`, `ranger`, `bat`, `ripgrep`.

---

## 🛠️ RunPod Setup requirements

When renting a Pod, use these settings:

- **Template:** `RunPod Base (Ubuntu 22.04)` or `RunPod PyTorch 2.x`. (Do NOT use One-Click WebUI templates).
- **GPU:** 24GB VRAM minimum recommended (80GB+ for 70B models).
- **Container Disk:** 50 GB (for system deps).
- **Volume Disk:** 100 GB+ (Persisted at `/workspace`).
- **Ports to Expose:**
  - `3000` (Open WebUI)
  - `8188` (ComfyUI)
  - `11434` (Ollama API - Optional)

---

## 🚀 Quick Start

1. **SSH into your Pod** (or use the Web Terminal).
2. **Clone and Launch:**

```bash
cd /workspace
git clone [https://github.com/Synchlaire/deploy-llama](https://github.com/Synchlaire/deploy-llama)
cd deploy-llama
chmod +x *.sh

# 1. Install Dev Environment (Zsh, Nvim, Tools)
./install_zsh.sh

# 2. Start AI Services (Ollama, WebUI, ComfyUI)
./start_stack.sh
