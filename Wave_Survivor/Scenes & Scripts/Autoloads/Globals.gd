# This autoload will handle the global variables
# like current time (wave/rest), player position, current_wave, etc.
# so that everyone(enemies, player, etc.) can access them in different scripts

extends Node

signal time_changed(current_time) #Lets the nodes know when a wave is started or ended
#time_changed signal is connected in main script so that it changes the gameplay state

var current_time: String = "rest": #Handles the current time(rest or wave)
	
	# Set function will emit time_changed signal whenever current_time is changed
	set(value):
		current_time = value
		time_changed.emit(current_time)
