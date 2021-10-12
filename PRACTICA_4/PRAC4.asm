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
	LOCAL salida, esA, esE, esO, esDip, regla1Dip, regla2Dip,esIr2, esDipR2,esIr3,esUr3,esDipR3,regla3Dip,exept
	mov al,0

	regla1Dip:
	esA:
		cmp caracter1,97 ;97 es a
		jne esE

		cmp caracter2,105; es i
		je esDip

		cmp caracter2, 117 ; es u
		je esDip

		jmp regla2Dip
		

	esE:

		cmp caracter1,101 ; es e
		jne esO

		cmp caracter2,105; es i
		je esDip

		cmp caracter2, 117; es u
		je esDip

		jmp regla2Dip


	esO:

		cmp caracter1,111 ; es o
		jne regla2Dip

		cmp caracter2,105 ; es i
		je esDip

		cmp caracter2, 117; es u
		je esDip

		jmp regla2Dip

	esDip:
		mov al,1
		inc esDipR1Contador
		inc esDipContadorGen
		jmp salida

	

;----------- TEGLA 2 DE DIPTONGOS 
	regla2Dip:
		cmp caracter1, 105 ; es i
		JE esIr2
		cmp caracter1, 117; es u
		JE esIr2
		;jmp regla3Dip
		jmp regla3Dip

		esIr2:
			cmp caracter2,97 ; es a
			JE esDipR2
			cmp caracter2,101 ; es e
			JE exept
			cmp caracter2,111 ; es o
			JE esDipR2
			Jmp regla3Dip

		exept:
			;push dl 
			;xor dl,dl
			;mov dl , bufferInformacion[si-1]
			cmp  bufferInformacion[si-1], 113 ; es q

			JE salida
		esDipR2:
			mov al,1
			inc esDipR2Contador
			inc esDipContadorGen
			jmp salida

;----------------- REGLA 3 DE DIPTONGOS
	regla3Dip:
		;vocales cerradas
		cmp caracter1, 105 ; es i
		JE esIr3
		cmp caracter1, 117 ; es u
		JE esUr3
		jmp salida

		esIr3:
			cmp caracter2, 117 ; es u
			JE esDipR3
			JMP salida
		esUr3:
			cmp caracter2, 105 ; es i
			JNE salida

		esDipR3:
			mov al,1
			inc esDipContadorGen
			inc esDipR3contador


	salida: 

endm

esTriptongo macro caracter1, caracter2, caracter3
	LOCAL salida, esAt, esEt, esOt,esTrip,esIt
	mov bl,0

	cmp caracter1,105; es i
	JE esIt
	cmp caracter1,117 ; es u
	JE esIt
	jmp salida
	esIt:
		cmp caracter2, 97 ;97 es a
		JE esAt
		cmp caracter2, 101 ; es e
		JE esEt
		cmp caracter2,111 ; es o
		JE esOt
		jmp salida


	esAt:
		cmp caracter3,105; es i
		JE esTrip
		cmp caracter3,117 ; es u
		JE esTrip
		jmp salida
		

	esEt:
		cmp caracter3,105; es i
		JE esTrip
		cmp caracter3,117 ; es u
		JE esTrip
		jmp salida

	esOt:

		cmp caracter3,105; es i
		JE esTrip
		cmp caracter3,117 ; es u
		JE esTrip
		jmp salida

	esTrip:
		mov bl,1
		inc esTripContador
		jmp salida




	salida: 
endm


;	ALGORITMO PARA HIATO SIN TIILDES (PSEUDOCODIGO)
; 	IF (CARACTER1= a OR e OR O)
; 		IF (CARACTER2= a OR e OR O)
;			ES HIATO
;		PASAR A REGLA 2
;	PASAR A REGLA 2
;
; #regla2
;	IF (CARACTER1 = i)
;		IF (CARACTER2 = i) 
;			es hiato
;		no es hiato
; 	regla 3
;
;	IF (CARACTER1 = u)
;		IF (CARACTER2 = u)
;			es hiato
;		no es hiato
;	no es hiato
esHiato macro caracter1, caracter2
	LOCAL salida, esHia,hiatoRegla1,esHiatoAbierta,hiatoRegla2,esHiatoI,esHiatoU
	mov cl,0

	hiatoRegla1:
		cmp caracter1,97 ;97 es a
		JE esHiatoAbierta
		cmp caracter1, 101 ; es e
		JE esHiatoAbierta
		cmp caracter1,111 ; es o
		JE esHiatoAbierta
		jmp hiatoRegla2
	esHiatoAbierta:
		cmp caracter2,97 ;97 es a
		JE esHia
		cmp caracter2, 101 ; es e
		JE esHia
		cmp caracter2,111 ; es o
		JE esHia
		jmp hiatoRegla2

	hiatoRegla2:
		cmp caracter1,105; es i
		JE esHiatoI
		cmp caracter1,117 ; es u
		JE esHiatoU
		jmp salida

	esHiatoI:
		cmp caracter2,105; es i
		JE esHia
		jmp salida

	esHiatoU:
		cmp caracter2,117 ; es u
		JE esHia
		jmp salida

	esHia:
		mov cl,1
		inc esHiatoContGen



	salida: 
endm
;----------------------------------------------------------------------------PARA PINTAR SIN MODIFICAR CONTADORES ----------------------------------------------------------------
esDiptongoP macro caracter1, caracter2 ;en el registor al va a tener un 1 si es un diptongo o un 0 si no lo es
	LOCAL salida, esA, esE, esO, esDip, regla1Dip, regla2Dip,esIr2, esDipR2,esIr3,esUr3,esDipR3,regla3Dip,exept
	mov al,0

	regla1Dip:
	esA:
		cmp caracter1,97 ;97 es a
		jne esE

		cmp caracter2,105; es i
		je esDip

		cmp caracter2, 117 ; es u
		je esDip

		jmp regla2Dip
		

	esE:

		cmp caracter1,101 ; es e
		jne esO

		cmp caracter2,105; es i
		je esDip

		cmp caracter2, 117; es u
		je esDip

		jmp regla2Dip


	esO:

		cmp caracter1,111 ; es o
		jne regla2Dip

		cmp caracter2,105 ; es i
		je esDip

		cmp caracter2, 117; es u
		je esDip

		jmp regla2Dip

	esDip:
		mov al,1
		;inc esDipR1Contador
		;inc esDipContadorGen
		jmp salida

	

