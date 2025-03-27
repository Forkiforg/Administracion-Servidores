#!/bin/bash
#Creacion de usuarios 2.0

#funciones 

function NombreU(){
	while true; do
	
	read -r -p "Primero ingresa el Nombre del nuevo Usuario: " nombre
	if grep -q "$nombre" /etc/passwd; then
		echo "El nombre ya esta ocupado, ingresa otro"

	else
		echo "$nombre guardado para el usuario"
		break
	fi
	done
}

function ComentarioU(){
	while true; do
	
	echo "Ingresa el comentario que tendra tu nuevo usuario. "
	echo "Debe de ir entre comillas."

	read -r comentario
	primero="${comentario:0:1}"
    ultimo="${comentario: -1}"
    if [[ ("$primero" == "\"" && "$ultimo" == "\"") || ("$primero" == "'" && "$ultimo" == "'") ]]; then
            echo "Comentario válido"
            break
        else
	            echo "Error: Debe estar entre comillas."
	        fi
	done

}

function GrupoU(){

	read -r -p "Ingresa el grupo al que pertenecera el nuevo usuario: " grupo
	if grep -q "^$grupo:" /etc/group; then
		echo "El grupo ya existe, agregando al usuario a este grupo"
		
	else
		echo "El grupo no existe, creando grupo y agregando al usuario"
		groupadd "$grupo"
	fi	
}

function HogarU(){
	while true; do

	read -r -p "Ingresa el nombre del Directorio Hogar que tendra tu usuario: " hogar
	if grep -q ":/home/$hogar:" /etc/passwd; then
		echo "El directorio ya existe y esta ocupado, busca otro: "

	elif [ -d /home/"$hogar" ]; then
		echo "El directorio ya existe pero esta vacio, usandolo..."
		break
		
	else
		echo "EL directorio no existe, creando el directorio y usandolo"
		mkdir /home/"$hogar"
		break
	fi
	done	
}

