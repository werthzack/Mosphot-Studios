extends StaticBody3D

signal durability_decreased #Emitted when durability of gate is decreased

@export var melee_scene: PackedScene
#Add more enemy scenes if enemies are of more type

@export var spawn_cooldown: float = 0.5

@export var durability: int = 30: #This is just health but for the gate
	set(value):
		if value < 0: value = 0
		durability = value
		durability_decreased.emit()
		if durability == 0:
			destroyed()

#The following variables are set when instantiating the gate from main.gd script
var num_of_melee: int #Stores num of melee enemies to be spawned
#var num_of_shooting: int (In case shooting enemies are there) Add more variables with enemies

@onready var enemy_container = get_tree().get_first_node_in_group("EnemyContainer") # Enemy container from main.tscn is added in EnemyContainer group

var enemies_spawned: int = 0

func _ready():
	
	#Connect wave_cleared signal from global.gd to increase difficulty when wave is cleared
	Globals.connect("wave_cleared", increase_diff)
	
	#At start, gate should not be destroyable
	Globals.can_destroy_gate = false
	
	#Connect the make_gate_destructible signal in the script
	Globals.connect("make_gate_destructible", ready_for_destruction)
	
	#Starts spawning enemies
	Globals.spawning_enemies = true
	
	#Spawn the melee enemy untill num_of_melee
	for enemy in range(0, num_of_melee):
		
		var melee_enemy = melee_scene.instantiate()
		
		enemy_container.add_child(melee_enemy)
		
		#Set the position of enemy to the position of gate
		melee_enemy.global_position = global_position
		melee_enemy.global_rotation = global_rotation
		
		#Await for spawn_cooldown time before next iteration
		await get_tree().create_timer(spawn_cooldown).timeout
	
	#----Place Code for spawning of other enemies in following area----
	
	#------------------------------------------------------------------
	
	#After the enemy spawning, set spawning enemies to false since ,gate isn't spawning enemies any more
	Globals.spawning_enemies = false
	
	
	
#This function makes the gate to be destroyable for the player
func ready_for_destruction():
	
	#NOTE -> When you add the mesh to the gate, don't make it completely closed
	#And keep its collision shape/poygon disabled untill it is ready to be destroyed in this function
	
	$CollisionShape3D.disabled = false

func take_damage(damage):
	durability -= damage

func destroyed():
	#Here you can play destruction animation & sounds for the gate/helicopter before removing it from tree
	queue_free()

#Called whenever the wave is cleared
func increase_diff():
	#Change parameters like speed, damage, health, etc. here of enemy to increase difficulty accordingly
	pass
