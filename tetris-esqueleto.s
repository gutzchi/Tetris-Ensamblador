
# Versión incompleta del tetris 
# Sincronizada con tetris.s:r2916
        
	.data	

pantalla:
	.word	0
	.word	0
	.space	1024

campo:
	.word	0
	.word	0
	.space	1024

pieza_actual:
	.word	0
	.word	0
	.space	1024

pieza_actual_x:
	.word 0

pieza_actual_y:
	.word 0

imagen_auxiliar:
	.word	0
	.word	0
	.space	1024

pieza_jota:
	.word	2
	.word	3
	.ascii		"\0#\0###\0\0"

pieza_ele:
	.word	2
	.word	3
	.ascii		"#\0#\0##\0\0"

pieza_barra:
	.word	1
	.word	4
	.ascii		"####\0\0\0\0"

pieza_zeta:
	.word	3
	.word	2
	.ascii		"##\0\0##\0\0"

pieza_ese:
	.word	3
	.word	2
	.ascii		"\0####\0\0\0"

pieza_cuadro:
	.word	2
	.word	2
	.ascii		"####\0\0\0\0"

pieza_te:
	.word	3
	.word	2
	.ascii		"\0#\0###\0\0"

piezas:
	.word	pieza_jota
	.word	pieza_ele
	.word	pieza_zeta
	.word	pieza_ese
	.word	pieza_barra
	.word	pieza_cuadro
	.word	pieza_te

acabar_partida:
	.byte	0

	.align	2
procesar_entrada.opciones:
	.byte	'x'
	.space	3
	.word	tecla_salir
	.byte	'j'
	.space	3
	.word	tecla_izquierda
	.byte	'l'
	.space	3
	.word	tecla_derecha
	.byte	'k'
	.space	3
	.word	tecla_abajo
	.byte	'i'
	.space	3
	.word	tecla_rotar

str000:
	.asciiz		"Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n"
str001:
	.asciiz		"\n¡Adiós!\n"
str002:
	.asciiz		"\nOpción incorrecta. Pulse cualquier tecla para seguir.\n"


	.text	

imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = dirección de la imagen 
					# $t1 ← ancho
    	mul	$t1, $t1, $a2		# $a2 * ancho
    	addu	$t1, $t1, $a1		# $a2 * ancho + $a1
    	addiu	$a0, $a0, 8		# $a0 ← dirección del array data
    	addu	$v0, $a0, $t1		# $v0 = $a0 + $a2 * ancho + $a1
    	jr	$ra

imagen_get_pixel:			# ($a0, $a1, $a2) = (img, x, y)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	lbu	$v0, 0($v0)		# lee el pixel a devolver
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

imagen_set_pixel:			#($a0, $a1, $a2, $a3) = (img, x, y,color)
	# Funcion que guarda el valor del pixel pasado como parámetro
	# Apilamos los registros que queremos preservar
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	# Guardamos color para preservarlo tras la llamada
	move	$s0, $a3
	
	# Llamamos a la funcion que nos devuelve la direccion del pixel determinado
	jal	imagen_pixel_addr
	
	# Guardamos el nuevo valor del pixel
	sb	$s0, 0($v0)
	
	# Desapilamos
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr 	$ra

imagen_clean:
	# Rellenamos toda la imagen con el color especificado
	# ($a0,$a1) = (img, color)
	
	# Apilamos los registros necesarios:
	addi	$sp, $sp, -28
	
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$s4, 20($sp)
	sw	$s5, 24($sp)
        
        # Movemos los parametros a los registros s:
        move 	$s0, $a0
	move 	$s1, $a1        
        
        # Iniciamos el iteradores i a 0
        move	$s2, $0
        
        #Cargamos el ancho y el alto
        lw	$s4, 4($s0) # alto
        lw	$s5, 0($s0) # ancho
        
        # Bucle que itera las filas:
imgc_3: bge	$s2, $s4, imgc_0
        
        #Inicializamos el iterador j a 0
        move	$s3, $0		
        
        # Bucle que itera las columnas:
