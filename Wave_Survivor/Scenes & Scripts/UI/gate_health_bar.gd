extends ProgressBar

#Get the parent gate of this health bar
@onready var gate = get_parent().get_parent()

func _ready():
	#Set the max value of health_bar to the durability of gate at start
	max_value = gate.durability
	value = gate.durability
	
	#connect the durability_decreased signal to update the health bar
	gate.connect("durability_decreased", durability_updated)

#This function upgrades the gate_health_bar when the gate gets damaged
func durability_updated():
	value = gate.durability
