extends Node3D

#----------Gun Stats------------------------------------------
@export_group("Gun Stats")

@export var bullet_scene: PackedScene

@export var rot_speed: float = 5

@export var damage: int = 10 #It is the Damage that the weapon does
@export var fire_rate: float = 2: #It is fire rate of weapon (bullets per second)
	set(value):
		#Whenever the fire rate is changed, updating the wait time
		fire_rate = value
		cooldown_timer.wait_time = 1/fire_rate

#Don't change the wait time of cooldown_timer(It won't change anything). instead change the fire rate

#-------------------------------------------------------------

@onready var cooldown_timer = $CooldownTimer
@onready var player = get_tree().get_nodes_in_group("Player")[0]

var bullet

func _ready():
	
	#Set the cooldown timer to the time taken for 1 bullet (1/fire_rate)
	cooldown_timer.wait_time = 1/fire_rate

func _process(_delta):
	
	#--------------------Check if shoot is pressed--------------------
	if Input.is_action_pressed("shoot"):
		#Shoot if action "shoot" is pressed & cooldown timer is not running
		if cooldown_timer.is_stopped():
			shoot()
			#This timer runs till the cooldown time dependent on fire_rate
			cooldown_timer.start()
	#-----------------------------------------------------------------
	
	#Making the gun look_at the position where player is looking smoothly
	var target = player.mouse_pos_3d
	if target != {}:
		look_at(Vector3(target.position.x, global_position.y, target.position.z), Vector3.UP)

#This function is called whenever the player has to shoot the bullet
func shoot():
	
	# Tell the main scene (world) to add a bullet in it
	# By emitting the add_bullet signal from globals autoload
	# add_bullet is connected in main.gd to spawn the bullet
	
	# instantiate the bullet_scene
	bullet = bullet_scene.instantiate()
	
	# set the direction variable of bullet script to the direction where gun is pointing
	bullet.direction = -global_transform.basis.z
	bullet.damage = damage
	
	Globals.add_bullet.emit(bullet, $BulletSpawnPoint.global_position)

