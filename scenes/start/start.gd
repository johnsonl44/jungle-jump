extends Control

func _ready() -> void:
	$Intro.play()

func _input(event):
	if event.is_action_pressed("ui_select"):
		$Intro.stop()
		GameState.next_level()
