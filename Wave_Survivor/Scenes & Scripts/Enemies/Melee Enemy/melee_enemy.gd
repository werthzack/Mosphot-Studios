extends CharacterBody3D

signal health_decreased #This will be connected in health bar of enemy

@export_group("Properties")
@export var speed = 400
@export var rotation_speed: float = 5
@export var attack_range: float = 2

@export var health: int = 20:
	#Whenever the health is changed, makes sure that the assigning health is between o & previous health
	set(value):
		#clamp the value between 0 & health then assign it back to health
		if value < 0: value = 0
		health = value
		health_decreased.emit()

@export var damage: int = 10

@onready var attack_timer = $AttackTimer
@onready var nav_agent = $NavigationAgent3D
@onready var hurt_timer = $HurtTimer # The time for which the enemy should stop after getting hurt

enum States {
	CHASE, #When enemy chases player
	ATTACK, #When enemy is in close range to player and attacks him
	HURT #When enemy gets a hit from the player and takes damage
}

var current_state = States.CHASE #Handles the state in which enemy currently is

func _ready():
	
	#Initialize tha target_position with zero vector
	nav_agent.target_position = Vector3.ZERO
	
	#Connect wave_cleared signal from global.gd to increase difficulty when wave is cleared
	Globals.connect("wave_cleared", increase_diff)

func _process(delta):
	
	#Enemy should only respond/behave to player when he is playing
	if Globals.playing:
		match current_state:
			
			States.ATTACK:
				#Check if the player is in range, if it is not, change the current state to chase
				if not player_in_range():
					current_state = States.CHASE
					attack_timer.stop()
					$AnimationPlayer.play("RESET")
					return
				
				#if attack timer is not started, start it (only for the first frsme of entering to attack state)
				if attack_timer.is_stopped() or attack_timer.paused:
					if attack_timer.paused: attack_timer.paused = false
					else: attack_timer.start()
					$AnimationPlayer.play("Attack")
				
			States.CHASE:
				
				#check_target_available(check_tgt_avb) function Checks if the target is available or not
				check_tgt_avb(delta)
				
				#Check if the player is in range, if it is, change the current state to attack
				if player_in_range():
					current_state = States.ATTACK
			
			States.HURT:
				
				# NOTE -> the health can't be less than 0 because it is clamped in set function of health
				
				if health > 0: # If the health > 0 after getting hurt
					if hurt_timer.is_stopped():
						get_hurt()
						hurt_timer.start()
				else: # If the health == 0 after getting hurt
					die()
		
	else:
		
		if Globals.player_dead: #If the player is dead, stop timer & animation
			$AnimationPlayer.stop()
			attack_timer.stop()
		
		elif current_state == States.ATTACK and not Globals.player_dead: #If not dead, then pause the timer & Animation to resume it again.
			attack_timer.paused = true
			$AnimationPlayer.pause()

# This function will update the target position for enemy
# with location of player in run-time every time the reaction_timer runs out
func _on_reaction_time_timeout():
	nav_agent.target_position = Globals.player_pos

#This function handles the direction & velocity calculation and moves the enemy to target
func move_to_target(delta, target):
	var direction = global_position.direction_to(target)
	direction = direction.normalized()
	velocity = direction * speed * delta
	move_and_slide()

#This function returns true if the player is in range and false if he isn't
func player_in_range():
	return global_position.distance_to(Globals.player_pos) <= attack_range

#check_tgt_avb (check_target_available) checks if the target position is defined or not
# if the target is available to be reached, it calls move_to_target function to reach target
func check_tgt_avb(delta):
	#if target is reached, return, else go to target
	if nav_agent.target_position == null:
		return
	
	else:
		var target = nav_agent.get_next_path_position()
		if global_transform.origin.is_equal_approx(target):
			return
		
		else:
			move_to_target(delta, target)
			var next_pos = nav_agent.get_next_path_position()
			
			if global_transform.origin.is_equal_approx(Vector3(next_pos.x, global_position.y, next_pos.z)):
				return
			
			#Making the enemy look_at the target_position smoothly
			var target_pos = Vector3(next_pos.x, global_position.y, next_pos.z)
			var new_transform = transform.looking_at(target_pos, Vector3.UP)
			transform = transform.interpolate_with(new_transform, rotation_speed * delta)

#This is called when attack timer runs out & timer is started in ATTACK state of process function 
func _on_attack_timer_timeout():
	hit_player() #Hit the player

#This function is used to hit the player & is called in attack timer's timeout
func hit_player():
	#Player is present in group "Player" so we can take its reference from there
	var player = get_tree().get_nodes_in_group("Player")[0]
	
	#Decrease the player health by damage amount which is export variable
	player.current_health -= damage

#This function damages the enemy & it is being called from bullet when the enemy enters detection area of bullet
func take_damage(damage_amt):
	
	#Decrese health by damage amount
	health -= damage_amt
	
	#Since the enemy got hit, set the current_state to States.HURT
	current_state = States.HURT

#This function will contain after effects of getting hurt like animations
func get_hurt():
	#Play hurt animations and sounds in this functions
	pass

#This function will have death animations, sounds, etc.
func die():
	#For now this will just have queue_free() function
	queue_free()

#Once the hurt_timer(timer for hurt cooldown) is finished, again go to chase state
func _on_hurt_timer_timeout():
	current_state = States.CHASE
	hurt_timer.stop()

#Called whenever the wave is cleared
func increase_diff():
	#Change parameters like speed, damage, health, etc. here of enemy to increase difficulty accordingly
	pass