imgc_2:	bge	$s3, $s5, imgc_1
        
        # Cargamos los parametros de la funcion que vamos a llamar:
        move	$a0, $s0
        move	$a1, $s3
        move	$a2, $s2
        move	$a3, $s1
        
        # Llamamos a la funcion
        jal	imagen_set_pixel
        
        # Mantenemos el invariante de los dos bucles
        addi	$s3, $s3, 1
        j imgc_2
        
imgc_1:	addi	$s2, $s2, 1
	j	imgc_3
	
imgc_0: # Desapilamos
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	lw	$s5, 24($sp)
	
	addi	$sp, $sp, 28
	jr 	$ra
imagen_init:
	# ($a0,$a1,$a2,$a3) = (img,ancho,alto,color)
	# Establece el ancho y el alto y llama a la funcion imagen_clean
	# Apilamos
	addi	$sp,$sp,-4
	sw	$ra, 0($sp)
	
	# Guardamos el ancho y el alto
	sw	$a1, 0($a0)
	sw	$a2, 4($a0)
	
	# Cargamos los parametros y llamamos a la funcion
	move	$a1, $a3
	jal	imagen_clean
	
	# Desapilamos
	lw	$ra, 0($sp)
	addi	$sp,$sp,4	
	jr	$ra
	

imagen_copy:
	# ($a0,$a1) = (destino,fuente)
	# Copia la imagen fuente a la imagen destino
	
	# Apilamos los registros necesarios:
	addi	$sp, $sp, -28
	
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$s4, 20($sp)
	sw	$s5, 24($sp)
	
	# Guardamos las direcciones de las imagenes en registros s:
	move	$s0, $a0	# destino
	move	$s1, $a1	# fuente
	
	# Guardamos el ancho y el alto en registros s y en la imagen destino:
	lw	$s2, 0($s1)	#ancho
	lw	$s3, 4($s1)	#alto
	sw	$s2, 0($s0)
	sw	$s3, 4($s0)
	
	# Inicializamos i a 0
	li	$s4, 0
	
	# Primer bucle que recorre las filas
img_cp3:bge	$s4, $s3, img_cp0
	
	#Inicializamos j a 0
	li	$s5, 0
	
	#Segundo bucle que recorre las columnas:
img_cp2:bge	$s5, $s2, img_cp1
	
	# Cargamos parametros y llamamos a imagen_get_pixel
	move	$a0, $s1
	move	$a1, $s5
	move	$a2, $s4
	jal	imagen_get_pixel
	
	# Cargamos parametros y llamamos a imagen_set_pixel
	move	$a0, $s0
	move	$a1, $s5
	move	$a2, $s4
	move	$a3, $v0
	jal	imagen_set_pixel
	
	# Mantenemos el invariante:
	addi	$s5, $s5, 1
	j	img_cp2

img_cp1:addi	$s4, $s4, 1
	j	img_cp3
	
img_cp0:# Desapilamos
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	lw	$s5, 24($sp)
	
	addi	$sp, $sp, 28
	jr 	$ra

imagen_print:				# $a0 = img
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a0
	lw	$s3, 4($s0)		# img->alto
	lw	$s4, 0($s0)		# img->ancho
        #  for (int y = 0; y < img->alto; ++y)
	li	$s1, 0			# y = 0
B6_2:	bgeu	$s1, $s3, B6_5		# acaba si y ≥ img->alto
	#    for (int x = 0; x < img->ancho; ++x)
	li	$s2, 0			# x = 0
B6_3:	bgeu	$s2, $s4, B6_4		# acaba si x ≥ img->ancho
	move	$a0, $s0		# Pixel p = imagen_get_pixel(img, x, y)
	move	$a1, $s2
	move	$a2, $s1
	jal	imagen_get_pixel
	move	$a0, $v0		# print_character(p)
	jal	print_character
	addiu	$s2, $s2, 1		# ++x
	j	B6_3
	#    } // for x
B6_4:	li	$a0, 10			# print_character('\n')
	jal	print_character
	addiu	$s1, $s1, 1		# ++y
	j	B6_2
	#  } // for y
B6_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra

