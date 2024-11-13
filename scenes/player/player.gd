extends CharacterBody2D

@export var gravity: float = 750
@export var run_speed: float = 150
@export var jump_speed: float = -300

@export var life: int =3:
	set(value):
		life = value
		life_changed.emit(life)
		if life<=0:
			change_state(DEAD)

signal life_changed(life: int)
signal died

enum {IDLE,RUN,JUMP,HURT,DEAD}
var state:int = IDLE

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	get_input()
	
	move_and_slide()
	if state == JUMP and is_on_floor():
		change_state(IDLE)

func _ready() -> void:
	change_state(IDLE)

func change_state(new_state: int) -> void:
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		RUN:
			$AnimationPlayer.play("run")
		HURT:
			$AnimationPlayer.play("hurt")
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
		JUMP:
			$AnimationPlayer.play("jump_up")
		DEAD:
			hide()

func get_input() -> void:
	if state == HURT:
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
	
	if state==IDLE and velocity.x !=0:
		change_state(RUN)
	
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
	
	if state in [IDLE,RUN] and !is_on_floor():
		change_state(JUMP)
	
	if state == JUMP and velocity.y>0:
		$AnimationPlayer.play("jump_down")

func hurt() -> void:
	if state != HURT:
		change_state(HURT)

func reset(_position: Vector2) -> void:
	position = _position
	show()
	change_state(IDLE)
	life = 0
