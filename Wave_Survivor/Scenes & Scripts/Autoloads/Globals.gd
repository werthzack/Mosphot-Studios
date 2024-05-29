# This autoload will handle the global variables
# like current time (wave/rest), player position, current_wave, etc.
# so that everyone(enemies, player, etc.) can access them in different scripts

extends Node

signal wave_cleared #This function is emitted from main.gd when clearing a wave (when the time changes to rest after a wave)
# wave_cleared signal is connected in different scripts (like gate.gd, melee_enemy.gd, main.gd, etc) to increase the difficulty by changing some parameters

signal make_gate_destructible #This function gets emitted whenever the gate is ready to be destroyed & It is connected in gate.gd script

signal add_bullet(bullet, position)

signal time_changed(current_time) #Lets the nodes know when a wave is started or ended
#time_changed signal is connected in main script so that it changes the gameplay state

var current_time: String = "rest": #Handles the current time(rest or wave)
	# Set function will emit time_changed signal whenever current_time is changed
	set(value):
		current_time = value
		time_changed.emit(current_time)


#Playing variable stores that if the player is playing or not, true when player is in game and false in pause_menu, home screen, etc.
var playing: bool = true  # used in player movement (if playing then only player can move)


var player_pos: Vector3 = Vector3.ZERO #Stores the position of player in real time for enemies to navigate to it

var player_dead: bool = false #Turns true when the player dies and lets everyone know that the player has died

var wave_no: int = 0 #Keeps inceasing by 1 at the start of each wave

var can_destroy_gate: bool = false: #Turns true when the player kills all the enemies and gate is ready to be destroyed
	set(value):
		if value == true:
			make_gate_destructible.emit()
		can_destroy_gate = value

var spawning_enemies: bool = false #Turns true when a gate is spawning enemies & false when it is not or it is done spawning