imagen_dibuja_imagen:
	# ($a0,$a1,$a2,$a3) = (destino,fuente,posdestx,posdesty)
	# Copia la imagen fuente a la imagen destino
	
	# Apilamos los registros necesarios:
	addi	$sp, $sp, -36
	
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$s4, 20($sp)
	sw	$s5, 24($sp)
	sw	$s6, 28($sp)
	sw	$s7, 32($sp)
	
	# Guardamos los cuatro parametros en registros s:
	move	$s0, $a0 	# destino
	move	$s1, $a1	# fuente
	move	$s2, $a2	# xdest
	move	$s3, $a3	# ydest
	
	# Cargamos el ancho y el alto de la fuente en registros s:
	lw	$s4, 0($s1)
	lw	$s5, 4($s1)
	
	# Inicializamos primer iterador a 0:
	move	$s6, $0
	
	# Doble bucle
imgdi_4:beq	$s6, $s5, imgdi_0
	move	$s7, $0
imgdi_3:beq	$s7, $s4, imgdi_1
	
	# Cargamos parametros y llamamos a imagen_get_pixel
	move	$a0, $s1
	move	$a1, $s7
	move	$a2, $s6
	jal	imagen_get_pixel
	move	$t0, $v0
	
	# Si no nos encontramos con el pixel vacio
	# llamamos a imagen_set_pixel
	beqz	$t0, imgdi_2
	move	$a0, $s0
	add	$a1, $s7, $s2
	add	$a2, $s6, $s3
	move	$a3, $t0
	jal	imagen_set_pixel
	
imgdi_2:# Mantenemos el invariante de los dos bucles:
	addi	$s7, $s7, 1
	j	imgdi_3
	
imgdi_1:addi	$s6, $s6, 1
	j	imgdi_4
	
imgdi_0:# Desapilamos
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	lw	$s5, 24($sp)
	lw	$s6, 28($sp)
	lw	$s7, 32($sp)
	
	addi	$sp, $sp, 36
	jr	$ra

imagen_dibuja_imagen_rotada:
	# ($a0,$a1,$a2,$a3) = (destino,fuente,posdestx,posdesty)
	# Copia la imagen fuente a la imagen destino rotandola 90 grados
	
	# Apilamos los registros necesarios:
	addi	$sp, $sp, -36
	
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$s4, 20($sp)
	sw	$s5, 24($sp)
	sw	$s6, 28($sp)
	sw	$s7, 32($sp)
	
	# Guardamos los cuatro parametros en registros s:
	move	$s0, $a0 	# destino
	move	$s1, $a1	# fuente
	move	$s2, $a2	# xdest
	move	$s3, $a3	# ydest
	
	# Cargamos el ancho y el alto de la fuente en registros s:
	lw	$s4, 0($s1)
	lw	$s5, 4($s1)
	
	# Inicializamos primer iterador a 0:
	move	$s6, $0
	
	# Doble bucle
imgri_4:beq	$s6, $s5, imgri_0
	move	$s7, $0
imgri_3:beq	$s7, $s4, imgri_1
	
	# Cargamos parametros y llamamos a imagen_get_pixel
	move	$a0, $s1
	move	$a1, $s7
	move	$a2, $s6
	jal	imagen_get_pixel
	move	$t0, $v0
	
	# Si no nos encontramos con el pixel vacio
	# llamamos a imagen_set_pixel
	beqz	$t0, imgri_2
	move	$a0, $s0
	# Pasamos los parametros de y e y rotados 90 grados
	addi	$t1, $s5, -1
	sub	$t1, $t1, $s6
	add	$a1, $t1, $s2
	add	$a2, $s3, $s7
	move	$a3, $t0
	jal	imagen_set_pixel
	
imgri_2:# Mantenemos el invariante de los dos bucles:
	addi	$s7, $s7, 1
	j	imgri_3
	
imgri_1:addi	$s6, $s6, 1
	j	imgri_4
	
imgri_0:# Desapilamos
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	lw	$s5, 24($sp)
	lw	$s6, 28($sp)
	lw	$s7, 32($sp)
	
	addi	$sp, $sp, 36
	jr	$ra

