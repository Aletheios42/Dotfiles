#!/bin/bash
# Ruta al archivo de emojis
EMOJI_FILE="$HOME/.config/dmenu-emoji/emojis.txt"

# Comprobar si existe el archivo
if [ ! -f "$EMOJI_FILE" ]; then
    echo "Archivo de emojis no encontrado: $EMOJI_FILE"
    exit 1
fi

# Seleccionar emoji con dmenu
selected=$(cat "$EMOJI_FILE" | dmenu -i -l 20)

# Si no se seleccionó nada, salir
if [ -z "$selected" ]; then
    exit 0
fi

# Extraer el emoji del texto seleccionado y copiarlo al portapapeles
emoji=$(echo "$selected" | awk '{print $1}')
echo -n "$emoji" | xclip -selection clipboard

# Notificar al usuario (si está disponible notify-send)
if command -v notify-send >/dev/null 2>&1; then
    notify-send "Emoji copiado" "$emoji" || echo "Emoji copiado: $emoji"
else
    echo "Emoji copiado: $emoji"
fi
