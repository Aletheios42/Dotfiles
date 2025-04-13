#!/bin/bash

TIMESTAMP=$(date +%Y%m%d%H%M%S)
SCREENSHOT_DIR="$HOME/Imagenes/Capturas"
VIDEO_DIR="$HOME/Videos/Grabaciones"
mkdir -p "$SCREENSHOT_DIR" "$VIDEO_DIR"

# Función para captura de pantalla
take_screenshot() {
  maim -s "$SCREENSHOT_DIR/$TIMESTAMP.png"
  notify-send "Screenshot saved" "$SCREENSHOT_DIR/$TIMESTAMP.png"
}

# Función para grabación
record_screen() {
  OUTPUT="$VIDEO_DIR/$TIMESTAMP.mp4"
  
  # Selección de área (usando slop para coordenadas)
  GEOMETRY=$(slop -f "%x %y %w %h")
  read -r X Y W H <<< "$GEOMETRY"
  
  ffmpeg -f x11grab -s "$W"x"$H" -i :0.0+$X,$Y -framerate 30 \
    -c:v libx264 -preset ultrafast -qp 0 "$OUTPUT" &
  PID=$!
  
  # Notificación con botón para detener
  notify-send "Recording started" "Press Print again to stop" -t 0
  
  # Guarda el PID para detenerlo después
  echo $PID > /tmp/screen_recording_pid
}

# Función para detener grabación
stop_recording() {
  if [ -f /tmp/screen_recording_pid ]; then
    PID=$(cat /tmp/screen_recording_pid)
    kill -SIGTERM $PID
    rm /tmp/screen_recording_pid
    notify-send "Recording saved" "$VIDEO_DIR/$TIMESTAMP.mp4"
  fi
}

# Verifica si hay una grabación en curso
if [ -f /tmp/screen_recording_pid ]; then
  stop_recording
else
  # Menú de selección con dmenu
  CHOICE=$(echo -e "Screenshot\nScreen Recording\nGIF Recording" | dmenu -p "Select action")
  
  case $CHOICE in
    "Screenshot")
      take_screenshot
      ;;
    "Screen Recording")
      record_screen
      ;;
    "GIF Recording")
      OUTPUT="$VIDEO_DIR/$TIMESTAMP.gif"
      peek
      ;;
  esac
fi
