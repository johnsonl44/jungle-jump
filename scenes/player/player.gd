extends CharacterBody2D

@export var gravity: float = 750
@export var run_speed: float = 150
@export var jump_speed: float = -300

@export var life: int =5:
	set(value):
		life = value
		life_changed.emit(life)
		if life<=0:
			if $DeathTimer.is_stopped():
				$AnimationPlayer.play("hurt")
				$dead.play()
				$DeathTimer.start()
				print("TIME STARt")

signal life_changed(life: int)
signal died

enum {IDLE,RUN,JUMP,HURT,DEAD}
var state:int = IDLE
@export var invincibility_duration: float = 1.0
var is_invincible: bool = false


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	get_input()
	
	move_and_slide()
	if state == JUMP and is_on_floor() and life!=0:
		change_state(IDLE)
	if state == HURT and is_on_floor() and life!=0:
		change_state(IDLE)
	if state == HURT:
		return
	for i in range(get_slide_collision_count()): 
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider.is_in_group("danger"):
			hurt()
		if collider.is_in_group("enemies"):
			
			if position.y<collider.position.y:
				collider.take_damage()
				velocity.y = -200
			else:
				hurt()
		if collider.is_in_group("player death"):
			fall_death()

func _ready() -> void:
	change_state(IDLE)

func fall_death():
	life=0

func change_state(new_state: int) -> void:
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		RUN:
			$AnimationPlayer.play("run")
		HURT:
			$AnimationPlayer.play("hurt")
			if not $hurt.playing:
				$hurt.play()
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
		JUMP:
			$AnimationPlayer.play("jump_up")
		DEAD:
			died.emit() 
			hide()

func get_input() -> void:
	if state == HURT or life==0:
		return
	var right: bool = Input.is_action_pressed("right")
	var left: bool = Input.is_action_pressed("left")
	var jump: bool = Input.is_action_pressed("jump")
	
	velocity.x=0
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	
	if left:
		velocity.x -=run_speed
		$Sprite2D.flip_h=true
	
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
	
	if state==IDLE and velocity.x !=0 and life!=0:
		change_state(RUN)
	
	if state == RUN and velocity.x == 0 and life!=0:
		change_state(IDLE)
	
	if state in [IDLE,RUN] and !is_on_floor() and life!=0:
		change_state(JUMP)
	
	if state == JUMP and velocity.y>0 and life!=0:
		$AnimationPlayer.play("jump_down")

func hurt() -> void:
	if is_invincible or life <= 0:  # Prevent taking damage if invincible or dead
		return
	is_invincible = true
	$InvincibilityTimer.start()  # Start the invincibility timer
	change_state(HURT)
	life -= 1



func reset(_position: Vector2) -> void:
	position = _position
	show()
	change_state(IDLE)
	life = 0


func _on_death_timer_timeout() -> void:
	print("DEAD TIMER")
	change_state(DEAD)


func _on_invincibility_timer_timeout() -> void:
	is_invincible=false
