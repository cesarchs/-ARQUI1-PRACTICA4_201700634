include macros.asm ;archivo con los macros a utilizar

.model small

;----------------SEGMENTO DE PILA---------------------

.stack

;----------------SEGMENTO DE DATO---------------------

.data

bufferentrada db 50 dup('$')
handlerentrada dw ?
bufferInformacion db 200 dup('$')

salto db 0ah,0dh, '$' ,'$'
opcion db 0ah,0dh, 'Elija una opcion:' , '$'
encabezadoMenu db 0ah,0dh, 'Administrador de archivos' , 0ah,0dh, '1.) Abrir archivo' , 0ah,0dh, '2.) Crear archivo' , 0ah,0dh, '3.) Salir' , '$'
enc2 db 0ah,0dh, '1.) Mostrar informacion' , 0ah,0dh, '2.) Cerrar archivo' , '$'
enc3 db 0ah,0dh, '1.) Escribir en archivo' , 0ah,0dh, '2.) Cerrar archivo' , '$'
ingreseruta db 0ah,0dh, 'Ingrese una ruta de archivo' , 0ah,0dh, 'Ejemplo: entrada.txt' , '$'
ing2 db 0ah,0dh, 'Ingrese texto a escribir' , '$'
err1 db 0ah,0dh, 'Error al abrir el archivo puede que no exista' , '$'
err2 db 0ah,0dh, 'Error al cerrar el archivo' , '$'
err3 db 0ah,0dh, 'Error al escribir en el archivo' , '$'
err4 db 0ah,0dh, 'Error al crear en el archivo' , '$'
err5 db 0ah,0dh, 'Error al leer en el archivo' , '$'

;----------------SEGMENTO DE CODIGO---------------------

.code
main proc


	MenuPrincipal:
		print salto
		print encabezadoMenu
		print salto
		print opcion
		getChar
		cmp al,31h ;si es 1 abrir archivo 
		je AbrirArchivo
		cmp al,32h ;si es 2, crear archivo 
		je CrearArchivo
		cmp al,33h
		je Salir ; si es 3, salir
		jmp MenuPrincipal ;sino es ninguna ir al menú principal 

	AbrirArchivo:
		print salto
		print ingreseruta
		print salto
		limpiar bufferentrada, SIZEOF bufferentrada,24h ;limpiamos el arreglo bufferentrada con $
		obtenerRuta bufferentrada ;obtenemos la ruta en buffer de entrada
		abrir bufferentrada,handlerentrada  ;le mandamos la ruta y el handler,que será la referencia al fichero 
		limpiar bufferInformacion, SIZEOF bufferInformacion,24h  ;limpiamos la variable donde guardaremos los datos del archivo 
		leer handlerentrada, bufferInformacion, SIZEOF bufferInformacion ;leemos el archivo 


	AbrirArchivo2:	
		print salto
		print enc2
		print salto
		print opcion
		getChar
		cmp al,31h
		je MostrarInformacion
		cmp al,32h
		je CerrarArchivo
		jmp AbrirArchivo


	CrearArchivo:
		print salto
		print ingreseruta		
		print salto		
		limpiar bufferentrada, SIZEOF bufferentrada,24h
		obtenerRuta bufferentrada
		crear bufferentrada, handlerentrada

	
	CrearArchivo2:	
		print salto
		print enc3
		print salto
		print opcion
		getChar
		cmp al,31h
		je EscribirArchivo
		cmp al,32h
		je CerrarArchivo
		jmp AbrirArchivo

	MostrarInformacion:
		print salto
		print bufferInformacion
		print salto
		getChar
		jmp AbrirArchivo2

	EscribirArchivo:
		print salto
		limpiar bufferInformacion, SIZEOF bufferInformacion,24h
		print ing2
		ObtenerTexto bufferInformacion
		escribir  handlerentrada, bufferInformacion, SIZEOF bufferInformacion
		print salto
		
		jmp CrearArchivo2

	CerrarArchivo:
		cerrar handlerentrada
		jmp MenuPrincipal

	Error1:
		print salto
		print err1
		getChar
		jmp MenuPrincipal

	Error2:
		print salto
		print err2
		getChar
		jmp MenuPrincipal
	
	Error3:
		print salto
		print err3
		getChar
		jmp MenuPrincipal
	
	Error4:
		print salto
		print err4
		getChar
		jmp MenuPrincipal

	Error5:
		print salto
		print err5
		getChar
		jmp MenuPrincipal


	Salir:
		close

main endp
end main	
