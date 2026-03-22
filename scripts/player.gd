extends CharacterBody2D

const SPEED    = 300.0
const JUMP_VEL = -600.0
const GRAVITY  = 1200.0

func _physics_process(delta):
	# Gravedad
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Salto
	# Jump
	if Input.is_action_just_pressed("Up") and is_on_floor():
		velocity.y = JUMP_VEL

	# Movimiento horizontal
	# Horizontal movement
	var dir = Input.get_axis("Left", "Right")
	velocity.x = dir * SPEED

	move_and_slide()
