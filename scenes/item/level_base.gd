extends Node2D

var _items: TileMapLayer = null
var _world: TileMapLayer = null
var _player: Node2D = null
var _spawn_point: Marker2D = null
var _camera_2d: Camera2D = null

# Signal definition
signal score_changed

# Scene resource
var item_scene: PackedScene = load("res://scenes/item/item.tscn")
var door_scene = load("res://scenes/item/door.tscn")
# Score with setter
var score: int: set = set_score

func _ready() -> void:
	get_items().hide()
	get_player()
	set_camera_limits() 
	spawn_items()
	start_music()

func start_music():
	print("MUSIC")
	$LevelMusic.play()


func set_camera_limits() -> void:
	# Sets the camera limits based on the world tilemap's size and tile size
	var map_size: Rect2 = get_world().get_used_rect()
	var cell_size: Vector2 = get_world().tile_set.tile_size

	# Set camera limits based on the tilemap dimensions
	get_camera_2d().limit_left = int((map_size.position.x - 5) * cell_size.x)
	get_camera_2d().limit_right = int((map_size.end.x + 5) * cell_size.x * 1.5)


# Spawns items based on the TileMapLayer's used cells
func spawn_items() -> void:
	
	# Use the lazy-initialized getter for Items
	var item_cells: Array[Vector2i] = get_items().get_used_cells()
	
	for cell in item_cells:
		var data: TileData = get_items().get_cell_tile_data(cell)
		var type: String = data.get_custom_data("type")  # Assuming "type" is stored as String
		if type =="door":
			print("DOOR")
			var door = door_scene.instantiate()
			add_child(door)
			door.position = get_items().map_to_local(cell)
			door.body_entered.connect(_on_door_entered)
		else:
			var item: Node = item_scene.instantiate()
			add_child(item)
			item.init(type, get_items().map_to_local(cell))
			item.picked_up.connect(self._on_item_picked_up)

func _on_door_entered(body):
	$LevelMusic.stop()
	GameState.next_level()

# Handles item pickup and increments score
func _on_item_picked_up(item:String) -> void:
	if item == "cherry":
		var player = get_player()
		if player.life < 5:  # Assuming the player script has a health variable
			player.life += 1
			$LifeUp.play()
			player.life_changed.emit(player.life)
	if item == "gem":
		score += 1

# Sets the score and emits the signal
func set_score(value: int) -> void:
	score = value
	score_changed.emit(score)

func get_camera_2d() -> Camera2D:
	if _camera_2d == null:
		var player = get_player()
		if player.has_node("Camera2D"):
			_camera_2d = player.get_node("Camera2D") as Camera2D
		else:
			push_error("Node 'Camera2D' not found as a child of player")
	return _camera_2d


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

func get_world() -> TileMapLayer:
	if _world == null:
		if $World:
			_world = $World
		else:
			push_error("Node 'World' not found")
	return _world
	
func _on_player_died():
	$LevelMusic.stop()
	GameState.restart()
