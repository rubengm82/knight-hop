extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $Animation

# CONSTANTS
const SPEED := 150.0					# Velocidad de su movimiento horizontal
const ACCELERATION := 900.0				# Aceleracion de sus movimientos horizontales
const FRICTION := 1000.0				# Friccion de sus zapatos

const COYOTE_TIME := 0.15				# Tiempo extra para saltar tras dejar el suelo
const JUMP_VELOCITY := -250.0			# Potencia del salto
const MAX_JUMP_TIME := 0.1				# Tiempo máximo para salto variable
const DOUBLE_JUMP_VELOCITY := -200.0	# El segundo salto sea inferior al primero
const JUMP_FORCE := -200.0				# Fuerza aplicada mientras mantienes la tecla de salto
const MAX_JUMPS := 2					# Número máximo de saltos (1 = normal, 2 = doble salto)

const DROP_THROUGH_HOLD_TIME := 0.05 	# Tiempo mínimo que debes mantener abajo para poder caer

# VARS
var jump_time := 0.0
var is_jumping := false					# Estas saltando?
var jump_count := 0						# Contador de saltos realizados
var coyote_timer := 0.0					# Contador para el salto coyote_timer
var down_hold_timer := 0.0				# Cuenta cuánto tiempo llevas apretando abajo

# FUNCTIONS
func _physics_process(delta: float) -> void: 
	# Actualiza timer para mantener abajo
	if Input.is_action_pressed("move_down"):
		down_hold_timer += delta
	else: 
		down_hold_timer = 0.0

	# Actualiza gravedad y coyote timer
	if not is_on_floor():
		velocity += get_gravity() * delta
		coyote_timer = max(coyote_timer - delta, 0.0)
	else:
		coyote_timer = COYOTE_TIME
		jump_count = 0  # Resetea el contador de saltos al tocar el suelo

	# Prioridad 1: Caer por plataforma si mantienes abajo un tiempo y saltas
	if down_hold_timer >= DROP_THROUGH_HOLD_TIME and Input.is_action_just_pressed("move_jump") and is_on_floor():
		drop_through()

	# Prioridad 2: Salto normal con coyote time (solo si no haces drop_through)
	elif Input.is_action_just_pressed("move_jump"):
		if coyote_timer > 0.0:
			# Primer salto desde el suelo con coyote time
			is_jumping = true
			jump_time = 0.0
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0.0
			jump_count = 1
		elif jump_count < MAX_JUMPS:
			# Doble salto en el aire
			is_jumping = true
			jump_time = 0.0
			velocity.y = DOUBLE_JUMP_VELOCITY
			jump_count += 1

	# Salto variable: mantener fuerza mientras mantienes tecla y no pasas tiempo max
	if is_jumping:
		jump_time += delta
		if Input.is_action_pressed("move_jump") and jump_time < MAX_JUMP_TIME:
			velocity.y += JUMP_FORCE * delta
		else:
			is_jumping = false
	# Salto dependiendo cuanto tiempo se presione la tecla "move_jump"
	if Input.is_action_just_released("move_jump") and velocity.y < 0:
		velocity.y *= 0.5  

	# Movimiento horizontal
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Mueve el cuerpo y procesa las colisiones
	move_and_slide()

	# Animaciones
	animations_sheet(direction)

	# Flip del sprite según dirección
	if velocity.x > 0:
		animation.flip_h = false
	elif velocity.x < 0:
		animation.flip_h = true

# Funcion para el maneja de animaciones
func animations_sheet(direction: float) -> void:
	if is_on_floor():
		if direction == 0:
			animation.play("idle")
		else:
			animation.play("run")
	else:
		if velocity.y < 0:
			animation.play("jump")
		elif velocity.y > 0:
			animation.play("fall")


# Funciona para atraveras plataformas y bajar por ellas
func drop_through() -> void:
	# Solo ejecuta si hay una plataforma debajo
	if is_on_floor():
		# Desactiva temporalmente la colisión con capa 1 para atravesar plataformas
		set_collision_mask_value(1, false)
		await get_tree().create_timer(0.2).timeout
		set_collision_mask_value(1, true)
