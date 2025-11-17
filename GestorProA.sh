#!/bin/bash

echo "📦 Iniciando entorno virtual..."

# Ruta al entorno virtual (ajustá si usás otro nombre)
source API/venv/bin/activate

# 1. Iniciar base de datos (si usás MySQL/Postgres podés levantar con systemctl si está apagado)
echo "🛢️ Asegurando base de datos en ejecución..."
sudo systemctl stop mysql
sudo /opt/lampp/lampp start


# 2. Iniciar FastAPI (en backend/main.py)
echo "🚀 Levantando API FastAPI..."
cd API
uvicorn fastapi_app:app --reload &
cd ..

# 3. Iniciar Vue 3 (en carpeta frontend)
echo "🌐 Levantando frontend Vue..."
cd frontGestor
npm run dev &

# Espera para que no se cierre el script
sleep 2 && 
xdg-open http://localhost:5173/
echo "✅ Todo listo. Presioná Ctrl+C para cerrar procesos."
wait
