extends CharacterBody2D

@export var speed: float = 50
@export var gravity: float = 900

var facing =1

func _physics_process(delta: float) -> void:
	velocity.y += gravity *delta
	
	velocity.x = facing*speed
	
	$Sprite2D.flip_h = velocity.x>0
	
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Node = collision.get_collider() as Node
		if collider.name == "player":
			
			collider.hurt()
		
		if collision.get_normal().x !=0:
			facing = sign(collision.get_normal().x)
			velocity.y = -100
			
	if position.y > 100000:
		queue_free()
	

func take_damage():
	$Sprite2D.hide()
	$DeathSprite.show()
	$Death.play("death")
	$CollisionShape2D.set_deferred("disabled",true)
	$DeathSound.play()
	set_physics_process(false)

func _on_death_animation_finished(anim_name: StringName) -> void:
	queue_free()
