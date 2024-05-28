# This script will handle the map behaviour
# like changing gameplay state from rest to wave or from wave to rest

extends Node3D

@onready var wave_timer = $Timers/WaveTimer
@onready var rest_timer = $Timers/RestTimer
@onready var skip_button = $UI/MapUI/SkipButton

@onready var time_label = $UI/MapUI/TimeLabel #This label shows how much time is left in startng/ending of a wave

#get the spawn points(marker 2d) and gate scene
@onready var gate_marks = $GateSpawns.get_children()
@export var gate_scene: PackedScene #This will have scene of gate in the editor

var spawn_points: Array = [] #array of positions of all spwant points(filled in ready function)
var gate

func _ready():
	#Connect time changed function from global to local script
	Globals.connect("time_changed", change_time)
	
	#Hide the skip button at the start of a game
	skip_button.hide()

func _on_wave_timer_timeout(): #starts when wave starts and ends when wave should end
	Globals.current_time = "rest"

func _on_rest_timer_timeout():#starts when wave ends and ends when wave should start
	Globals.current_time = "wave"

# This function will be called whenever the current time is changed
# This will handle the starting or ending of wave
# It takes a current_time argument which will be current_time variable from global script and will be sent with signal
func change_time(current_time):
	match Globals.current_time:
		#if current_time is rest, start rest timer which sets the current_time to wave after timeout
		"rest":
			rest_timer.start()
			end_wave()
		
		#if current_time is wave, then start wave timer
		"wave":
			wave_timer.start()
			start_wave()


func _process(_delta):
	#Change time_label text according to current_time
	match Globals.current_time:
		"rest":
			time_label.text = "Wave Starts in: " + str(int(rest_timer.time_left)) + " sec"
			
			#Show the skip button if rest_time is elapsed by 10 sec > 10
			if (rest_timer.wait_time - rest_timer.time_left) >= 10:
				skip_button.show()
			
		"wave":
			time_label.text = "Wave Ends in: " + str(int(wave_timer.time_left)) + " sec"
			#Hide skip button iwhen wave starts
			skip_button.hide()

#Use when wave has to start
func start_wave():
	spawn_gate()

#Use when have to spawn the gates (in start of wave)
func spawn_gate():
	gate = gate_scene.instantiate()
	var rd_idx = randi_range(0, len(gate_marks) - 1) #Get a random integer named rd_idx(random_index)
	var rnd_mark = gate_marks[rd_idx] #Use rd_idx to get random node/marker from the array "gate_marks"
	
	# Set the position & rotation of random marker to Gate's position & rotation
	gate.position = rnd_mark.global_position
	gate.rotation = rnd_mark.rotation
	
	#Add child to gate container
	$GateContainer.add_child(gate)

# uses when ending a wave
func end_wave():
	destroy_gate()

# Used when destroying gate(s) after a wave
func destroy_gate():
	for gate in $GateContainer.get_children():
		gate.queue_free()


# Called when skip button is pressed
func _on_skip_button_button_down():
	# get the rest time and store it
	var rest_time = rest_timer.wait_time
	
	#Set the wait_time to 1 (Just about to end) & restart te timer
	rest_timer.wait_time = 1
	rest_timer.start()
	
	#Reset the wait_time to original value
	rest_timer.wait_time = rest_time