function ContraseñaU(){
	echo "Ahora tendras que ingresar una contraseña segura, esta debe de tener los siguiente:"
	echo
	echo "10 o mas caracteres"
	echo "Mayusculas y Minusculas"
	echo "Numeros y Caracteres especiasles como # $ % & @ _ -"
	echo

	 while true; do
        read -r -s -p "Ingresa tu contraseña: " contrasena
        echo
        read -r -s -p "Confirma tu contraseña: " confirmacion
        echo

        # Verificar que ambas contraseñas coincidan
        if [[ "$contrasena" != "$confirmacion" ]]; then
            echo "Error: Las contraseñas no coinciden. Inténtalo de nuevo."
            continue
        fi

     if [[ ${#contrasena} -ge 10 && 
                      "$contrasena" =~ [A-Z] && 
                      "$contrasena" =~ [a-z] && 
                      "$contrasena" =~ [0-9] && 
                      "$contrasena" =~ [#\$@_\-] ]]; then
                    echo "Contraseña válida y guardada."
                    break
                else
                    echo "Error: La contraseña no cumple con los requisitos."
                fi
            done   
	}

function GrupoD(){

	while true; do
	read -r -p "Ingresa el nombre del grupo que quieres eliminar: " grupoD

	if getent group "$grupoD" > /dev/null; then
		groupdel "$grupoD"
		echo "Grupo $grupoD borrado"
		break
		
	else 
		echo "Grupo incorrecto o no existe, ingresalo de nuevo"
	fi
	done
}

function UsuarioD(){

	while true; do
	read -r -p "Ingresa el nombre del usuario que quieres eliminar: " userD

	if id "$userD" > /dev/null 2>&1; then
		userdel "$userD"
		echo "Usuario eliminado"
		break
		
	else
		echo "El usuario no existe o es incorrecto, ingresalo de nuevo"
	fi
	done

}

function CuotasU (){

	echo "¿Deseas asignarle una cuota a este usuario?"
	echo "1.Si"
	echo "2.No"
	read -r cuota
	if [ "$cuota" -eq 2 ]; then
		echo "Entendido, sin asignar cuotas"

	else
	
		echo "Para asignar cuotas necesito que me des el tamaño del espacio Soft y Hard"
		echo "Recuerda que el espacio Hard debe de ser mayor al espacio Soft"

		while true;do
		read -r -p "Soft: " soft
		read -r -p "Hard: " hard

		if [ "$soft" -eq "$hard" ]; then
			echo "El espacio Hard debe de ser mayor al espacio Soft, intentalo de nuevo"

		elif [ "$soft" -gt "$hard" ]; then 	
			echo "El espacio Hard debe de ser mayor al espacio Soft, intentalo de nuevo"
	
		else 
			echo "Cuotas asignadas"
			break
		fi
		done
	fi
	
}

function Sudo(){
    echo "¿Deseas asignar a este usuario con privilegios de SUDO? "
    echo "1. Sí"
    echo "2. No"
    read -r s

    if [ "$s" -eq 2 ]; then
        echo "Entendido, hasta luego"
        return
    fi

    echo "Elige a continuación cómo quieres configurar el SUDO de tu usuario"
    echo -e "1. Todos los privilegios"
    echo -e "2. Especificar privilegios"
    read -r -p "Elige: " ss

    while true; do
        case $ss in
            1)
                read -r -p "Escribe el nombre del usuario: " user
                usermod -aG sudo "$user"
                echo "$user ahora tiene todos los privilegios de sudo."
                break
                ;;
            2)
                read -r -p "Escribe el nombre del usuario: " user
                read -r -p "Escribe los comandos que podrá usar el usuario: " cmd
                echo "$user ALL=(ALL) NOPASSWD: $cmd" >> /etc/sudoers
                echo "Se han asignado los permisos de sudo a $user para: $cmd"
                break
                ;;
            *)
                echo "Opción inválida, intenta de nuevo."
                ;;
        esac
    done
}


# main
clear
echo "_____Creacion de Usuarios y edicion de usuarios_____"
echo -e "\n ¿Que deseas hacer?"

while true; do
echo
echo "1. Crear un usuario."
echo "2. Cambiar la contraseña del usuario."
echo "3. Eliminar usuario o grupo"
echo "4. Crear cuotas."
echo "5. Usar comandos con SUDO."
echo "6. Salir del programa."

read -r -p "Selecciona una opcion: " opcion

case $opcion in
	1)
	
		clear
		echo "Vamos a crear un nuevo usuario"
		NombreU
		echo
		sleep 0.5
		ComentarioU
		echo
		sleep 0.5
		GrupoU
		echo
		sleep 0.5
		HogarU

		useradd -d /home/"$hogar" -s /bin/sh -c "$comentario" -g "$grupo" "$nombre"
		echo "Usuario $nombre creado con exito"
		echo
		sleep 0.5
		ContraseñaU

		echo "$nombre:$contrasena" | chpasswd
		echo
		sleep 0.5
		CuotasU 
		setquota -u "$nombre" "$soft"  "$hard" 0 0 /

		echo
		sleep 0.5
		Sudo

	;;

	2)
	
		clear
		read -r -p "Para cambiar la contraseña la contraseña de un usuario ingresa su nombre: " user
		echo
		sleep 0.5
		ContraseñaU
		echo "$user:$contrasena" | chpasswd
	;;

	3)

		clear
		echo "Elige que deseas eliminar"
		echo
		echo "1.Usuario"
		echo "2.Grupo"

		while true; do

		read -r op2
		if [ "$op2" -eq 1 ]; then
			UsuarioD
			break
		elif [ "$op2" -eq 2 ]; then
			GrupoD
			break
		else  echo "Elige una opcion valida"

		fi
		done
	;;

	4)
		
		clear
		read -r -p "Ingresa el nombre del usuario al que le quieres asignar una cuota: " ncuota
		CuotasU
		setquota -u "$ncuota" "$soft"  "$hard" 0 0 /
	;;

	5) 

		clear	
		Sudo
	;;

	6) 

		clear
		echo "Hasta pronto"
		sleep 0.5
		exit 1;
	;;
esac
done