;----------- TEGLA 2 DE DIPTONGOS 
	regla2Dip:
		cmp caracter1, 105 ; es i
		JE esIr2
		cmp caracter1, 117; es u
		JE esIr2
		;jmp regla3Dip
		jmp regla3Dip

		esIr2:
			cmp caracter2,97 ; es a
			JE esDipR2
			cmp caracter2,101 ; es e
			JE exept
			cmp caracter2,111 ; es o
			JNE regla3Dip

		exept:
			;push dl 
			;xor dl,dl
			;mov dl , bufferInformacion[si-1]
			cmp  bufferInformacion[si-1], 113 ; es q

			JE salida
		esDipR2:
			mov al,1
			;inc esDipR2Contador
			;inc esDipContadorGen
			jmp salida

;----------------- REGLA 3 DE DIPTONGOS
	regla3Dip:
		;vocales cerradas
		cmp caracter1, 105 ; es i
		JE esIr3
		cmp caracter1, 117 ; es u
		JE esUr3
		jmp salida

		esIr3:
			cmp caracter2, 117 ; es u
			JE esDipR3
		esUr3:
			cmp caracter2, 105 ; es i
			JNE salida

		esDipR3:
			mov al,1
			;inc esDipContadorGen
			;inc esDipR3contador
			jmp salida


	salida: 

endm

esTriptongoP macro caracter1, caracter2, caracter3
	LOCAL salida, esAt, esEt, esOt,esTrip,esIt
	mov bl,0

	cmp caracter1,105; es i
	JE esIt
	cmp caracter1,117 ; es u
	JE esIt
	jmp salida
	esIt:
		cmp caracter2, 97 ;97 es a
		JE esAt
		cmp caracter2, 101 ; es e
		JE esEt
		cmp caracter2,111 ; es o
		JE esOt
		jmp salida


	esAt:
		cmp caracter3,105; es i
		JE esTrip
		cmp caracter3,117 ; es u
		JE esTrip
		jmp salida
		

	esEt:
		cmp caracter3,105; es i
		JE esTrip
		cmp caracter3,117 ; es u
		JE esTrip
		jmp salida

	esOt:

		cmp caracter3,105; es i
		JE esTrip
		cmp caracter3,117 ; es u
		JE esTrip
		jmp salida

	esTrip:
		mov bl,1
		;inc esTripContador
		jmp salida




	salida: 
endm


;	ALGORITMO PARA HIATO SIN TIILDES (PSEUDOCODIGO)
; 	IF (CARACTER1= a OR e OR O)
; 		IF (CARACTER2= a OR e OR O)
;			ES HIATO
;		PASAR A REGLA 2
;	PASAR A REGLA 2
;
; #regla2
;	IF (CARACTER1 = i)
;		IF (CARACTER2 = i) 
;			es hiato
;		no es hiato
; 	regla 3
;
;	IF (CARACTER1 = u)
;		IF (CARACTER2 = u)
;			es hiato
;		no es hiato
;	no es hiato
esHiatoP macro caracter1, caracter2
	LOCAL salida, esHia,hiatoRegla1,esHiatoAbierta,hiatoRegla2,esHiatoI,esHiatoU
	mov cl,0

	hiatoRegla1:
		cmp caracter1,97 ;97 es a
		JE esHiatoAbierta
		cmp caracter1, 101 ; es e
		JE esHiatoAbierta
		cmp caracter1,111 ; es o
		JE esHiatoAbierta
		jmp hiatoRegla2
	esHiatoAbierta:
		cmp caracter2,97 ;97 es a
		JE esHia
		cmp caracter2, 101 ; es e
		JE esHia
		cmp caracter2,111 ; es o
		JE esHia
		jmp hiatoRegla2

	hiatoRegla2:
		cmp caracter1,105; es i
		JE esHiatoI
		cmp caracter1,117 ; es u
		JE esHiatoU
		jmp salida

	esHiatoI:
		cmp caracter2,105; es i
		JE esHia
		jmp salida

	esHiatoU:
		cmp caracter2,117 ; es u
		JE esHia
		jmp salida

	esHia:
		mov cl,1
		;inc esHiatoContGen



	salida: 
endm

;----------------------------------------------------------------------------------------------

; CONTADORE DE PALABRAS
contadorPalabras macro

    local contarcaracteres,charcontados,noesespacio
    xor si,si         ;limpiar stack index 
    mov pcontador,1    ;empezar a contar en 1 
    contarcaracteres: 
    cmp bufferInformacion[si],"$" ;fin de cadena
    je charcontados   ;si es igual sale del ciclo  
    cmp bufferInformacion[si],32 ;compara caracter espacio
    jne noesespacio   ;si no es igual se va a esa etiqueta
    add pcontador,1    ;si es igual aumenta el contador 
    noesespacio:      
        inc si        ;aumenta el stack index para el siguiente caracter 
        jmp contarcaracteres ;regresa al inicio del ciclo
    charcontados:     ;termino de contar
	;print salto
	;IntToString pcontador, avisoContaPrint
	;print pcontador2
	;imprimir_reg bx
	
	;print salto 
	xor si,si   ;limpia si por si se usa despues. No es necesario

endm
;-----------------------------------------------------------------------------------------
salirMenu macro
	print msjcontinue
	getChar
	print salto
	cmp al, 120
	je exit
	jmp MenuOpciones
endm

;-------------------------------------------------------------------------------------------------
.model small

;----------------SEGMENTO DE PILA----------------------------------------------------------------
.stack

;----------------SEGMENTO DE DATO-------------------------------------------------------------------

