extends ProgressBar

@onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	#Set the max value of health_bar to the max_health of player at the start
	max_value = player.max_health
	value = player.current_health
	
	#connect the health_changed signal to update the health accordingly
	player.connect("health_changed", health_updated)

#This function upgrades the ui when the player upgrades
func health_updated():
	value = player.current_health
