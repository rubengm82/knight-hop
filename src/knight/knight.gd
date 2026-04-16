extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $Animation
@onready var audio_jump: AudioStreamPlayer = $AudioPlayer_jump
@onready var area2d: Area2D = $Area2D_Damage

# Cargar la escena de polvo para el salto
var jump_dust_scene = preload("res://src/knight/knight_jump_dirt.tscn")

# CONSTANTS
const SPEED := 100.0					# Velocidad de su movimiento horizontal
const ACCELERATION := 900.0				# Aceleracion de sus movimientos horizontales
const FRICTION := 1000.0				# Friccion de sus zapatos

const COYOTE_TIME := 0.15				# Tiempo extra para saltar tras dejar el suelo
const JUMP_VELOCITY := -250.0			# Potencia del salto
const MAX_JUMP_TIME := 0.2				# Tiempo máximo para salto variable
const DOUBLE_JUMP_VELOCITY := -200.0	# El segundo salto sea inferior al primero
const JUMP_FORCE := -350.0				# Fuerza aplicada mientras mantienes la tecla de salto
const MAX_JUMPS := 2					# Número máximo de saltos (1 = normal, 2 = doble salto)
var ENABLE_DOUBLE_JUMP := false		    # Habilitar o deshabilitar el doble salto

const DROP_THROUGH_HOLD_TIME := 0.05	# Tiempo mínimo que debes mantener abajo para poder caer

# VARS
var jump_time := 0.0
var is_jumping := false					# Estas saltando?
var jump_count := 0						# Contador de saltos realizados
var coyote_timer := 0.0					# Contador para el coyote time
var down_hold_timer := 0.0				# Cuenta cuánto tiempo llevas apretando abajo

# Control de movimiento durante transiciones
var puede_moverse := true				# Si false, no se puede mover (durante transición)
var is_dying := false					# Si true, está muriendo (para animación)


# =====================================================
# SETTER - Habilitar/deshabilitar movimiento
# =====================================================
func set_puede_moverse(valor: bool) -> void:
	puede_moverse = valor



# =====================================================
# PHYSICS
# =====================================================
func _physics_process(delta: float) -> void:
	# INPUT / TIMERS
	handle_down_timer(delta)
	
	# FÍSICA
	handle_gravity_and_coyote(delta)
	handle_jump_logic(delta)
	handle_horizontal_movement(delta)

	# MOVIMIENTO
	move_and_slide()
	
	# VISUAL
	update_animation()
	update_flip()   


# =====================================================
# INPUT TIMER (DOWN HOLD) - Actualiza timer para mantener abajo
# =====================================================
func handle_down_timer(delta: float) -> void:
	if Input.is_action_pressed("move_down"):
		down_hold_timer += delta
	else:
		down_hold_timer = 0.0