pieza_aleatoria:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0, 0
	li	$a1, 7
	jal	random_int_range	# $v0 ← random_int_range(0, 7)
	sll	$t1, $v0, 2
	la	$v0, piezas
	addu	$t1, $v0, $t1		# $t1 = piezas + $v0*4
	lw	$v0, 0($t1)		# $v0 ← piezas[$v0]
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

actualizar_pantalla:
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s2, 4($sp)
	sw	$s1, 0($sp)
	la	$s2, campo
	la	$a0, pantalla
	li	$a1, ' '
	jal	imagen_clean		# imagen_clean(pantalla, ' ')
        # for (int y = 0; y < campo->alto; ++y) {
	li	$s1, 0			# y = 0
B10_2:	lw	$t1, 4($s2)		# campo->alto
	bge	$s1, $t1, B10_3		# sigue si y < campo->alto
	la	$a0, pantalla
	li	$a1, 0                  # pos_campo_x - 1
	addi	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, 0, y, '|')
	la	$a0, pantalla
	lw	$t1, 0($s2)		# campo->ancho
	addiu	$a1, $t1, 1		# campo->ancho + 1
	addiu	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, campo->ancho + 1, y, '|')
        addiu	$s1, $s1, 1		# ++y
        j       B10_2
        # } // for y
	# for (int x = 0; x < campo->ancho + 2; ++x) { 
B10_3:	li	$s1, 0			# x = 0
B10_5:  lw	$t1, 0($s2)		# campo->ancho
        addiu   $t1, $t1, 2             # campo->ancho + 2
        bge	$s1, $t1, B10_6		# sigue si x < campo->ancho + 2
	la	$a0, pantalla
	move	$a1, $s1                # pos_campo_x - 1 + x
        lw	$t1, 4($s2)		# campo->alto
	addiu	$a2, $t1, 2		# campo->alto + pos_campo_y
	li	$a3, '-'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, x, campo->alto + 1, '-')
	addiu	$s1, $s1, 1		# ++x
	j       B10_5
        # } // for x
B10_6:	la	$a0, pantalla
	move	$a1, $s2
	li	$a2, 1                  # pos_campo_x
	li	$a3, 2                  # pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, campo, 1, 2)
	la	$a0, pantalla
	la	$a1, pieza_actual
	lw	$t1, pieza_actual_x
	addiu	$a2, $t1, 1		# pieza_actual_x + pos_campo_x
	lw	$t1, pieza_actual_y
	addiu	$a3, $t1, 2		# pieza_actual_y + pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, pieza_actual, pieza_actual_x + pos_campo_x, pieza_actual_y + pos_campo_y)
	jal	clear_screen		# clear_screen()
	la	$a0, pantalla
	jal	imagen_print		# imagen_print(pantalla)
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

nueva_pieza_actual:
	# Devuelve una nueva pieza, llamando a la funcion pieza_aleatoria
	# Apilamos
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# Llamamos a la funcion pieza_aleatoria que nos devuelve un puntero
	# a una de las piezas
	jal	pieza_aleatoria
	
	# Llamamos a imagen_copy pasandole la imagen fuente y la imagen destino
	move	$a1, $v0
	la	$a0, pieza_actual
	jal	imagen_copy
	
	# Cargamos las direcciones de pieza_actual_x y pieza_actual_y
	# y les asignamos los valores del centro superior de la pantalla/campo
	la	$t0, pieza_actual_x
	li	$t1, 8
	sw	$t1, 0($t0)
	la	$t0, pieza_actual_y
	li	$t1, 0
	sw	$t1, 0($t0)
	
	# Desapilamos
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	

probar_pieza:				# ($a0, $a1, $a2) = (pieza, x, y)
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s7, 24($sp)
	sw	$s6, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a2		# y
	move	$s1, $a1		# x
	move	$s2, $a0		# pieza
	li	$v0, 0
	bltz	$s1, B12_13		# if (x < 0) return false
	lw	$t1, 0($s2)		# pieza->ancho
	addu	$t1, $s1, $t1		# x + pieza->ancho
	la	$s4, campo
	lw	$v1, 0($s4)		# campo->ancho
	bltu	$v1, $t1, B12_13	# if (x + pieza->ancho > campo->ancho) return false
	bltz	$s0, B12_13		# if (y < 0) return false
	lw	$t1, 4($s2)		# pieza->alto
	addu	$t1, $s0, $t1		# y + pieza->alto
	lw	$v1, 4($s4)		# campo->alto
	bltu	$v1, $t1, B12_13	# if (campo->alto < y + pieza->alto) return false
	# for (int i = 0; i < pieza->ancho; ++i) {
	lw	$t1, 0($s2)		# pieza->ancho
	beqz	$t1, B12_12
	li	$s3, 0			# i = 0
	#   for (int j = 0; j < pieza->alto; ++j) {
	lw	$s7, 4($s2)		# pieza->alto
