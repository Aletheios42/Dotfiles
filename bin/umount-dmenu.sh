#!/bin/bash

# umount-dmenu.sh - Script para desmontar dispositivos mediante dmenu
# Muestra dispositivos montados y permite desmontarlos
# Solo busca dispositivos en $HOME/mnt/

# Función para notificar
notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$1" "$2"
    else
        echo "$1: $2"
    fi
}

# Directorio base de montaje
MOUNT_DIR="$HOME/mnt"

# Obtener dispositivos montados en nuestro directorio
get_mounted_devices() {
    if command -v findmnt >/dev/null 2>&1; then
        findmnt -o SOURCE,TARGET -ln | grep "$MOUNT_DIR" | awk '{print $1 " en " $2}'
    else
        mount | grep "$MOUNT_DIR" | awk '{print $1 " en " $3}'
    fi
}

# Obtener dispositivos
DEVICES=$(get_mounted_devices)

# Verificar si hay dispositivos montados
if [ -z "$DEVICES" ]; then
    notify "Información" "No hay dispositivos montados para desmontar"
    exit 1
fi

# Presentar dispositivos en dmenu
SELECTED=$(echo "$DEVICES" | dmenu -i -p "Selecciona dispositivo para desmontar:")

# Verificar selección
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Extraer punto de montaje
MOUNT_POINT=$(echo "$SELECTED" | awk '{print $3}')

# Extraer dispositivo para mensajes
DEVICE=$(echo "$SELECTED" | awk '{print $1}')

# Desmontar usando sudo
if sudo umount "$MOUNT_POINT" 2>/dev/null; then
    notify "Éxito" "Dispositivo $DEVICE desmontado"
    
    # Eliminar el directorio de montaje vacío
    rmdir "$MOUNT_POINT" 2>/dev/null
else
    # Si falla, intentar forzar el desmontaje
    FORCE=$(echo -e "No\nSí" | dmenu -i -p "¿Desmontar forzosamente?")
    
    if [ "$FORCE" = "Sí" ]; then
        sudo umount -f "$MOUNT_POINT" && 
        notify "Éxito" "Dispositivo desmontado forzosamente" &&
        rmdir "$MOUNT_POINT" 2>/dev/null || 
        notify "Error" "No se pudo desmontar el dispositivo"
    else
        notify "Información" "Operación cancelada"
    fi
fi

exit 0
