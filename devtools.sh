#!/bin/bash
# install_zsh.sh: Entorno Dev (Zsh, Nvim, Ranger, Zoxide Latest)

# 1. Instalar dependencias del sistema

echo " Instalando cositas uwu"
# Añadido: ranger
apt-get update && apt-get install -y \
    zsh curl git fzf bat ripgrep unzip build-essential \
    python3-venv fd-find ranger netcat

# Fix para 'fd'
ln -sf $(which fdfind) /usr/local/bin/fd

# 2. INSTALAR ZOXIDE (Latest)
# La versión de apt es muy vieja y falla con "z command not found".
# Usamos el instalador oficial -> instala en ~/.local/bin
echo "🚀 Instalando Zoxide (Latest)..."
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# 3. INSTALAR NEOVIM (Latest Stable)
if [ ! -f "/usr/local/bin/nvim" ]; then
    echo "⬇️ Instalando Neovim..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    tar -C /opt -xzf nvim-linux64.tar.gz
    ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
    rm nvim-linux64.tar.gz
fi

# 4. CLONAR EIGENGRAU.NVIM
if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
fi
git clone https://github.com/Synchlaire/eigengrau.nvim "$HOME/.config/nvim"

# 5. ANTIDOTE
if [ ! -d "$HOME/.antidote" ]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
fi

# Plugins
cat <<EOT > $HOME/.zsh_plugins.txt
mattmc3/antidote
mafredri/zsh-async
romkatv/zsh-defer
sindresorhus/pure
zsh-users/zsh-autosuggestions
zsh-users/zsh-completions
zdharma-continuum/fast-syntax-highlighting
EOT

# 6. GENERAR .ZSHRC (Con Fix de PATH para Zoxide)
cat <<'EOF' > $HOME/.zshrc
# --- INIT ---
source "$HOME/.antidote/antidote.zsh"
antidote load

# --- VARS ---
export EDITOR="nvim"
export PAGER="batcat"
# IMPORTANTE: Añadir .local/bin al PATH para que encuentre 'zoxide'
export PATH="$HOME/.local/bin:$PATH"

export OLLAMA_HOST="0.0.0.0:11434"

# --- ALIASES ---
alias ls='ls --color=auto'
alias ll='ls -lah'
alias cat='batcat -p'
alias v='nvim'
alias r='ranger'  # Alias rápido para ranger

# --- TOOLS ---
eval "$(fzf --zsh)"

# Inicializar Zoxide (Esto habilita el comando 'z')
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi
EOF

# 7. Finalizar
if ! grep -q "exec zsh" ~/.bashrc; then
    echo "[ -t 1 ] && exec zsh" >> ~/.bashrc
fi

echo "✅ Setup listo. Escribe 'zsh' para entrar."
