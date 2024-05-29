extends CharacterBody3D

#this signal is going to be emitted when the player gains/loses health
#This signal is connected in player_health_bar script to upgrade the health_bar value
signal health_changed()

@export_group("Controller")

#Change/Increase this variable when you have to change/upgrade max_health in game
@export var max_health: int = 100

@export var speed: int = 10
@export var allow_jump: bool = true
@export var jump_gravity: int = 70
@export var fall_gravity: int = 90
@export var jump_velocity: int = 20
@export var rotation_speed: float = 7

@onready var camera = get_tree().get_nodes_in_group("Camera")[0]

var direction

var current_health:int = 100:
	set(value):
		value = clamp(value, 0, max_health)
		if value == 0:
			Globals.playing = false
			Globals.player_dead = true
		elif value > current_health:
			current_health = value
		
		got_hit()
		current_health = value
		health_changed.emit()

var look_dir = Vector3(0, 1, -1)

var mouse_pos_2d
var mouse_pos_3d

func _process(delta):
	
	#Only apply movemen and look_at func when player is playing
	if Globals.playing:
		
		Globals.player_pos = global_position #Updating player position so enemies can access it
		
		look_at_mouse(delta)
		
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
	#direction = direction.rotated(Vector3.UP, camera.rotation.y)
	
	# Normalizing Direction
	direction = direction.normalized()

#This function makes the player look at mouse pointing direction
func look_at_mouse(delta):
	mouse_pos_2d = get_viewport().get_mouse_position()#Getting the mouse position in 2d space
	
	#Making a raycast from camera in mouse direction to check colliding surface
	var ray_length = 100
	var from = camera.project_ray_origin(mouse_pos_2d)
	var to = from + camera.project_ray_normal(mouse_pos_2d) * ray_length
	var space = get_world_3d().direct_space_state#Getting 3d space
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	
	#Get the intersection point of ray
	var result = space.intersect_ray(ray_query)
	
	mouse_pos_3d = result
	
	if result != {}: look_dir = Vector3(result.position.x, global_position.y, result.position.z)
	#else: look_dir.y = global_position.y
	
	#Look at result's direction
	var new_transform = transform.looking_at(look_dir, Vector3.UP)
	transform = transform.interpolate_with(new_transform, rotation_speed * delta)

#This function is called from set function of variable "current_health"
func got_hit():
	#Change the colour (Just for prototype and will be replaced with damage taking animations in actual game)
	$Body.mesh.material.albedo_color = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.3).timeout
	$Body.mesh.material.albedo_color = Color(0, 1, 1, 1)
	if current_health == 0:
		die()

#This function is called inside the got hit dunction when the current_health = 0
func die():
	#Just made a tween to make death animation. It will be replaced with actual animation after this
	var tween = owner.create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", Vector3(rotation_degrees.x+90, rotation_degrees.y, rotation_degrees.z), 0.2)