# =====================================================
# GRAVITY + COYOTE + RESET JUMPS - Actualiza gravedad y coyote timer
# =====================================================
func handle_gravity_and_coyote(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		coyote_timer = max(coyote_timer - delta, 0.0)
	else:
		coyote_timer = COYOTE_TIME
		jump_count = 0  # Resetea el contador de saltos al tocar el suelo


# =====================================================
# JUMP - Lógica de salto normal, doble salto y salto variable
# =====================================================
func handle_jump_logic(delta: float) -> void:
	if is_dying:
		return
	
	### INFORMACION DE COMO FUNCIONA EL SALTO(JUMP) DE KNIGHT
	## Presiona jump?
	## │
	## ├─[mantiene ABAJO + 0.05s]─→ DROP_THROUGH (atravesar plataforma)
	## │
	## └─[no hizo drop-through]──→ ¿Hay coyote time?
	##                                 │
	##                                 ├─[SÍ]──→ SALTO NORMAL (-250)
	##                                 │
	##                                 └─[NO]──→ ¿jump_count < 2?
	##                                              │
	##                                              ├─[SÍ]──→ DOBLE SALTO (-200)
	##                                              └─[NO]──→ (no pasa nada)
	###

	# Bandera para saber si hicimos drop_through (evita salto normal después)
	var did_drop_through := false

	# Prioridad 1: Caer por plataforma si mantienes abajo un tiempo y saltas
	if down_hold_timer >= DROP_THROUGH_HOLD_TIME \
	and Input.is_action_just_pressed("move_jump") \
	and is_on_floor():
		drop_through()
		did_drop_through = true

	# Prioridad 2: Salto normal con coyote time (solo si no haces drop_through)
	if not did_drop_through and Input.is_action_just_pressed("move_jump"):

		if coyote_timer > 0.0:
			# Primer salto desde el suelo con coyote time
			is_jumping = true
			jump_time = 0.0
			velocity.y = JUMP_VELOCITY
			audio_jump.play()
			# Crear efecto de polvo al saltar solo si está en el suelo (no durante coyote time)
			if coyote_timer == COYOTE_TIME:
				_crear_polvo_salto()
			coyote_timer = 0.0
			jump_count = 1

		elif ENABLE_DOUBLE_JUMP and jump_count < MAX_JUMPS:
			# Doble salto en el aire
			is_jumping = true
			audio_jump.play()
			jump_time = 0.0
			velocity.y = DOUBLE_JUMP_VELOCITY
			jump_count += 1

	# Salto variable: mantener fuerza manteniendo tecla y no pasas tiempo max
	if is_jumping:
		jump_time += delta

		if Input.is_action_pressed("move_jump") and jump_time < MAX_JUMP_TIME:
			velocity.y += JUMP_FORCE * delta
		else:
			is_jumping = false

	# Salto dependiendo cuanto tiempo se presione la tecla "move_jump"
	if Input.is_action_just_released("move_jump") and velocity.y < 0:
		velocity.y *= 0.5


# =====================================================
# HORIZONTAL MOVEMENT - Movimiento horizontal
# =====================================================
func handle_horizontal_movement(delta: float) -> void:
	# Si no puede moverse (durante transición), no procesar input
	if not puede_moverse:
		# Aplicar fricción para detener al jugador
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		return
	
	var raw := Input.get_axis("move_left", "move_right")

	var direction := 0.0

	# Si es teclado o Joystick digital
	if raw == -1.0 or raw == 1.0:
		direction = sign(raw)
	else:
		# Joystick analogico → solo actúa si supera 0.5
		if abs(raw) > 0.5:
			direction = sign(raw)

	velocity.x = move_toward(
		velocity.x,
		direction * SPEED,
		ACCELERATION * delta if direction != 0 else FRICTION * delta
	)


# =====================================================
# ANIMATION de KNIGHT - Funcion para el manejo de animaciones
# =====================================================
func update_animation() -> void:
	if is_dying:
		if animation.animation != "dead":
			animation.play("dead")
		return
	
	if is_on_floor():
		if abs(velocity.x) < 10.0:
			animation.play("idle")
		else:
			animation.play("run")
	else:
		if velocity.y < 0:
			animation.play("jump")
		else:
			animation.play("fall")


# =====================================================
# FLIP de Animacion - Flip del sprite según dirección
# =====================================================
func update_flip() -> void:
	if velocity.x > 0:
		animation.flip_h = false
	elif velocity.x < 0:
		animation.flip_h = true


# =====================================================
# DROP THROUGH - Atravesar plataformas y bajar por ellas
# =====================================================
func drop_through() -> void:
	# Solo ejecuta si hay una plataforma debajo
	if is_on_floor():
		# Desactiva temporalmente la colisión con capa 1 para atravesar plataformas
		#  Corregir para poner luego en la capa que sea solo de:
		#	Plataforas de Descenso
		set_collision_mask_value(5, false)
		await get_tree().create_timer(0.2).timeout
		set_collision_mask_value(5, true)


# =====================================================
# AREA ENTERED - Cuando a Knight le atraviesa layers seleccionados
# =====================================================
func _on_area_2d_body_entered(_body: Node2D) -> void:
	# Marcar como muriendo
	is_dying = true
	# Detener movimiento completamente
	velocity = Vector2.ZERO
	# Deshabilitar movimiento
	puede_moverse = false
	# Reproducir animación de muerte
	animation.play("dead")
	# Esperar a que termine la animación
	await animation.animation_finished
	# Esperar 1 segundo adicional
	await get_tree().create_timer(1.0).timeout
	# Buscar la escena principal
	var main_scene = _buscar_main_scene()
	
	if main_scene and main_scene.has_method("reiniciar_nivel"):
		main_scene.reiniciar_nivel()
	else:
		# Fallback: recargar la escena actual
		get_tree().call_deferred("reload_current_scene")

func _buscar_main_scene() -> Node:
	# Buscar MainScene usando find_child (busca recursivamente)
	return get_tree().root.find_child("MainScene", true, false)


# =====================================================
# DUST EFFECT - Crear efecto de polvo al saltar
# =====================================================
func _crear_polvo_salto() -> void:
	var polvo = jump_dust_scene.instantiate()
	get_parent().add_child(polvo)
	# Posicionar el polvo en los pies del knight (ajustar -16 según sea necesario)
	polvo.global_position = Vector2(global_position.x, global_position.y - 16)
	# Reproducir la animación
	polvo.play("jump_dirt")
	# Conectar la señal de animación terminada para borrar el polvo
	polvo.animation_finished.connect(_on_polvo_animacion_terminada.bind(polvo))

func _on_polvo_animacion_terminada(polvo: AnimatedSprite2D) -> void:
	polvo.queue_free()
