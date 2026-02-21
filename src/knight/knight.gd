extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $Animation

# CONSTANTS
const SPEED := 150.0
const ACCELERATION := 900.0
const FRICTION := 1000.0

const COYOTE_TIME := 0.15
const JUMP_VELOCITY := -250.0
const MAX_JUMP_TIME := 0.1
const DOUBLE_JUMP_VELOCITY := -200.0
const JUMP_FORCE := -200.0
const MAX_JUMPS := 2

const DROP_THROUGH_HOLD_TIME := 0.05

# VARS
var jump_time := 0.0
var is_jumping := false
var jump_count := 0
var coyote_timer := 0.0
var down_hold_timer := 0.0


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
# INPUT TIMER (DOWN HOLD) - Tiempo para poder descender
# =====================================================
func handle_down_timer(delta: float) -> void:
	if Input.is_action_pressed("move_down"):
		down_hold_timer += delta
	else:
		down_hold_timer = 0.0


# =====================================================
# GRAVITY + COYOTE + RESET JUMPS
# =====================================================
func handle_gravity_and_coyote(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		coyote_timer = max(coyote_timer - delta, 0.0)
	else:
		coyote_timer = COYOTE_TIME
		jump_count = 0


# =====================================================
# JUMP
# =====================================================
func handle_jump_logic(delta: float) -> void:

	# Drop through priority
	if down_hold_timer >= DROP_THROUGH_HOLD_TIME \
	and Input.is_action_just_pressed("move_jump") \
	and is_on_floor():
		drop_through()
		return

	# Normal / Double jump
	if Input.is_action_just_pressed("move_jump"):

		if coyote_timer > 0.0:
			is_jumping = true
			jump_time = 0.0
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0.0
			jump_count = 1

		elif jump_count < MAX_JUMPS:
			is_jumping = true
			jump_time = 0.0
			velocity.y = DOUBLE_JUMP_VELOCITY
			jump_count += 1

	if is_jumping:
		jump_time += delta

		if Input.is_action_pressed("move_jump") and jump_time < MAX_JUMP_TIME:
			velocity.y += JUMP_FORCE * delta
		else:
			is_jumping = false

	# Salto dependiendo del tiemo que se presione el "move_jump"
	if Input.is_action_just_released("move_jump") and velocity.y < 0:
		velocity.y *= 0.5


# =====================================================
# HORIZONTAL MOVEMENT
# =====================================================
func handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


# =====================================================
# ANIMATION de KNIGHT
# =====================================================
func update_animation() -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	animations_sheet(direction)


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


# =====================================================
# FLIP de Animacion dependiendo donde mire su X
# =====================================================
func update_flip() -> void:
	if velocity.x > 0:
		animation.flip_h = false
	elif velocity.x < 0:
		animation.flip_h = true


# =====================================================
# DROP THROUGH - Atravesar objectos para descender  
# =====================================================
func drop_through() -> void:
	if is_on_floor():
		set_collision_mask_value(1, false)
		await get_tree().create_timer(0.2).timeout
		set_collision_mask_value(1, true)
