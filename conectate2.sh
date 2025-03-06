#!/bin/bash  
# apunta a la ruta de la shell de bash

# inicio del programa, saludo a quien lo va a ejecutar
clear
echo "Bienvenido "  `whoami` # nombre del usuario
echo -e "\nEste es un script para conectarte a la red de manera sencilla"
sleep 1
echo "¿Quieres ver tus interfaces de red y su estado?"
echo "Escribe el numero correspondiente"
echo "1.Si"
echo "2.No"

read respuesta # lee lo escrito por el usuario

clear # limpia la pantalla

if [ "$respuesta" = "1" ]; then 
    ip link show # muestra la interfaz
    echo -e "\n¿Deseas cambiar el estado de alguna interfaz?"
    echo "1.Si"
    echo "2.No"
    read respuesta2
    
    if [ "$respuesta2" = "1" ]; then
        while true; do 
            echo "Escribe el nombre de la interfaz (ejemplo wlp1s0)"
            read interfaz

            if [ -n "$interfaz" ]; then
                break # sale del bucle
            else
                echo "Escribe una interfaz válida"
            fi
        done 
        
        echo "¿Deseas activar o desactivar la interfaz? (up/down)"
        read estado
        
        if [[ "$estado" == "up" ]]; then
        	sudo ip link set "$interfaz" up
            echo "Interfaz $interfaz activada"
            
            echo "La red a la que te deseas conectar es:"
            echo "1. Alámbrica"
            echo "2. Inalámbrica"
            read respuesta3
            
            case $respuesta3 in
                1)
                    echo "Conectando a red alámbrica..."
                    sudo dhclient "$interfaz"
                    echo "Conexión establecida con IP:"
                    ip addr show "$interfaz" | grep "inet "
                    ;;
                2)
                    echo "Escaneando redes disponibles..."
                    sudo iwlist "$interfaz" scan | grep -i "essid" | uniq
                    echo "Introduce el nombre (SSID) de la red:"
                    read ssid
                    echo "Introduce la contraseña (deja en blanco si es abierta):"
                    read -s password
                    
                    if [ -z "$password" ]; then
                        nmcli dev wifi connect "$ssid"
                    else
                        nmcli dev wifi connect "$ssid" password "$password"
                    fi
                    
                    echo "Esperando dirección IP..."
                    sudo dhclient "$interfaz"
                    echo "Conexión establecida con IP:"
                    ip addr show "$interfaz" | grep "inet "
                    ;;
                *)
                    echo "Opción no válida"
                    ;;
            esac
        elif [[ "$estado" == "down" ]]; then
            sudo ip link set "$interfaz" down
            echo "Interfaz $interfaz desactivada"
        else
            echo "Opción no válida"
        fi
    fi
fi
