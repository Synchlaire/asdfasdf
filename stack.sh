#!/bin/bash
# start_stack.sh: RunPod Native Stack (Ollama + WebUI + ComfyUI)

# 1. GENERAR CLAVE DE SEGURIDAD (Automático)
# Genera una clave segura para esta sesión
export WEBUI_SECRET_KEY=$(openssl rand -base64 32)
echo "🔐 Clave de sesión generada."

# 2. INSTALAR OLLAMA
if ! command -v ollama &> /dev/null; then
    echo "🦙 Instalando Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
fi

# 3. INSTALAR OPEN WEBUI + HF TRANSFER
if ! pip show open-webui &> /dev/null; then
    echo "🌐 Instalando Open WebUI + Dependencias..."
    pip install open-webui hf_transfer
    # pip install faster-whisper # Descomentar para voz local mejorada
fi

# 4. INSTALAR COMFYUI
if [ ! -d "ComfyUI" ]; then
    echo "🎨 Clonando ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI
    pip install -r ComfyUI/requirements.txt
fi

# 5. CONFIGURAR ENTORNO
export OLLAMA_HOST="0.0.0.0:11434"
export HF_HUB_ENABLE_HF_TRANSFER=1
export DATA_DIR="/workspace/webui_data" # Datos persistentes en el volumen
mkdir -p "$DATA_DIR"

# 6. INICIAR SERVICIOS
echo "🚀 Iniciando Servicios..."

# A) Iniciar Ollama
ollama serve > ollama.log 2>&1 &
PID_OLLAMA=$!
echo "✅ Ollama iniciado (PID: $PID_OLLAMA)"

# B) Esperar a Ollama y bajar modelo ligero
echo "⏳ Esperando a Ollama..."
timeout 30 bash -c 'until echo > /dev/tcp/localhost/11434; do sleep 1; done'

if [ $? -eq 0 ]; then
    # Chequear si ya tenemos el modelo para no bajarlo siempre
    if ! ollama list | grep -q "llama3.2:1b"; then
        echo "⬇️ Descargando Llama 3.2 1B..."
        ollama pull llama3.2:1b
    fi
else
    echo "⚠️ Ollama no respondió a tiempo."
fi

# C) Iniciar Open WebUI (Puerto 3000 para Proxy RunPod)
export PORT=3000
export HOST=0.0.0.0  # <--- NO TOCAR
open-webui serve > webui.log 2>&1 &
PID_WEBUI=$!

echo "✅ Open WebUI iniciado en https://{POD_ID}-3000.proxy.runpod.net"
# ...



echo "✅ Open WebUI corriendo."
echo "🔗 Acceso: https://{POD_ID}-3000.proxy.runpod.net"
echo "📜 Logs: tail -f webui.log"

# Mantener vivo
tail -f webui.log