.data
msjEntrada db 0ah, 0dh, '| Universidad de San Carlos de Guatemala',0ah, 0dh,'| Arquitectura de Ensambladores y Computadores 1' , 0ah, 0dh, '| CESAR LEONEL CHAMALE SICAN      201700634' , 0ah, 0dh, '| Pr',160,'ctica 4',0ah, 0dh, '| Ingrese x si desea cerrar el programa' , '$'
msjComandos db 0ah, 0dh, '| COMANDOS DE APLICACION: ',0ah, 0dh,'| 1. -abrir_',34,'ruta',34 , 0ah, 0dh, '| 2. -contar_<diptongo | triptongo | hiato | palabra>' , 0ah, 0dh, '| 3. -prop_<diptongo | triptongo | hiato > ',0ah, 0dh, '| 4. -colorear' ,0ah, 0dh,'| 5. -reporte',0ah, 0dh,'| 6. -diptongo_palabra',0ah, 0dh,'| 7. -hiato_palabra',0ah, 0dh,'| 8. -triptongo_palabra', '$'

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
;--------------------------COMPARADORES A COMANDOS ---------------------------------------------------
;MENSAJE CONTADOR COMPARADOR
;---de contador
msjContadorCompDi db 'diptongo>','$'
msjContadorCompTri db 'triptongo>','$'
msjContadorCompHi db 'hiato>','$'
msjContadorCompPa db 'palabra>','$'
msjTotalPalabras db 'cantidad todal de palabras: ','$'
msjTotalHiatos db 'cantidad total de hiatos: ','$'
msjTotalDiptongos db 'cantidad total de diptongos: ','$'
msjTotalTriptongos db 'cantidad total de triptongos: ','$'

;---- de prop
;MENSAJE PROP
msjGenRep db 'GENERANDO REPORTE','$'
msjPropDi db 'diptongo>','$'
msjPropTri db 'triptongo>','$'
msjPropHi db 'hiato>','$'
;--- de reporte
msjRep db 0,'$'


;------------------------------------------------------------------------------------------------------
saltoLinea db 0Ah,0Dh,"$"
saludo db 0Ah,0Dh, "---------------------- ANALIZANDO TEXTO  -------------------","$"
fin db 0Ah,0Dh, "Finalizando el programa.......", "$"
salto db 0ah,0dh, '$' ,'$'

texto db "Hola esto es unn peine y una aula","$"

fila db 0
columna db 0

;------------------------------------------------SIGNOS DE PUNTUACION -----------------------------
msjPunto1 db '.','$'
msjPorce db '%','$'
;-------------------------------------------------------------------------------------------------
;----------------AGREGADOS PARA COMANDOS ------------------------------------------------
comand db 0, '$'

;------------------PARA REPORTE -----------------------------
input db "REPORTE.txt",00h;Nombre
contenedor db 200 dup("$"),"$";Guardar Lectyra
handle dw ?
Rencabezado db "REPORTE PRACTICA 4: ",'$'
RSalto db 10
RavisoSalto db "aviso salto de linea",'$'
Rinfo db "CESAR LEONEL CHAMALE SICAN 201700634", '$'
RPropCant db "PROPORCION Y CANTIDAD ", '$'
RCantidadPalabras db "Cantidad total de palabras en el documento: ", '$'
RCantidadHiatos db "Cantidad total de hiatos en el documento: ", '$'
RPropHiatos db "Proporcion de hiatos en el documento: ", '$'
RCantidadTriptongos db "Cantidad total de triptongos en el documento: ", '$'
RPropTriptongos db "Proporcion de triptongos en el documento: ", '$'
RCantidadDiptongos db "Cantidad total de Diptongos en el documento: ", '$'
RPropDiptongos db "Proporcion de Diptongos en el documento: ", '$'
RPunto db ".",'$'
RPorcentaje db "%",'$'


;--------------------------------------------------------------
; BUFFERS PARA LA PALABRA QUE DESEAMOS ANALIZAR AISLADAMENTE
;---------------------------------------------------------------
bufferPalabra db 15 dup('$')
RespuestaEsTrip db "SI ES TRIPTONGO ","$"
RespuestaNoTrip db "LA PALABRA NO ES TRIPTONGO ","$"
RespuestaEsHi db "SI ES HIATO ","$"
RespuestaNoHi db "LA PALABRA NO ES HIATO ","$"
RespuestaEsDi db "SI ES DIPTONGO ","$"
RespuestaNoDi db "LA PALABRA NO ES DIPTONGO ","$"
;--------------- PARA ABRIR DOCUMENTO ---------------------------------------------------
bufferentrada db 50 dup('$')
handlerentrada dw ?
bufferInformacion db 700 dup('$')

msjOpcionesArch db 0ah,0dh, '1. Mostrar informacion' , 0ah,0dh, '2. Cerrar archivo' , '$'
;-----------------MENSAJE DE ERROES
err1 db 0ah,0dh, 'Error al abrir el archivo puede que no exista' , '$'
err2 db 0ah,0dh, 'Error al cerrar el archivo' , '$'
err3 db 0ah,0dh, 'Error al escribir en el archivo' , '$'
err4 db 0ah,0dh, 'Error al crear en el archivo' , '$'
err5 db 0ah,0dh, 'Error al leer en el archivo' , '$'
errorComando db 0ah,0dh, "Error comando no existente" ,0ah,0dh, "$"

;---------------------- PARA CONTADORES ------------------------------------------------
pcontador dw 0
avisoContador1 db "aviso contador 1",'$'
;avisoContaPrint dw 0
;avisoContaPrint2 db "aviso print contador palabras ",'$'
contadorHiato dw 1
avisoContador2 db "aviso contador 2",'$'
contadoraux dw 0
avisoContador3 db "aviso contador 3",'$'
pcontadorResH db 15, '$'
;#######################
contadorVer db 15, '$'
;#######################
contadorDiptongo dw 0
avisoContador4 db "aviso contador 4",'$'
contadorTriptongo dw 0
avisoContador5 db "aviso contador 5",'$'
esDipR2Contador dw 0
avisoContador6 db "aviso contador 6",'$'
esDipR1Contador dw 0
avisoContador7 db "aviso contador 7",'$'
esDipContadorGen dw 0
avisoContador8 db "aviso contador 8",'$'
esDipR3contador dw 0
avisoContador9 db "aviso contador 9",'$'
esTripContador dw 0
avisoContador10 db "aviso contador 10",'$'
esHiatoContGen dw 0
avisoContador11 db "aviso contador 11",'$'
;contadores para palabras al reporte
ContadorTripReporte dw 0
avisoContador12 db "aviso contador 12",'$'
ContadorDipReporte dw 0
avisoContador13 db "aviso contador 13",'$'
ContadorHiaReporte dw 0
avisoContador14 db "aviso contador 14",'$'
;#####################################
pruebaSimb db 2, '$'
;######################################
textoaleer db "Texto de muestra con seis palabras siete ocho nueve dies",'$'

