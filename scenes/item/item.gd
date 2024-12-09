extends Area2D

signal picked_up

var textures: Dictionary ={
	"cherry":
		"res://assets/sprites/cherry.png",
	"gem":
		"res://assets/sprites/gem.png",
	"door":#FIX THIS LATER !!!!!!!!!!!!!!!!!!!!!!!!!
		"res://assets/sprites/gem.png"
}

func init(item_type:String,_position:Vector2) ->void:
	$Sprite2D.texture = load(textures[item_type]) as Texture
	position = _position


func _on_body_entered(body: Node2D) -> void:
	picked_up.emit()
	queue_free()
