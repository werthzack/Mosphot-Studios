extends Camera3D

# Used Ray to detect where the mouse should point in 3d space


var ray_origin = Vector3() #Origin or ray (Camera Position)
var ray_target = Vector3() #Target of ray (mouse position)

var look_pos = Vector3(0, 0, -1) #Position/Direction for player to look in (initialized by negative z axis)
var player_pos = Vector3() #Gives real-time position of player
var mouse_position = Vector3() #Stores the position of mouse on screen (Vector2)

var cam_pos = Vector3.ZERO #Stores the position where the camera should go in next frame (because of player movement)

@onready var player = $"../Player" #Player node

func _physics_process(_delta):
	
	#get the mouse position on viewport (in 2d space)
	mouse_position = get_viewport().get_mouse_position()
	
	player_pos = player.global_position #Get the current player position
	
	cam_pos = Vector3(player_pos.x, player_pos.y+5, player_pos.z+15) #New position of camera to follow player
	position = cam_pos
	
	var drop_plane = Plane(Vector3(0, 1, 0), player_pos.y)
	var ray_length = 10000 #The length of ray
	
	#Start & end the ray and check the collision point
	ray_origin = project_ray_origin(mouse_position)
	ray_target = ray_origin + project_local_ray_normal(mouse_position) * ray_length
	var intersection = drop_plane.intersects_ray(ray_origin, ray_target)
	
	#If ray is intersecting, look in the direction of intersection point
	if intersection != null:
		look_pos = intersection + Vector3(0, 1, 0)
		player.look_at(Vector3(look_pos.x, player.global_position.y, look_pos.z))
