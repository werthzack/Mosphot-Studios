extends CharacterBody3D

@export_group("Controller")
@export var speed: int = 6
@export var allow_jump: bool = true
@export var jump_gravity: int = 70
@export var fall_gravity: int = 90
@export var jump_velocity: int = 20

var direction

var mouse_pos

func _process(delta):
	
	#Applying movement function
	get_direction()
	
	#Calculating velocity
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	#Applying gravity using apply_gravity function
	apply_gravity(delta)
	
	# if Player uses jump button, call jump function
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#jump()
	
	#Applying velocity to movement
	move_and_slide()

# Use to apply Gravity
func apply_gravity(delta):
	
	if not is_on_floor(): # only apply gravity when player is on floor
		if velocity.y >= 0:
			velocity.y -= jump_gravity * delta
		else:
			velocity.y -= fall_gravity * delta
	else: # If trying to jump on floor and jump is allowed in editor
		if Input.is_action_just_pressed("jump") and allow_jump:
			velocity.y = jump_velocity

func get_direction():
	#Resetting direction every frame
	direction = Vector3.ZERO
	
	#Calclating direction
	if Input.is_action_pressed("forward"):
		direction.z -= 1
	if Input.is_action_pressed("backward"):
		direction.z += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	
	# Normalizing Direction
	direction = direction.normalized()
