extends CharacterBody3D

#All the enemies must be in the "Enemies" group for the bullet to work

@export var speed: int = 200

var damage: int #Damage of bullet is set from the pistol/any other gun
var direction: Vector3 = Vector3.ZERO

func _ready():
	#Make the bullet look in the direction which is set while instantiating it
	look_at(direction)

func _process(_delta):
	velocity = direction * speed
	move_and_slide()

#If the timer times out (i.e. the body doesn't collide), free the bullet
func _on_life_time_timeout():
	queue_free()

#If the bullet detects something in detection area (very near to the bullet)
#That means the bullet has hit some body (parameter in the body entered function)
func _on_detection_area_body_entered(body):
	#if the body is part of enemies group (body is enemy), damage it.
	if body.is_in_group("Enemies"):
		#Make sure all the enemies have "take_damage()" function in their script
		body.take_damage(damage)
	
	#if the body is in group "Gates" then gate should take damage
	if body.is_in_group("Gates"):
		body.take_damage(damage)
	
	#The bullet has to be freed even if the colliding body is enemy or level
	queue_free()
