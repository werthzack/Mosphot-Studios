extends ProgressBar

#Get the parent gate of this health bar
@onready var parent_enemy = get_parent().get_parent()

func _ready():
	#Set the max value of health_bar to the durability of gate at start
	max_value = parent_enemy.health
	value = parent_enemy.health
	
	#connect the durability_decreased signal to update the health bar
	parent_enemy.connect("health_decreased", health_updated)

#This function upgrades the gate_health_bar when the gate gets damaged
func health_updated():
	value = parent_enemy.health
