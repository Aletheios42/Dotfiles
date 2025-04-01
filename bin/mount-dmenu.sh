#!/bin/bash

# mount-dmenu.sh - Script para montar dispositivos mediante dmenu
# Detecta dispositivos disponibles y los muestra en dmenu para montarlos
# Centraliza todos los puntos de montaje en $HOME/mnt/

# Función para notificar
notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$1" "$2"
    else
        echo "$1: $2"
    fi
}

# Crear directorio de montaje si no existe
MOUNT_DIR="$HOME/mnt"
mkdir -p "$MOUNT_DIR"

# Obtener dispositivos disponibles para montar
# Excluir dispositivos ya montados y particiones del sistema
get_available_devices() {
    lsblk -lp -o NAME,SIZE,TYPE,MOUNTPOINT,LABEL | grep -v "loop\|sr\|ram" | 
    awk '$3 == "part" && $4 == "" {print $1 " (" $2 ") " $5}'
}

# Obtener lista de dispositivos 
DEVICES=$(get_available_devices)

# Verificar si hay dispositivos disponibles
if [ -z "$DEVICES" ]; then
    notify "Error" "No hay dispositivos disponibles para montar"
    exit 1
fi

# Presentar dispositivos en dmenu
SELECTED=$(echo "$DEVICES" | dmenu -i -p "Selecciona dispositivo para montar:")

# Verificar selección
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Extraer el nombre del dispositivo (PATH)
DEVICE=$(echo "$SELECTED" | awk '{print $1}')

# Extraer etiqueta si existe, o usar UUID como nombre
LABEL=$(lsblk -no LABEL "$DEVICE" 2>/dev/null)
if [ -z "$LABEL" ]; then
    LABEL=$(lsblk -no UUID "$DEVICE" | cut -c 1-8)
fi

# Crear punto de montaje específico
MOUNT_POINT="$MOUNT_DIR/$LABEL"
mkdir -p "$MOUNT_POINT"

# Usar sudo mount para montar el dispositivo
if sudo mount "$DEVICE" "$MOUNT_POINT" 2>/dev/null; then
    # Cambiar propietario si es necesario
    sudo chown $USER:$USER "$MOUNT_POINT"
    notify "Éxito" "Dispositivo $DEVICE montado en $MOUNT_POINT"
else
    # Si falla, probar auto-detección de sistema de archivos con sudo
    FS_TYPE=$(lsblk -no FSTYPE "$DEVICE")
    
    case $FS_TYPE in
        vfat|ntfs|exfat)
            # Para sistemas de archivos Windows
            sudo mount -o uid=$(id -u),gid=$(id -g) "$DEVICE" "$MOUNT_POINT" && 
            notify "Éxito" "Dispositivo $DEVICE montado en $MOUNT_POINT"
            ;;
        ext4|ext3|ext2|btrfs|xfs)
            # Para sistemas de archivos Linux
            sudo mount "$DEVICE" "$MOUNT_POINT" && 
            sudo chown $USER:$USER "$MOUNT_POINT" &&
            notify "Éxito" "Dispositivo $DEVICE montado en $MOUNT_POINT"
            ;;
        *)
            # Intentar montar sin especificar tipo
            sudo mount "$DEVICE" "$MOUNT_POINT" && 
            sudo chown $USER:$USER "$MOUNT_POINT" &&
            notify "Éxito" "Dispositivo $DEVICE montado en $MOUNT_POINT" || 
            notify "Error" "No se pudo montar $DEVICE"
            ;;
    esac
fi

exit 0
