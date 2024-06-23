extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	await SceneManager.scene_loaded
	SceneManager.get_entity("Select").button_down.connect(_on_button_down)


func _on_button_down():
	if not SceneManager.is_transitioning:
		SceneManager.change_scene(
			"res://scenes/select_level.tscn",{
				"pattern_enter": "fade",
				"pattern_leave": "circle",
			}
		)