B12_6:	beqz	$s7, B12_11
	li	$s6, 0			# j = 0
B12_8:	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s6
	jal	imagen_get_pixel	# imagen_get_pixel(pieza, i, j)
	beqz	$v0, B12_10		# if (imagen_get_pixel(pieza, i, j) == PIXEL_VACIO) sigue
	move	$a0, $s4
	addu	$a1, $s1, $s3		# x + i
	addu	$a2, $s0, $s6		# y + j
	jal	imagen_get_pixel
	move	$t1, $v0		# imagen_get_pixel(campo, x + i, y + j)
	li	$v0, 0
	bnez	$t1, B12_13		# if (imagen_get_pixel(campo, x + i, y + j) != PIXEL_VACIO) return false
B12_10:	addiu	$s6, $s6, 1		# ++j
	bltu	$s6, $s7, B12_8		# sigue si j < pieza->alto
        #   } // for j
B12_11:	lw	$t1, 0($s2)		# pieza->ancho
	addiu	$s3, $s3, 1		# ++i
	bltu	$s3, $t1, B12_6 	# sigue si i < pieza->ancho
        # } // for i
B12_12:	li	$v0, 1			# return true
B12_13:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s6, 20($sp)
	lw	$s7, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

intentar_movimiento:
	# ($a0, $a1) = (x,y)
	# Prueba a colocar la pieza actual en las coordenadas proporcionadas
	# Si lo consigue, cambia las coordenadas de la pieza y devuelve TRUE
	# Si no, devuelve FALSE
	
	# Apilamos
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	
	# Guardamos los parametros en registros s:
	move	$s0, $a0
	move	$s1, $a1
	
	# Cargamos los parametros de probar_pieza y llamamos a la funcion
	move	$a2, $s1
	move	$a1, $s0
	la	$a0, pieza_actual
	jal	probar_pieza
	
	# Si probar_pieza devuelve true, entonces actualizamos las posiciones actuales
	# y devolvemos true, si no devolvemos false
	
	beqz	$v0, intmov_0
	la	$t0, pieza_actual_x
	sw	$s0, 0($t0)
	la	$t0, pieza_actual_y
	sw	$s1, 0($t0)
	li	$v0, 1
	j	intmov_1
	
intmov_0:
	li	$v0, 0

intmov_1:		
	# Desapilamos
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra

bajar_pieza_actual:
	# intenta bajar la pieza, si no lo consigue, la pieza se inserta en el campo
	# y se crea una nueva pieza
	
	# Apilamos
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# LLamamos a intentar_movimiento, bajando la pieza en una unidad
	la	$t0, pieza_actual_x
	lw	$a0, 0($t0)
	la	$t0, pieza_actual_y
	lw	$a1, 0($t0)
	addi	$a1, $a1, 1
	jal	intentar_movimiento
	
	# Si no podemos mover, copiamos la imagen al campo y creamos una nueva pieza
	bnez	$v0, bpa_0
	
	# Llamamos a imagen_dibuja_imagen
	la	$a0, campo
	la	$a1, pieza_actual
	la	$t0, pieza_actual_x
	lw	$a2, 0($t0)
	la	$t0, pieza_actual_y
	lw	$a3, 0($t0)
	jal	imagen_dibuja_imagen
	
	# Y llamamos a nueva_pieza_actual
	jal	nueva_pieza_actual
		
bpa_0:	# Desapilamos y retornamos
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra

