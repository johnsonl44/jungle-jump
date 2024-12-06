extends Node2D

var _items: TileMapLayer = null
var _player: Node2D = null
var _spawn_point: Marker2D = null

func _ready() -> void:
	get_items().hide()
	get_player()
	

func get_items() -> TileMapLayer:
	if _items == null:
		if $Items:
			_items = $Items
		else:
			push_error("Node 'Items' not found")
	return _items

func get_player() -> Node2D:
	if _player == null:
		if $player:
			_player = $player
		else:
			push_error("Node 'player' not found")
	return _player

func get_spawn_point() -> Marker2D:
	if _spawn_point == null:
		if $SpawnPoint:
			_spawn_point = $SpawnPoint
		else:
			push_error("Node 'SpawnPoint' not found")
	return _spawn_point
