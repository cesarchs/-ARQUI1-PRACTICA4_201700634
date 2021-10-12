print macro buffer ;imprime cadena
	mov ax, @data
	mov ds,ax
	mov ah,09h ;Numero de funcion para imprimir buffer en pantalla
	mov dx,offset buffer ;equivalente a que lea dx,buffer, inicializa en dx la posicion donde comienza la cadena
	int 21h
endm

close macro ;cierra el programa
	mov ah, 4ch ;Numero de funcion que finaliza el programa
	xor al,al
	int 21h
endm

getChar macro  ;obtiene el caracter
	mov ah,01h ; se guarda en al en codigo hexadecimal
	int 21h
endm

obtenerTexto macro buffer
LOCAL ObtenerChar, endTexto
	xor si,si ; xor si,si =	mov si,0
	
	ObtenerChar:
		getChar
		cmp al,0dh ; ascii de salto de linea en hexa
		je endTexto
		mov buffer[si],al ;mov destino, fuente
		inc si ; si = si + 1
		jmp ObtenerChar

	endTexto:
		mov al,24h ; asci del signo dolar $
		mov buffer[si], al  
endm

obtenerRuta macro buffer
LOCAL ObtenerChar, endTexto
	xor si,si ; xor si,si =	mov si,0
	
	ObtenerChar:
		getChar
		cmp al,0dh ; ascii de salto de linea en hexa
		je endTexto
		mov buffer[si],al ;mov destino, fuente
		inc si ; si = si + 1
		jmp ObtenerChar

	endTexto:
		mov al,00h ; asci del caracter nulo
		mov buffer[si], al  
endm

abrir macro buffer,handler

	mov ah,3dh ;funcion para abrir fichero 
	mov al,02h ;010b Acceso de lectura/escritura. 010b 
	lea dx,buffer ;carga la dirección de la fuente (buffer) a dx 
	int 21h ;ejecutamos la interrupción 
	jc Error1 ;salta si el flag de acarreo = 1
	mov handler,ax ;sino hay error  en ax devuelve un handle para acceder al fichero 

endm

cerrar macro handler
	
	mov ah,3eh
	mov bx, handler
	int 21h
	jc Error2
	mov handler,ax

endm

leer macro handler,buffer, numbytes
	
	mov ah,3fh ;interrupción para leer 
	mov bx,handler ;copiamos en bx el handler,referencia al fichero
	mov cx,numbytes ;numero de bytes a leer, tamaño del arreglo que guarda el contenido 
	lea dx,buffer ;carga la dirección de la variable buffer a dx
	int 21h
	jc  Error5
	;en el buffer se guarda la información

endm
;en el macro limpiar vamos a limpiar el arreglo con $
limpiar macro buffer, numbytes, caracter
LOCAL Repetir
	xor si,si ; colocamos en 0 el contador si
	xor cx,cx ; colocamos en 0 el contador cx
	mov	cx,numbytes ;le pasamos a cx el tamaño del arreglo a limpiar 

	Repetir:
		mov buffer[si], caracter ;le asigno el caracter que le estoy mandando 
		inc si ;incremento si = si++;
		Loop Repetir ;se va a repetir hasta que cx sea 0 
endm

crear macro buffer, handler
	
	mov ah,3ch ;función para crear fichero
	mov cx,00h ;fichero normal 
	lea dx,buffer ;carga la dirección de la variable buffer a dx
	int 21h
	jc Error4
	mov handler, ax ;sino hubo error nos devuelve el handler 

endm

escribir macro handler, buffer, numbytes

	mov ah, 40h ;función de escritura del archivo 
	mov bx, handler ;en bx copiamos el handler, 
	mov cx, numbytes ;numero de bytes a escribir 
	lea dx, buffer ;carga la dirección de la variable buffer a dx
	int 21h ;ejecutamos la interrupción 
	jc Error3

endm