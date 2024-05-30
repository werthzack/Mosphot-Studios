# This script will handle the map behaviour
# like changing gameplay state from rest to wave or from wave to rest

extends Node3D

#---------ENEMY DATA---------------------------------
@export_group("Enemy Data")

#Add enemy scenes in this subgroup
@export_subgroup("Enemy Scenes")
@export var melee_scene: PackedScene
#Add more scenes with enemies:
#Example -> @export var shooting_scene: PackedScene -> for shooting enemy

#Add number of each enemies to be spawned from this gate
@export_subgroup("Number of Enemies")
@export var num_melee: int = 10
#Add more variables with more enemies
#Example -> @export var num_shoot: int = 3 -> for shooting enemies
#--------------------------------------------------------

#-----------Gate Data----------------------------------------
@export_group("Gate Data")
@export var no_of_gates: int = 1 #The value of this value should not exeed the no. of spawn markers
@export var gate_scene: PackedScene #This will have scene of gate in the editor
#-----------------------------------------------------------


@onready var rest_timer = $Timers/RestTimer
@onready var skip_button = $UI/MapUI/SkipButton
@onready var pause_menu = $PauseMenu

@onready var time_label = $UI/MapUI/TimeLabel #This label shows how much time is left in startng/ending of a wave

#get the spawn points(marker 2d) and gate scene
@onready var gate_marks = $GateSpawns.get_children()



var spawn_points: Array = [] #array of positions of all spwant points(filled in ready function)
var gate

func _ready():
	
	#Connect time changed function from global.gd to this script
	Globals.connect("time_changed", change_time)
	
	#Connect the add_bullet function from global.gd to know when to add bullet in scene
	Globals.connect("add_bullet", add_bullet)
	
	#Connect wave_cleared signal from global.gd to increase difficulty when wave is cleared
	Globals.connect("wave_cleared", increase_diff)
	
	#Hide the skip button at the start of a game
	skip_button.hide()
	
	#Hide PauseMenu
	pause_menu.hide()

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
			Globals.wave_no += 1
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
			
			#If spawning enemies is done in wave time check
			if not Globals.spawning_enemies:
				
				# whether there are no enemies in group "Enemies" (All enemies are defeated), make the gate destructible
				if get_tree().get_nodes_in_group("Enemies") == []:
					Globals.make_gate_destructible.emit()
			
				#or all the gate(s) are destroyed (nodes in group Gates = []) then wave stops
				if get_tree().get_nodes_in_group("Gates") == []:
					Globals.current_time = "rest"
					Globals.wave_cleared.emit()
				
#Use when wave has to start
func start_wave():
	spawn_gate()
	
	#Show the current wave_no at the start of the wave
	time_label.text = "Wave: " + str(Globals.wave_no)
	
	#Hide skip button when wave starts
	skip_button.hide()

#Use when have to spawn the gates (in start of wave)
func spawn_gate():
	
	# repeat gate_spawning entill it reaches the no_of_gates (export variable)
	for i in range(0, no_of_gates):
		gate = gate_scene.instantiate()
		
		#Get random spawn marker
		var rd_idx = randi_range(0, len(gate_marks) - 1) #Get a random integer named rd_idx(random_index)
		var rnd_mark = gate_marks[rd_idx] #Use rd_idx to get random node/marker from the array "gate_marks"
	
		# Set the position & rotation of Gate marker to random marker's position & rotation
		gate.position = rnd_mark.global_position
		gate.rotation = rnd_mark.rotation
		
		#Remove the marker from array so that the same marker can't be selected in further iteration
		gate_marks.remove_at(rd_idx)
		
		gate.num_of_melee = num_melee #Set the num of melee enemies for gates to num_melee export variable
	
		#Add child to gate container
		$GateContainer.add_child(gate)
		
		#Set the sprite to unique
		
		

# uses when ending a wave
func end_wave():
	destroy_gate()

# Used when destroying gate(s) after a wave
func destroy_gate():
	for i in $GateContainer.get_children():
		i.queue_free()
	
	#Reset the markers in array so that all of them will be avalable for selection
	gate_marks = $GateSpawns.get_children()


# Called when skip button is pressed
func _on_skip_button_button_down():
	# get the rest time and store it
	var rest_time = rest_timer.wait_time
	
	#Set the wait_time to 1 (Just about to end) & restart te timer
	rest_timer.wait_time = 1
	rest_timer.start()
	
	#Reset the wait_time to original value
	rest_timer.wait_time = rest_time

func _input(_event):
	
	# Player can only access the pause menu only if he is not dead
	if not Globals.player_dead:
		if Input.is_action_just_pressed("ui_cancel"): #ui_cancel = esc key, if playing set to not playing and viceversa
			match Globals.playing:
				true: Globals.playing = false
				false: Globals.playing = true
			
			#now pause or play the game based on playing variable
			pause_play_game()

#Use when game has to be paused or has to be played
func pause_play_game():
	
	#Show/Hide the pause_menu based in playing variable of Globals scipt
	pause_menu.visible = not Globals.playing
	
	#If current time is rest then play/pause the rest_timer
	#and if it is wave then pause/play wave_timer
	match Globals.current_time:
		"rest": rest_timer.paused = not Globals.playing
		"wave": pass

func add_bullet(bullet, pos):
	
	$BulletContainer.add_child(bullet)
	bullet.global_position = pos

#This function is used to increase the difficulty of the game
func increase_diff():
	#You can change many values to increase the difficulty in each wave
	#By changing the number of melee & other enemy types, by changing the no of gates, etc.
	
	num_melee += 1
