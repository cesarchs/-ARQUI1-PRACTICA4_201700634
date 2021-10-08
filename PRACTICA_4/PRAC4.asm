include macros2.asm ;archivo con los macros a utilizar
include archivos.asm ; incluimos macros para manipulacion de archivos 

imprimir macro buffer ;imprime cadena
push ax
push dx

	mov ax, @data
	mov ds,ax
	mov ah,09h ;Numero de funcion para imprimir buffer en pantalla
	mov dx,offset buffer ;equivalente a que lea dx,buffer, inicializa en dx la posicion donde comienza la cadena
	int 21h

pop dx
pop ax
endm


escribirChar macro char
		mov ah, 02h
		mov dl, char
		int 21h
endm

posicionarCursor macro x,y
	mov ah,02h
	mov dh,x
	mov dl,y
	mov bh,0
	int 10h
endm

imprimirVideo macro caracter, color
	mov ah, 09h
	mov al, caracter ;al guarda el valor que vamos a escribir
	mov bh, 0
	mov bl, color ; valor binario rojo
	mov cx,1 ; este nos sirve para decirle que solo se imprima una vez la letra
	int 10h
endm

esDiptongo macro caracter1, caracter2 ;en el registor al va a tener un 1 si es un diptongo o un 0 si no lo es
LOCAL salida, esA, esE, esO, esDip
mov al,0



esA:
	cmp caracter1,97 ;97 es a
	jne esE

	cmp caracter2,105
	je esDip

	cmp caracter2, 117
	je esDip

	jmp salida
	

esE:

	cmp caracter1,101 ;97 es a
	jne esO

	cmp caracter2,105
	je esDip

	cmp caracter2, 117
	je esDip

	jmp salida


esO:

	cmp caracter1,111 ;97 es a
	jne salida

	cmp caracter2,105
	je esDip

	cmp caracter2, 117
	je esDip

	jmp salida

esDip:
	mov al,1


jmp salida


salida: 

endm
;-------------------------------------------------------------------------------------------------
.model small

;----------------SEGMENTO DE PILA----------------------------------------------------------------
.stack

;----------------SEGMENTO DE DATO-------------------------------------------------------------------

.data
msjEntrada db 0ah, 0dh, '| Universidad de San Carlos de Guatemala',0ah, 0dh,'| Arquitectura de Ensambladores y Computadores 1' , 0ah, 0dh, '| CESAR LEONEL CHAMALE SICAN      201700634' , 0ah, 0dh, '| Pr',160,'ctica 4',0ah, 0dh, '| Ingrese x si desea cerrar el programa' , '$'
msjComandos db 0ah, 0dh, '| Comandos de aplicacion: ',0ah, 0dh,'| 1. -abrir_',34,'ruta',34 , 0ah, 0dh, '| 2. -contar_<diptongo | triptongo | hiato | palabra>' , 0ah, 0dh, '| 3. -prop_<diptongo | triptongo | hiato > ',0ah, 0dh, '| 4. -colorear' ,0ah, 0dh,'| 5. -reporte',0ah, 0dh,'| 6. -diptongo_palabra',0ah, 0dh,'| 7. -hiato_palabra',0ah, 0dh,'| 8. -triptongo_palabra', '$'

msjIngreseC db 0ah, 0dh, 'INGRESE EL NUMERO DE SU COMANDO: ' , '$'
msjcontinue db 0ah, 0dh, 'precione CUALQUIER tecla para continuar o x para salir: ' , '$'
ingreseruta db 0ah,0dh, 'Ingrese una ruta de archivo' , 0ah,0dh, 'Ejemplo: entrada.txt' , '$'
;------------------------------MESAJE PARA COMANDOS ------------------------------------------------
msjComando1 db 0ah, 0dh, '-abrir_','$'
msjComando2 db 0ah, 0dh, '-contar_<','$'
msjComando3 db 0ah, 0dh, '-prop_<','$'
msjComando4 db 0ah, 0dh, '-colorear','$'
msjComando5 db 0ah, 0dh, '-reporte','$'
msjComando6 db 0ah, 0dh, '-diptongo_','$'
msjComando7 db 0ah, 0dh, '-hiato_','$'
msjComando8 db 0ah, 0dh, '-triptongo_','$'
;------------------------------------------------------------------------------------------------------
saltoLinea db 0Ah,0Dh,"$"
saludo db 0Ah,0Dh, "Anlaizando texto..........","$"
fin db 0Ah,0Dh, "Finalizando el programa.......", "$"
salto db 0ah,0dh, '$' ,'$'

texto db "Hola esto es unn peine y una aula","$"

fila db 0
columna db 0
;----------------AGREGADOS PARA COMANDOS ------------------------------------------------
comand db 0, '$'
;--------------- PARA ABRIR DOCUMENTO ---------------------------------------------------
bufferentrada db 50 dup('$')
handlerentrada dw ?
bufferInformacion db 700 dup('$')
auxEntrada db 0, '$' 
msjOpcionesArch db 0ah,0dh, '1. Mostrar informacion' , 0ah,0dh, '2. Cerrar archivo' , '$'