intentar_rotar_pieza_actual:
	# Intenta rotar la pieza actual, si lo consigue, cambia la pieza actual
	# por la imagen rotada
	
	#Apilamos
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	# Cargamos los parametros de imagen_init y llamamos a la funcion
	# Para realizar las pruebas usaremos el puntero a una variable llamada imagen_auxiliar
	la	$a0, imagen_auxiliar
	la	$t0, pieza_actual
	lw	$a1, 4($t0)
	lw	$a2, 0($t0)
	li	$a3, 0
	jal 	imagen_init
	
	# Cargamos los parametros de imagen_dibuja_imagen_rotada y llamamos a la funcion
	# "Dibujamos la pieza actual en la variable utilizada anteriormente llamada imagen_auxiliar
	la	$a0, imagen_auxiliar
	la	$a1, pieza_actual
	li	$a2, 0
	li	$a3, 0
	jal	imagen_dibuja_imagen_rotada
	
	# Cargamos los parametros y llamamos a probar_pieza
	la	$a0, imagen_auxiliar
	la	$t0, pieza_actual_x
	lw	$a1, 0($t0)
	la	$t0, pieza_actual_y
	lw	$a2, 0($t0)
	jal	probar_pieza
	
	# En el caso de que probar_pieza devuelva verdadero, copiamos la imagen auxiliar
	# en la pieza actual
	beqz	$v0, irpa_0
	la	$a0, pieza_actual
	la	$a1, imagen_auxiliar
	jal	imagen_copy
	
irpa_0:	#Desapilamos
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr 	$ra
	

tecla_salir:
	li	$v0, 1
	sb	$v0, acabar_partida	# acabar_partida = true
	jr	$ra

tecla_izquierda:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, -1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x - 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_derecha:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, 1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x + 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_abajo:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_rotar:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	intentar_rotar_pieza_actual	# intentar_rotar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

procesar_entrada:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	jal	keyio_poll_key
	move	$s0, $v0		# int c = keyio_poll_key()
        # for (int i = 0; i < sizeof(opciones) / sizeof(opciones[0]); ++i) { 
	li	$s1, 0			# i = 0, $s1 = i * sizeof(opciones[0]) // = i * 8
	la	$s3, procesar_entrada.opciones	
	li	$s4, 40			# sizeof(opciones) // == 5 * sizeof(opciones[0]) == 5 * 8
B21_1:	addu	$t1, $s3, $s1		# procesar_entrada.opciones + i*8
	lb	$t2, 0($t1)		# opciones[i].tecla
	bne	$t2, $s0, B21_3		# if (opciones[i].tecla != c) siguiente iteración
	lw	$t2, 4($t1)		# opciones[i].accion
	jalr	$t2			# opciones[i].accion()
	jal	actualizar_pantalla	# actualizar_pantalla()
B21_3:	addiu	$s1, $s1, 8		# ++i, $s1 += 8
	bne	$s1, $s4, B21_1		# sigue si i*8 < sizeof(opciones)
        # } // for i
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

jugar_partida:
	addiu	$sp, $sp, -12	
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	la	$a0, pantalla
	li	$a1, 20
	li	$a2, 22
	li	$a3, 32
	jal	imagen_init		# imagen_init(pantalla, 20, 22, ' ')
	la	$a0, campo
	li	$a1, 14
	li	$a2, 18
	li	$a3, 0
	jal	imagen_init		# imagen_init(campo, 14, 18, PIXEL_VACIO)
	jal	nueva_pieza_actual	# nueva_pieza_actual()
	sb	$zero, acabar_partida	# acabar_partida = false
	jal	get_time		# get_time()
	move	$s0, $v0		# Hora antes = get_time()
	jal	actualizar_pantalla	# actualizar_pantalla()
	j	B22_2
        # while (!acabar_partida) { 
B22_2:	lbu	$t1, acabar_partida
	bnez	$t1, B22_5		# if (acabar_partida != 0) sale del bucle
	jal	procesar_entrada	# procesar_entrada()
	jal	get_time		# get_time()
	move	$s1, $v0		# Hora ahora = get_time()
	subu	$t1, $s1, $s0		# int transcurrido = ahora - antes
	ble	$t1, 1000, B22_2	# if (transcurrido < pausa) siguiente iteración