;---------------------AUX PARA ENTRADAS-------------------------------------------------
auxEntrada db 0, '$'

auxContador db '$'

etiquetaPruebas db "llego xdd" , "$"
;----------------------- aca hay un buggg#########################################
;cuando creamos mas variables para imrprimir aca,, da simbolos raros

auxProp db 0, '$'
auxPalabra db 0, '$'




;----------------SEGMENTO DE CODIGO------------------------------------------------------


.code
CrearReporte proc
	push ax 
	push bx
	push cx 
	push dx
	call XOR_REG
	createFile input,handle
	OpenFile input,handle

;-------------- IMPRESIONES EN REPORTE ----------------------
	WriteFile handle,Rencabezado,20
	WriteFile handle,RSalto,1
	WriteFile handle,Rinfo,36
	WriteFile handle,RSalto,1
	WriteFile handle,RSalto,1
	WriteFile handle,RPropCant,22
	WriteFile handle,RSalto,1
	WriteFile handle,RCantidadPalabras,44
	contadorPalabras
	IntToString pcontador,contadorVer
	WriteFile handle,contadorVer,2 ; mandamos la cantidad de palabras totales
	WriteFile handle,RSalto,1
	WriteFile handle,RSalto,1
	;-------------------------
	;			hiatos
	;-------------------------
	WriteFile handle,RCantidadHiatos,42
	IntToString esHiatoContGen,contadorVer 
	WriteFile handle,contadorVer,2 ; mandamos la cantidad de hiatos
	WriteFile handle,RSalto,1
	WriteFile handle,RPropHiatos,38

	;----prop hiato------------
		xor si,si
		mov ax ,esHiatoContGen ; ax = contadorhiato
		mov bx,100 ; 			ax * 100
		mul bx					;	*
		contadorPalabras		; llamar al metodo que cuanto cuantas todas las palabras
		mov bx,pcontador ;		resultado de conteo -> bx = resultado
		div bx	
		mov contadoraux,ax
		IntToString contadoraux,contadorVer ; convertimos contador a numeros
	WriteFile handle,contadorVer,2
		;mov contadoraux,dx
		;IntToString contadoraux,contadorVer
	;WriteFile handle,RPunto,1
	;WriteFile handle,contadorVer,2
	WriteFile handle,RPorcentaje,1
	WriteFile handle,RSalto,1
	WriteFile handle,RSalto,1
	;-------------------------
	;		diptongos
	;-------------------------
	WriteFile handle,RCantidadDiptongos,45
	IntToString esDipContadorGen,contadorVer 
	WriteFile handle,contadorVer,2 ; mandamos la cantidad de hiatos
	WriteFile handle,RSalto,1
	WriteFile handle,RPropDiptongos,41

	;----prop diptongos------------
		xor si,si
		mov ax ,esDipContadorGen ; ax = contadorhiato
		mov bx,100 ; 			ax * 100
		mul bx					;	*
		contadorPalabras		; llamar al metodo que cuanto cuantas todas las palabras
		mov bx,pcontador ;		resultado de conteo -> bx = resultado
		div bx	
		mov contadoraux,ax
		IntToString contadoraux,contadorVer ; convertimos contador a numeros
	WriteFile handle,contadorVer,2
		;mov contadoraux,dx
		;IntToString contadoraux,contadorVer
	;WriteFile handle,RPunto,1
	;WriteFile handle,contadorVer,2
	WriteFile handle,RPorcentaje,1
	WriteFile handle,RSalto,1
	WriteFile handle,RSalto,1
	;-------------------------
	;		TRIPTONGO
	;-------------------------
	WriteFile handle,RCantidadTriptongos,46
	IntToString esTripContador,contadorVer 
	WriteFile handle,contadorVer,2 ; mandamos la cantidad de hiatos
	WriteFile handle,RSalto,1
	WriteFile handle,RPropTriptongos,42

	;----prop diptongos------------
		xor si,si
		mov ax ,esTripContador ; ax = contadorhiato
		mov bx,100 ; 			ax * 100
		mul bx					;	*
		contadorPalabras		; llamar al metodo que cuanto cuantas todas las palabras
		mov bx,pcontador ;		resultado de conteo -> bx = resultado
		div bx	
		mov contadoraux,ax
		IntToString contadoraux,contadorVer ; convertimos contador a numeros
	WriteFile handle,contadorVer,2
		mov contadoraux,dx
		IntToString contadoraux,contadorVer
	WriteFile handle,RPunto,1
	WriteFile handle,contadorVer,2
	WriteFile handle,RPorcentaje,1
	WriteFile handle,RSalto,1
	WriteFile handle,RSalto,1


	
	;WriteFile handle,
	WriteFile handle,RSalto,1
	;WriteFile handle,
	WriteFile handle,RSalto,1

;---------------------------------------------------------
	CloseFile handle

	call XOR_REG
	pop dx
	pop cx 
	pop bx 
	pop ax 
	ret
CrearReporte endp


XOR_REG proc
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	ret
XOR_REG endp

