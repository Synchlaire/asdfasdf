#!/bin/bash
# install_zsh.sh: Dotfiles + Eigengrau.nvim para RunPod

# 1. Instalar dependencias del sistema (Zsh + Nvim deps)
# build-essential y unzip son obligatorios para compilar plugins de nvim (Treesitter/Telescope)
apt-get update && apt-get install -y \
    zsh curl git fzf bat ripgrep unzip build-essential \
    python3-venv fd-find

# Fix para 'fd' en Ubuntu (necesario para Telescope/FZF)
ln -sf $(which fdfind) /usr/local/bin/fd

# 2. INSTALAR NEOVIM MODERNO (Latest Stable)
# Evitamos 'apt install neovim' porque trae versiones viejas
if [ ! -f "/usr/local/bin/nvim" ]; then
    echo "⬇️ Instalando Neovim Latest Stable..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    tar -C /opt -xzf nvim-linux64.tar.gz
    ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
    rm nvim-linux64.tar.gz
fi

# 3. CLONAR EIGENGRAU.NVIM
# Hacemos backup si ya existe algo
if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
fi
echo "🌑 Clonando Synchlaire/eigengrau.nvim..."
git clone https://github.com/Synchlaire/eigengrau.nvim "$HOME/.config/nvim"

# 4. Instalar Antidote y Plugins Zsh
if [ ! -d "$HOME/.antidote" ]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
fi

cat <<EOT > $HOME/.zsh_plugins.txt
mattmc3/antidote
mafredri/zsh-async
romkatv/zsh-defer
sindresorhus/pure
zsh-users/zsh-autosuggestions
zsh-users/zsh-completions
zdharma-continuum/fast-syntax-highlighting
EOT

# 5. Generar .zshrc Unificado
cat <<'EOF' > $HOME/.zshrc
# --- INIT ---
source "$HOME/.antidote/antidote.zsh"
antidote load

# --- VARS & OPTS ---
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="batcat"
export OLLAMA_HOST="0.0.0.0:11434" # Visible para docker
export OLLAMA_KEEP_ALIVE="5m"
export PATH="$HOME/.local/bin:$PATH"

setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
HISTFILE="$HOME/.zhistory"
HISTSIZE=10000
SAVEHIST=10000

# --- ALIASES ---
alias ls='ls --color=auto'
alias ll='ls -lah'
alias cat='batcat -p'
alias g='git'
alias gc='git clone'
alias gstat='git status'
alias gl='lazygit' # Si decides instalarlo, si no usa git log
alias v='nvim'
alias vim='nvim'
alias vimconfig='cd ~/.config/nvim && nvim'
alias back='cd -'
alias disks='df -h'
alias install='apt-get install -y'

# --- TOOLS ---
# Zoxide y FZF
if command -v fzf &> /dev/null; then eval "$(fzf --zsh)"; fi
if command -v zoxide &> /dev/null; then eval "$(zoxide init zsh)"; fi
alias cd='z'

# Prompt fix
zstyle :prompt:pure:git:stash show yes
EOF

# 6. Cambiar shell y limpiar
if ! grep -q "exec zsh" ~/.bashrc; then
    echo "[ -t 1 ] && exec zsh" >> ~/.bashrc
fi

echo "✅ Setup Completo: Zsh + Eigengrau.nvim instalados."