B22_1:	jal	bajar_pieza_actual	# bajar_pieza_actual()
	jal	actualizar_pantalla	# actualizar_pantalla()
	move	$s0, $s1		# antes = ahora
        j	B22_2			# siguiente iteración
       	# } 
B22_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

	.globl	main
main:					# ($a0, $a1) = (argc, argv) 
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
B23_2:	jal	clear_screen		# clear_screen()
	la	$a0, str000
	jal	print_string		# print_string("Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n")
	jal	read_character		# char opc = read_character()
	beq	$v0, '2', B23_1		# if (opc == '2') salir
	bne	$v0, '1', B23_5		# if (opc != '1') mostrar error
	jal	jugar_partida		# jugar_partida()
	j	B23_2
B23_1:	la	$a0, str001
	jal	print_string		# print_string("\n¡Adiós!\n")
	li	$a0, 0
	jal	mips_exit		# mips_exit(0)
	j	B23_2
B23_5:	la	$a0, str002
	jal	print_string		# print_string("\nOpción incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	B23_2
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra
	
main2:
       addi $sp, $sp, -4
       sw $ra, 0($sp)

       # Para probar imagen_set_pixel, imagen_clean e imagen_init
       # Tiene que salir un rectángulo de 20x22 con el carácter '+'

       la $a0, pantalla
       li $a1, 20
       li $a2, 22
       li $a3, '+'
       jal imagen_init

 

       #Decomentar las siguientes líneas sólo para probar imagen_copy. Una vez probada, volver a comentarlas.
       #Tiene que aparecer la pieza ese con el carácter "#"

       #la $a0, pantalla
       #la $a1, pieza_ele
       #jal imagen_copy

 

       #Decomentar las siguientes líneas sólo para probar imagen_dibuja_imagen. Una vez probada, volver a comentarlas.
       #Tiene que aparecer la pieza ese con el carácter "#" entre los "+" del rectángulo
       #En este caso es conveniente probar distintas piezas, como la jota o la barra, para comprobar que no ha habido errores.

       #la $a0, pantalla
       #la $a1, pieza_barra
       #li $a2, 2
       #li $a3, 4
       #jal imagen_dibuja_imagen

 

       #Decomentar las siguientes líneas sólo para probar imagen_dibuja_imagen_rotada. Una vez probada, volver a comentarlas.
       #Tiene que aparecer la pieza ese rotada con el carácter "#" entre los "+" del rectángulo
       #En este caso es conveniente probar distintas pieza, como la jota o la barra,  para comprobar que no ha habido errores.

       #la $a0, pantalla
       #la $a1, pieza_barra
       #li $a2, 6
       #li $a3, 6
       #jal imagen_dibuja_imagen_rotada

	# Para probar nueva_pieza_actual
	jal nueva_pieza_actual
	la $a0, pantalla
        la $a1, pieza_actual
        la $t0, pieza_actual_x
        lw $a2, 0($t0)
        la $t0, pieza_actual_y
        lw $a3, 0($t0)
        jal imagen_dibuja_imagen

       la $a0, pantalla
       jal imagen_print


       jal mips_exit

       lw $ra, 0($sp)
       addi $sp, $sp, 4
       jr $ra

#
# Funciones de la librería del sistema
#

print_character:
	li	$v0, 11
	syscall	
	jr	$ra

print_string:
	li	$v0, 4
	syscall	
	jr	$ra

get_time:
	li	$v0, 30
	syscall	
	move	$v0, $a0
	move	$v1, $a1
	jr	$ra

read_character:
	li	$v0, 12
	syscall	
	jr	$ra

clear_screen:
	li	$v0, 39
	syscall	
	jr	$ra

mips_exit:
	li	$v0, 17
	syscall	
	jr	$ra

random_int_range:
	li	$v0, 42
	syscall	
	move	$v0, $a0
	jr	$ra

keyio_poll_key:
	li	$v0, 0
	lb	$t0, 0xffff0000
	andi	$t0, $t0, 1
	beqz	$t0, keyio_poll_key_return
	lb	$v0, 0xffff0004
keyio_poll_key_return:
	jr	$ra