LLENADO_VARIABLES proc 
	push ax 
	push bx
	push cx 
	push dx
		CicloLLenado:
		call XOR_REG
		;----------------------------------------------------------------------------------------

		esTriptongo bufferInformacion[si], bufferInformacion[si+1], bufferInformacion[si+2]
		cmp bl,0
		JNE esTripPrintll

		esDiptongo bufferInformacion[si], bufferInformacion[si+1]  
		cmp al,0  
		JNE esDipPrintll

		esHiato bufferInformacion[si], bufferInformacion[si+1]
		cmp cl,0
		JNE esHiatoPrintll
		JMP letrall
		
		

		esDipPrintll:
			;pintamos el diptongo
			;imprimirVideo bufferInformacion[si], 0010b ;imprimos verde 
			;inc columna ;aumenta la posicion del cursor
			inc si

			;posicionarCursor fila, columna

			
			;imprimirVideo bufferInformacion[si], 0010b ;imprimos verde  
			jmp siguientell

			;letra:
			;	imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
			;	jmp siguiente
	;--------------------------------------------------------------------------------------
		esTripPrintll:
			;pintamos el diptongo
			;imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
			;inc columna ;aumenta la posicion del cursor
			inc si

			;posicionarCursor fila, columna

			
			;imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
			;inc columna ;aumenta la posicion del cursor
			inc si 

			;posicionarCursor fila, columna
			;imprimirVideo bufferInformacion[si],1110b ;imprimos amarillo 
			jmp siguientell
	;---------------------------------------------------------------------------------------
		esHiatoPrintll:
		;pintamos el hiato
			;imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo 
			;inc columna ;aumenta la posicion del cursor
			inc si

			;posicionarCursor fila, columna

			
			;imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo  
			jmp siguientell

			
	;---------------------------------------------------------------------------------------
		letrall:
			;imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
			jmp siguientell
	;--------------------------------------------------------------------------------------

		siguientell:

		;inc columna ;aumenta la posicion del cursor
		inc si



		;cmp columna, 80d
		;jl noSaltoll
			;mov columna,0
			;inc fila
		;noSaltoll:

		cmp bufferInformacion[si], 36d ; $
		jne CicloLLenado

	call XOR_REG
	pop dx
	pop cx 
	pop bx 
	pop ax 
	ret
LLENADO_VARIABLES endp


LLENADO_VARIABLES2 proc 
	push ax 
	push bx
	push cx 
	push dx
	push si 
	push di
		xor si,si
		xor di,di
		CicloLLenado2:
		call XOR_REG
		;----------------------------------------------------------------------------------------

		esTriptongoP bufferInformacion[si], bufferInformacion[si+1], bufferInformacion[si+2]
		cmp bl,0
		
		JNE esTripPrintll2

		esDiptongoP bufferInformacion[si], bufferInformacion[si+1]  
		cmp al,0  
		
		JNE esDipPrintll2

		esHiatoP bufferInformacion[si], bufferInformacion[si+1]
		cmp cl,0
		
		JNE esHiatoPrintll2
		JMP letrall2
		
		

		esDipPrintll2:
			;GUARDAMOS el diptongo
			mov di,si

			;imprimirVideo bufferInformacion[si], 0010b ;imprimos verde 

			;inc columna ;aumenta la posicion del cursor
			inc ContadorDipReporte
			inc si

			;posicionarCursor fila, columna

			
			;imprimirVideo bufferInformacion[si], 0010b ;imprimos verde  
			jmp siguientell2

			;letra:
			;	imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
			;	jmp siguiente
	;--------------------------------------------------------------------------------------
		esTripPrintll2:
		
			;pintamos el diptongo
			;imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
			;inc columna ;aumenta la posicion del cursor
			inc ContadorTripReporte
			inc si

			;posicionarCursor fila, columna

			
			;imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
			;inc columna ;aumenta la posicion del cursor
			inc si 

			;posicionarCursor fila, columna
			;imprimirVideo bufferInformacion[si],1110b ;imprimos amarillo 
			jmp siguientell2
	;---------------------------------------------------------------------------------------
		esHiatoPrintll2:
		;pintamos el hiato
			;imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo 
			;inc columna ;aumenta la posicion del cursor
			inc ContadorHiaReporte
			inc si

			;posicionarCursor fila, columna

			
			;imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo  
			jmp siguientell2

			
	;---------------------------------------------------------------------------------------
		letrall2:
			;imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
			jmp siguientell2
	;--------------------------------------------------------------------------------------

		siguientell2:

		;inc columna ;aumenta la posicion del cursor
		inc si



		;cmp columna, 80d
		;jl noSaltoll
			;mov columna,0
			;inc fila
		;noSaltoll:

		cmp bufferInformacion[si], 36d ; $
		jne CicloLLenado2

	call XOR_REG
	xor si,si 
	xor di,di
	pop di
	pop si 
	pop dx
	pop cx 
	pop bx 
	pop ax 
	ret
LLENADO_VARIABLES2 endp



