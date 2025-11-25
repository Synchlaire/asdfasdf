#!/bin/bash

# 1. INSTALAR OLLAMA
if ! command -v ollama &> /dev/null; then
    echo "🦙 Instalando Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
fi

# 2. INSTALAR OPEN WEBUI (Via Python pip, sin Docker)
# Esto requiere Python 3.11, que RunPod suele tener.
if ! pip show open-webui &> /dev/null; then
    echo "🌐 Instalando Open WebUI..."
    pip install open-webui
    # Instalar motor de audio local (opcional, para voz rápida)
    # pip install faster-whisper
fi

# 3. INSTALAR COMFYUI (Si lo necesitas)
if [ ! -d "ComfyUI" ]; then
    echo "🎨 Clonando ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI
    pip install -r ComfyUI/requirements.txt
fi

# 4. CONFIGURAR ENTORNO
export OLLAMA_HOST="0.0.0.0:11434"
export WEBUI_SECRET_KEY="tu_clave_secreta_aqui"
export DATA_DIR="$HOME/webui_data" # Persistencia para WebUI

# Crear directorio de datos si no existe
mkdir -p "$DATA_DIR"

# 5. INICIAR SERVICIOS (En background)
echo "🚀 Iniciando Servicios..."

# Iniciar Ollama
ollama serve > ollama.log 2>&1 &
PID_OLLAMA=$!
echo "✅ Ollama iniciado (PID: $PID_OLLAMA)"

# Iniciar ComfyUI (Puerto 8188)
# (cd ComfyUI && python main.py --listen 0.0.0.0 --port 8188) > comfy.log 2>&1 &

# Iniciar Open WebUI (Puerto 8080 por defecto, lo mapeamos al 3000 si quieres)
# Open WebUI usa el puerto 8080 por defecto en pip install.
# RunPod espera 3000 para el proxy web.
export PORT=3000
open-webui serve > webui.log 2>&1 &
PID_WEBUI=$!
echo "✅ Open WebUI iniciado en puerto $PORT (PID: $PID_WEBUI)"

echo "📜 Logs disponibles en: ollama.log y webui.log"
echo "⚠️  Para detener todo: kill $PID_OLLAMA $PID_WEBUI"

# Mantener el script corriendo para ver logs (opcional)
tail -f webui.log