err1 db 0ah,0dh, 'Error al abrir el archivo puede que no exista' , '$'
err2 db 0ah,0dh, 'Error al cerrar el archivo' , '$'
err3 db 0ah,0dh, 'Error al escribir en el archivo' , '$'
err4 db 0ah,0dh, 'Error al crear en el archivo' , '$'
err5 db 0ah,0dh, 'Error al leer en el archivo' , '$'
;----------------SEGMENTO DE CODIGO------------------------------------------------------


.code
main proc

	Menu:
		print msjEntrada
		print saltoLinea
		getChar ; lee un caracter del teclado y lo guarda en al
        cmp al, 120 ; if (al == 120){va a brincar a la etiqueta salir}else{va a continuar con el programa}
        je exit
	MenuOpciones:
		print msjComandos
		print saltoLinea
		print msjIngreseC
		print saltoLinea
		getChar
		cmp al,49 ; NUMEOR 1 PARA ABRIR DOC
		je AbrirArchivo
		cmp al,50 ; NUMERO 2 PARA CONTAR
		je exit ;############
		cmp al,52 ; NUMERO 4 PARA COLOREAR 
		JE COLOREAR
		jmp exit
	AbrirArchivo: ; PARA ABRIR DOC
		print ingreseruta
		print saltoLinea
		print msjComando1
		limpiar bufferentrada, 50 ,24h ; LIMPIAMOS EL ARRAY PARA LA RUTA, LIMPIAMOS CON $
		obtenerRuta bufferentrada  ; OBTENEMOS LA RUTA DEL ARCHIVO DE ENTRADA
		abrir bufferentrada,handlerentrada ; LE MANDAMOS LA RUTA Y EL HANDLE QUE SERA LA REFERENCIA AL FICHERO
		limpiar bufferInformacion, 700 ,24h ; LIMPIAMOS LA VARIABLE DONDE GUARDAMOS LOS DATOS DEL ARCHIVO DE ENTRADA
		leer handlerentrada, bufferInformacion, 700 ;leemos el archivo 
		; para el tamaño se puede mandar as "SIZEOF bufferInformacion" en anbos de limpar pero da problema al ensamblar,
		;aunque no error, si funciona, pero al automatizar el arranque del ejetucable en doss opcions no acepta bien el SIZEOF

		print msjcontinue
		getChar
		cmp al, 120 ; if (al == 120){va a brincar a la etiqueta salir}else{va a continuar con el programa}
        je exit


	AbrirArchivo2:	
		print salto
		print msjOpcionesArch
		print salto
		print msjIngreseC
		getChar
		cmp al,31h
		je MostrarInformacion
		cmp al,32h
		je CerrarArchivo
		jmp AbrirArchivo


	MostrarInformacion:
		print salto
		print bufferInformacion
		print salto
		print msjcontinue
		getChar
		cmp al, 120
		je exit
		jmp AbrirArchivo2


	CerrarArchivo:
		cerrar handlerentrada
		jmp MenuOpciones


	Error1:
		print salto
		print err1
		getChar
		jmp Menu

	Error2:
		print salto
		print err2
		getChar
		jmp Menu
	
	Error3:
		print salto
		print err3
		getChar
		jmp Menu
	
	Error4:
		print salto
		print err4
		getChar
		jmp Menu

	Error5:
		print salto
		print err5
		getChar
		jmp Menu


COLOREAR:

;----------CON ESTO DE ENTRA A MODO VIDEO-------------------
;al inicializar el modo video le decimos que empiece en la posicion 0
; se inicializa modo video con una resolucion de 80x25
mov ah, 0
mov al, 03h 
int 10h
;-------------------------------------------------------------
imprimir saludo
imprimir saltoLinea
;----------------------------------------------------------------------------------------------
;por que ya imprimimos las palabras de arrbia por eso usamos lo siguiente para guardar la posicion de 
;fila y columna
mov ah, 03h ; con el 03h le decimos que analice despues del texto anterior
mov bh, 00h
int 10h ;dh guarda el valor de la ultima posicion fila y dl guarda la ultima posicion de la columna
;----------------------------------------------------------------------------------------------
mov fila, dh
mov columna, dl
mov si, 0
mov di, 0

ciclo1:
	;----------------------------------------------------------------------------------------
	;posicionar al cursor donde corresponde
	posicionarCursor fila, columna

	esDiptongo bufferInformacion[si], bufferInformacion[si+1]  

	cmp al,0  
	je letra

	;pintamos el diptongo
	imprimirVideo bufferInformacion[si], 0100b ;imprimos blanco 
	inc columna ;aumenta la posicion del cursor
	inc si

	posicionarCursor fila, columna

	
	imprimirVideo bufferInformacion[si], 0100b ;imprimos blanco  
	jmp siguiente

	letra:
		imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
		jmp siguiente


	siguiente:

	inc columna ;aumenta la posicion del cursor
	inc si



	cmp columna, 80d
	jl noSalto
		mov columna,0
		inc fila
	noSalto:

	cmp bufferInformacion[si], 36d 
	jne ciclo1

	inc fila
	mov ah,02h
	mov dh,fila
	mov dl,0
	mov bh,0
	int 10h
	
exit:
	close

main endp
end main	