main proc

	mov ax,@data    
    mov ds,ax

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
		je contar 
		cmp al,51 ; NUMERO 3 PARA PROP
		JE PROPORCION
		cmp al,52 ; NUMERO 4 PARA COLOREAR 
		JE COLOREAR
		cmp al,53 ; NUMERO 5 PARA REPORTE
		JE REPORTE
		cmp al,54 ; NUMERO 6 PARA PALABRA DIPTONGO
		JE PALABRA_DIPTONGO 
		cmp al,55 ; NUMERO 7 PARA PALABRA HIATO
		JE PALABRA_HIATO
		cmp al,56 ; NUMERO 8 PARA PALABRA TRIPTONGO
		JE PALABRA_TRIPTONGO
		jmp ErrorNoExist
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
		call LLENADO_VARIABLES
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
	
	ErrorNoExist:
		print errorComando
		jmp Menu

	contar:
		print salto
		;print msjContadorCompDi
		;print salto
		;print msjContadorCompTri
		;print salto
		;print msjContadorCompHi
		;print salto
		;print msjContadorCompPa
		;print salto
		print msjComando2
		obtenerTexto auxContador
		print auxContador
		;COMPARACIONES 
		;------------PARA HIATOS
		mov cx,6  ; hiato> 6 posiciones
		mov AX, DS
		mov ES, AX
		
		LEA si, msjContadorCompHi
		LEA di, auxContador
		repe cmpsb 
		JE HIATOc 

		;----------PARA TRIPTONGOS
		xor cx,cx
		mov cx,10  ;triptongo>
		lEA si, msjContadorCompTri
		LEA di, auxContador
		repe cmpsb ;Compare msjContadorCompTri:auxContador
		JE TRIPTONGOc 
		
		;----------PARA DIPTONGO   diptongo>

		xor cx,cx
		mov cx,9      ; numero de posiciones a comparar diptongo> = 9 posiciones
		LEA si, msjContadorCompDi
		LEA di, auxContador
		repe cmpsb
		JE DIPTONGOc

		;----------PARA PALABRAS , msjContadorCompPa , palabra>
		xor cx,cx
		mov cx,8      ; numero de posiciones a comparar palabra> = 8 POSICIONES
		LEA si, msjContadorCompPa
		LEA di, auxContador
		repe cmpsb
		JNE ErrorNoExist
		
		print salto
		print msjTotalPalabras
		contadorPalabras
		IntToString pcontador,contadorVer ; convertimos contador a numeros
		print contadorVer
		print salto
		salirm:
		salirMenu

		HIATOc:
			mov ax,@data
 			mov ds,ax
			print salto
			print salto
			print msjTotalHiatos
			
			IntToString esHiatoContGen , contadorVer ; convertimos contador a numeros
			print contadorVer
			print salto
			salirMenu

		TRIPTONGOc:
			mov ax,@data
 			mov ds,ax
			print salto
			print salto
			print msjTotalTriptongos
			
			IntToString esTripContador , contadorVer ; convertimos contador a numeros
			print contadorVer
			print salto
			salirMenu

		DIPTONGOc:
			mov ax,@data
 			mov ds,ax
			print salto
			print salto
			print msjTotalDiptongos
			
			IntToString esDipContadorGen , contadorVer ; convertimos contador a numeros
			print contadorVer
			print salto
			salirMenu


	PROPORCION:
		print salto
		;print msjPropDi
		;print salto
		;print msjPropHi
		;print salto
		;print msjPropTri
		;print salto
		print msjComando3
		obtenerTexto auxProp
		print auxProp
		print salto
		;COMPARACIONES
		;------------PARA HIATOS
		mov cx,6  ; hiato> 6 posiciones
		mov AX, DS
		mov ES, AX
		
		LEA si, msjPropHi
		LEA di, auxProp
		repe cmpsb 
		JE HIATOp 

		;----------PARA TRIPTONGOS
		xor cx,cx
		mov cx,10  ;triptongo>
		lEA si, msjPropTri
		LEA di, auxProp
		repe cmpsb ;Compare msjContadorCompTri:auxContador
		JE TRIPTONGOp
		
		;----------PARA DIPTONGO   diptongo>

		xor cx,cx
		mov cx,9      ; numero de posiciones a comparar diptongo> = 9 posiciones
		LEA si, msjPropDi
		LEA di, auxProp
		repe cmpsb
		JE DIPTONGOp

		jmp ErrorNoExist


		HIATOp:
			mov ax,@data
			mov ds,ax
			;print salto
			;print msjPropHi
			print salto 

			;call XOR_REG
			xor si,si
			mov ax ,esHiatoContGen ; ax = contadorhiato
			mov bx,100 ; 			ax * 100
			mul bx					;	*
			contadorPalabras		; llamar al metodo que cuanto cuantas todas las palabras
			mov bx,pcontador ;		resultado de conteo -> bx = resultado
			div bx					; resultado de multiplicacion dividido por resultado de conteo
			;print salto
			;imprimir_reg ax
			;print salto
			;imprimir_reg dx
			;print salto
			;limpiar contadoraux,15,0 ;limpiamos el contador 
			;mov si, ax
			;imprimir_reg ax
			;print salto
			mov contadoraux,ax ; movemos ax a contador
			;print contadoraux
			;print salto
			;print pruebaSimb 
			;print salto
			IntToString contadoraux,contadorVer ; convertimos contador a numeros
			print contadorVer
			;call XOR_REG
			;print msjPunto1 
			cmp dx,0
			JA terminarProp

		;decimalProp:
			;print salto
			print msjPunto1
			mov contadoraux,dx
			IntToString contadoraux,contadorVer
			print contadorVer
			jmp terminarProp
			;print msjPorce
			 


		jmp Menu
		

		TRIPTONGOp:
			mov ax,@data
			mov ds,ax
			;print salto
			;print msjPropHi
			print salto 

			;call XOR_REG
			xor si,si
			mov ax ,esTripContador ; ax = contadorhiato
			mov bx,100 ; 			ax * 100
			mul bx					;	*
			contadorPalabras		; llamar al metodo que cuanto cuantas todas las palabras
			mov bx,pcontador ;		resultado de conteo -> bx = resultado
			div bx					; resultado de multiplicacion dividido por resultado de conteo
			;print salto
			;imprimir_reg ax
			;print salto
			;imprimir_reg dx
			;print salto
			;limpiar contadoraux,15,0 ;limpiamos el contador 
			;mov si, ax
			;imprimir_reg ax
			;print salto
			mov contadoraux,ax ; movemos ax a contador
			;print contadoraux
			;print salto
			;print pruebaSimb 
			;print salto
			IntToString contadoraux,contadorVer ; convertimos contador a numeros
			print contadorVer
			call XOR_REG
			;print msjPunto1 
			cmp dx,0
			JA terminarProp

		;decimalProp:
			;print salto
			print msjPunto1
			mov contadoraux,dx
			IntToString contadoraux,contadorVer
			print contadorVer
			jmp terminarProp
			;print msjPorce


		jmp Menu



		DIPTONGOp:
			mov ax,@data
			mov ds,ax
			;print salto
			;print msjPropHi
			print salto 

			;call XOR_REG
			xor si,si
			mov ax ,esDipContadorGen ; ax = contadorhiato
			mov bx,100 ; 			ax * 100
			mul bx					;	*
			contadorPalabras		; llamar al metodo que cuanto cuantas todas las palabras
			mov bx,pcontador ;		resultado de conteo -> bx = resultado
			div bx					; resultado de multiplicacion dividido por resultado de conteo
			;print salto
			;imprimir_reg ax
			;print salto
			;imprimir_reg dx
			;print salto
			;limpiar contadoraux,15,0 ;limpiamos el contador 
			;mov si, ax
			;imprimir_reg ax
			;print salto
			mov contadoraux,ax ; movemos ax a contador
			;print contadoraux
			;print salto
			;print pruebaSimb 
			;print salto
			IntToString contadoraux,contadorVer ; convertimos contador a numeros
			print contadorVer
			call XOR_REG
			;print msjPunto1 
			cmp dx,0
			JA terminarProp

		;decimalProp:
			;print salto
			print msjPunto1
			mov contadoraux,dx
			IntToString contadoraux,contadorVer
			print contadorVer
			;print msjPorce
			 
			

			terminarProp:
				;print msjEspacio
				call XOR_REG
				print msjPorce
				print salto


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
		; -----------ACTUALIZAMOS POSICIONES
		mov fila, dh
		mov columna, dl
		mov si, 0
		mov di, 0

	ciclo1:
		call XOR_REG
		;----------------------------------------------------------------------------------------
		;posicionar al cursor donde corresponde
		posicionarCursor fila, columna

		esTriptongoP bufferInformacion[si], bufferInformacion[si+1], bufferInformacion[si+2]
		cmp bl,0
		JNE esTripPrint

		esDiptongoP bufferInformacion[si], bufferInformacion[si+1]  
		cmp al,0  
		JNE esDipPrint

		esHiatoP bufferInformacion[si], bufferInformacion[si+1]
		cmp cl,0
		JNE esHiatoPrint
		JMP letra
		
		

		esDipPrint:
			;pintamos el diptongo
			imprimirVideo bufferInformacion[si], 0010b ;imprimos verde 
			inc columna ;aumenta la posicion del cursor
			inc si

			posicionarCursor fila, columna

			
			imprimirVideo bufferInformacion[si], 0010b ;imprimos verde  
			jmp siguiente

			;letra:
			;	imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
			;	jmp siguiente
	;--------------------------------------------------------------------------------------
		esTripPrint:
			;pintamos el diptongo
			imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
			inc columna ;aumenta la posicion del cursor
			inc si

			posicionarCursor fila, columna

			
			imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
			inc columna ;aumenta la posicion del cursor
			inc si 

			posicionarCursor fila, columna
			imprimirVideo bufferInformacion[si],1110b ;imprimos amarillo 
			jmp siguiente
	;---------------------------------------------------------------------------------------
		esHiatoPrint:
		;pintamos el hiato
			imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo 
			inc columna ;aumenta la posicion del cursor
			inc si

			posicionarCursor fila, columna

			
			imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo  
			jmp siguiente

			
	;---------------------------------------------------------------------------------------
		letra:
			imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
			jmp siguiente
	;--------------------------------------------------------------------------------------

		siguiente:

		inc columna ;aumenta la posicion del cursor
		inc si



		cmp columna, 80d
		jl noSalto
			mov columna,0
			inc fila
		noSalto:

		cmp bufferInformacion[si], 36d ; $
		jne ciclo1
		

		inc fila
		mov ah,02h
		mov dh,fila
		mov dl,0
		mov bh,0
		int 10h

		JMP Menu


	REPORTE:
		print salto
		obtenerTexto msjRep
		;print msjRep
		print salto 
		print msjGenRep
		call CrearReporte
		print salto
		JMP Menu


	PALABRA_TRIPTONGO:
		;push bx
		xor si,si
		mov si,0
		mov di, 0
		;call XOR_REG
		print salto
		limpiar bufferPalabra,15,24h
		print msjComando8
		obtenerTexto bufferPalabra
		print salto
		print bufferPalabra
		print salto
			
		ciclo2:
			call XOR_REG
			;----------------------------------------------------------------------------------------

			esTriptongoP bufferPalabra[si], bufferPalabra[si+1], bufferPalabra[si+2]
			cmp bl,0
			JNE esTripPrintT
			
			;esDiptongoP bufferPalabra[si], bufferPalabra[si+1]  
			;cmp al,0  
			;JNE esDipPrintT

			;esHiatoP bufferPalabra[si], bufferPalabra[si+1]
			;cmp cl,0
			;JNE esHiatoPrintT
			JMP letraT
			
			

			esDipPrintT:
				;pintamos el diptongo
				;imprimirVideo bufferInformacion[si], 0010b ;imprimos verde 
				;inc columna ;aumenta la posicion del cursor
				inc si

				;posicionarCursor fila, columna

				
				;imprimirVideo bufferInformacion[si], 0010b ;imprimos verde  
				jmp siguienteT

				;letra:
				;	imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
				;	jmp siguiente
		;--------------------------------------------------------------------------------------
			esTripPrintT:
				;pintamos el diptongo
				;imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
				;inc columna ;aumenta la posicion del cursor
				inc si

				;posicionarCursor fila, columna

				
				;imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
				;inc columna ;aumenta la posicion del cursor
				inc si 
				

				;posicionarCursor fila, columna
				;imprimirVideo bufferInformacion[si],1110b ;imprimos amarillo 
				jmp SIESTRIP
		;---------------------------------------------------------------------------------------
			esHiatoPrintT:
			;pintamos el hiato
				;imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo 
				;inc columna ;aumenta la posicion del cursor
				inc si

				;posicionarCursor fila, columna

				
				;imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo  
				jmp siguienteT

				
		;---------------------------------------------------------------------------------------
			letraT:
				;imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
				jmp siguienteT
		;--------------------------------------------------------------------------------------

			siguienteT:
		
			;inc columna ;aumenta la posicion del cursor
			inc si



			;cmp columna, 80d
			;jl noSalto
			;	mov columna,0
			;	inc fila
			;noSalto:

			cmp bufferInformacion[si], 36d ; $
			jne ciclo2
			;print salto
			;print RespuestaNoTrip
			;print texto
			;print salto
			jmp SIESTRIP
		
		SIESTRIP:
		print salto
		print RespuestaEsTrip
		print salto
	
		JMP Menu

		SALIRT:
		print salto
		print RespuestaNoTrip
		print salto
		print salto

		JMP Menu

		SALIRTt:
		print msjPunto1
		JMP Menu
	PALABRA_DIPTONGO:
		;push bx
		xor si,si
		mov si,0
		mov di, 0
		;call XOR_REG
		print salto
		limpiar bufferPalabra,15,24h
		print msjComando6
		obtenerTexto bufferPalabra
		print salto
		print bufferPalabra
		print salto
			
		ciclo4:
			call XOR_REG
			;----------------------------------------------------------------------------------------

			;esTriptongoP bufferPalabra[si], bufferPalabra[si+1], bufferPalabra[si+2]
			;cmp bl,0
			;JNE esTripPrintT
			
			esDiptongoP bufferPalabra[si], bufferPalabra[si+1]  
			cmp al,0  
			JNE esDipPrintTD

			;esHiatoP bufferPalabra[si], bufferPalabra[si+1]
			;cmp cl,0
			;JNE esHiatoPrintT
			JMP letraT
			
			

			esDipPrintTD:
				;pintamos el diptongo
				;imprimirVideo bufferInformacion[si], 0010b ;imprimos verde 
				;inc columna ;aumenta la posicion del cursor
				inc si

				;posicionarCursor fila, columna

				
				;imprimirVideo bufferInformacion[si], 0010b ;imprimos verde  
				jmp SIESTRIPD

				;letra:
				;	imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
				;	jmp siguiente
		;--------------------------------------------------------------------------------------
			esTripPrintTD:
				;pintamos el diptongo
				;imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
				;inc columna ;aumenta la posicion del cursor
				inc si

				;posicionarCursor fila, columna

				
				;imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
				;inc columna ;aumenta la posicion del cursor
				inc si 
				

				;posicionarCursor fila, columna
				;imprimirVideo bufferInformacion[si],1110b ;imprimos amarillo 
				jmp SALIRTD
		;---------------------------------------------------------------------------------------
			esHiatoPrintTD:
			;pintamos el hiato
				;imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo 
				;inc columna ;aumenta la posicion del cursor
				inc si

				;posicionarCursor fila, columna

				
				;imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo  
				jmp siguienteTD

				
		;---------------------------------------------------------------------------------------
			letraTD:
				;imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
				jmp siguienteTD
		;--------------------------------------------------------------------------------------

			siguienteTD:
		
			;inc columna ;aumenta la posicion del cursor
			inc si



			;cmp columna, 80d
			;jl noSalto
			;	mov columna,0
			;	inc fila
			;noSalto:

			cmp bufferInformacion[si], 36d ; $
			jne ciclo4
			;print salto
			;print RespuestaNoTrip
			;print texto
			;print salto
			jmp SIESTRIPD
		
		SIESTRIPD:
		print salto
		print RespuestaEsDi
		print salto
	
		JMP Menu

		SALIRTD:
		print salto
		print RespuestaNoDi
		print salto
		print salto
	
		JMP Menu

		SALIRTtD:
		print msjPunto1
		JMP Menu

	PALABRA_HIATO:
		;push bx
		xor si,si
		mov si,0
		mov di, 0
		;call XOR_REG
		print salto
		limpiar bufferPalabra,15,24h
		print msjComando7
		obtenerTexto bufferPalabra
		print salto
		print bufferPalabra
		print salto
			
		ciclo3:
			call XOR_REG
			;----------------------------------------------------------------------------------------

			;esTriptongoP bufferPalabra[si], bufferPalabra[si+1], bufferPalabra[si+2]
			;cmp bl,0
			;JNE esTripPrintT
			
			;esDiptongoP bufferPalabra[si], bufferPalabra[si+1]  
			;cmp al,0  
			;JNE esDipPrintT

			esHiatoP bufferPalabra[si], bufferPalabra[si+1]
			cmp cl,0
			JNE esHiatoPrintTH
			JMP letraT
			
			

			esDipPrintTH:
				;pintamos el diptongo
				;imprimirVideo bufferInformacion[si], 0010b ;imprimos verde 
				;inc columna ;aumenta la posicion del cursor
				inc si

				;posicionarCursor fila, columna

				
				;imprimirVideo bufferInformacion[si], 0010b ;imprimos verde  
				jmp siguienteTH

				;letra:
				;	imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
				;	jmp siguiente
		;--------------------------------------------------------------------------------------
			esTripPrintTH:
				;pintamos el diptongo
				;imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
				;inc columna ;aumenta la posicion del cursor
				inc si

				;posicionarCursor fila, columna

				
				;imprimirVideo bufferInformacion[si], 1110b ;imprimos amarillo 
				;inc columna ;aumenta la posicion del cursor
				inc si 
				

				;posicionarCursor fila, columna
				;imprimirVideo bufferInformacion[si],1110b ;imprimos amarillo 
				jmp SALIRTH
		;---------------------------------------------------------------------------------------
			esHiatoPrintTH:
			;pintamos el hiato
				;imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo 
				;inc columna ;aumenta la posicion del cursor
				inc si

				;posicionarCursor fila, columna

				
				;imprimirVideo bufferInformacion[si], 0100b ;imprimos rojo  
				jmp SIESTRIPH

				
		;---------------------------------------------------------------------------------------
			letraTH:
				;imprimirVideo bufferInformacion[si], 1111b ;imprimos blanco  
				jmp siguienteTH
		;--------------------------------------------------------------------------------------

			siguienteTH:
		
			;inc columna ;aumenta la posicion del cursor
			inc si



			;cmp columna, 80d
			;jl noSalto
			;	mov columna,0
			;	inc fila
			;noSalto:

			cmp bufferInformacion[si], 36d ; $
			jne ciclo3
			;print salto
			;print RespuestaNoTrip
			;print texto
			;print salto
			jmp SIESTRIPH
		
		SIESTRIPH:
		print salto
		print RespuestaEsHi
		print salto

		JMP Menu

		SALIRTH:
		print salto
		print RespuestaNoHi
		print salto
		print salto

		JMP Menu

		SALIRTtH:
		print msjPunto1
		JMP Menu	



exit:
	close

main endp
end main