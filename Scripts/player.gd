extends CharacterBody2D

@export var hspeed = 150 #horizontal speed
@export var vspeed = 150 #vertical speed
@export var dashspeed = 300 #dash speed

var accel_t = 0.0 #acceleration time
var decel_t = 0.0 #deceleration time
var accel_friction = 16
var decel_friction = 0.9 #speed of deceleration

var health = 100
var dashing = false
var player_dead = false

var target_velocity = Vector2.ZERO #target velocity
var input = Vector2.ZERO #input

var debug = false

signal dead

func _ready():
	pass
	#$Area2D/CollisionShape2D.disabled = false
	#$AnimatedSprite2D.animation = "default" #initially set animation to default

func get_input():
	#if not dashing:
	input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input.length_squared() > 1:
		input = input.normalized()

	if Input.is_action_just_pressed("dash"):
		if input.x != 0:
			if input.y != 0: #diagonal dash.
				target_velocity = input * dashspeed/1.3
			else: #horizontal dash.
				target_velocity = input * dashspeed
		elif input.y != 0: #vertical dash.
			target_velocity = input * dashspeed
		else:
		#dash left if no input and facing left
			if $Sprite2D.flip_h:
				target_velocity = Vector2(-1, 0) * dashspeed
			else:
			#dash right if no input and facing right
				target_velocity = Vector2(1, 0) * dashspeed
		dash()
	
	#determine target velocity
	elif not dashing and input.x != 0: #normal movement horizontal
		target_velocity = input * hspeed
	elif not dashing and input.y != 0: #normal movement vertical
		target_velocity = input * vspeed
		
	#$CPUParticles2D.direction.x = 50 * input.x * -1
	
	#DEBUG
	if Input.is_action_just_pressed("debug"):
		debug = !debug
		if debug:
			$CollisionShape2D.disabled = true
		else:
			$CollisionShape2D.disabled = false

func _physics_process(delta):
		
	if not player_dead:
		#update time
		accel_t += delta * accel_friction
		accel_t = accel_t * accel_t
		accel_t = clamp(accel_t, 0, 1) #need to clamp if accel_fric is high
		decel_t += delta * decel_friction
		decel_t = clamp(decel_t, 0, 1)
		
		#flip sprite
		if velocity.x != 0:
			$Sprite2D.flip_h = velocity.x < 0
			
		if not dashing:
			move_and_collide(Vector2(0, 0))
		
		get_input()
		calc_movement()
		move_and_slide()
	
func calc_movement():
	#if not dashing:
	if input != Vector2.ZERO or dashing: #if input != 0, interpolate to speed
		decel_t = 0 #reset decel time
		velocity = velocity.lerp(target_velocity, accel_t)
		if (velocity - target_velocity).length_squared() < 1 * 1:
			accel_t = 0

	elif input == Vector2.ZERO: #if input = 0, interpolate to 0
		accel_t = 0 #reset accel time
		velocity = velocity.lerp(Vector2.ZERO, decel_t)
		if (velocity - Vector2.ZERO).length_squared() < 1 * 1:
			decel_t = 0
			
	if input != Vector2.ZERO and not dashing:
		#Walking animation
		pass
		#$AnimatedSprite2D.animation = "swim"
		#$AnimatedSprite2D.play()
	if input == Vector2.ZERO:
		#Idle animation
		pass
		#$AnimatedSprite2D.animation = "default"

func dash():
	dashing = true
	#$CPUParticles2D.emitting = true
	#$AnimatedSprite2D.animation = "dash"
	#$DashSound.play()
	$DashTimer.start()

func _on_dash_timer_timeout():
	dashing = false

func _on_area_2d_area_entered(area):
	#print(area)
	pass
