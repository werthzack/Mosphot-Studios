extends CharacterBody3D

@export_group("Controller")
@export var speed: int = 10
@export var allow_jump: bool = true
@export var jump_gravity: int = 70
@export var fall_gravity: int = 90
@export var jump_velocity: int = 20

@onready var camera = get_tree().get_nodes_in_group("Camera")[0]

var direction

var look_dir = Vector3(0, 1, -1)

var mouse_pos

func _process(delta):
	
	look_at_mouse()
	
	#Applying movement function
	get_direction()
	
	#Calculating velocity
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	#Applying gravity using apply_gravity function
	apply_gravity(delta)
	
	#Applying velocity to movement
	move_and_slide()
	
	camera.global_position = Vector3(global_position.x+15, global_position.y+15, global_position.z+15)

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
	
	direction.z += Input.get_axis("forward", "backward")
	direction.x += Input.get_axis("left", "right")
	
	#Rotating direction respective to camera
	direction = direction.rotated(Vector3.UP, camera.rotation.y)
	
	# Normalizing Direction
	direction = direction.normalized()

#This function makes the player look at mouse pointing direction
func look_at_mouse():
	mouse_pos = get_viewport().get_mouse_position()#Getting the mouse position in 2d space
	
	#Making a raycast from camera in mouse direction to check colliding surface
	var ray_length = 100
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state#Getting 3d space
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	
	#Get the intersection point of ray
	var result = space.intersect_ray(ray_query)
	if result != {}: look_dir = Vector3(result.position.x, global_position.y, result.position.z)
	else: look_dir.y = global_position.y
	
	#Looj at result's direction
	look_at(look_dir)
