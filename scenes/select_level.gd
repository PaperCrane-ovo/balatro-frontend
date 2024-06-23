extends Node2D

var color:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	await SceneManager.scene_loaded
	SceneManager.get_entity("Start").set_disabled(true)
	SceneManager.get_entity("Start").button_down.connect(_on_start_pressed)
	SceneManager.get_entity("Back").button_down.connect(_on_back_pressed)
	SceneManager.get_entity("Red").button_down.connect(_on_red_pressed)
	SceneManager.get_entity("Blue").button_down.connect(_on_blue_pressed)


func _on_start_pressed():
	# 场景切换 gamecore初始化
	GameCore.initialize()
	_for_color_to_change()
	SceneManager.change_scene(
		"res://scenes/player.tscn",{
			"pattern_enter":"fade",
			"pattern_leave":"circle",
		}
	)
	
	

func _for_color_to_change():
	match color:
		1:
			GameCore.max_discard_count+=1
			GameCore.discard_count += 1
		2:
			GameCore.max_play_hand_count+=1
			GameCore.play_hand_count += 1

func _on_back_pressed():
	if not SceneManager.is_transitioning:
		SceneManager.change_scene(
			"res://scenes/start_menu.tscn",
			{
				"pattern_enter": "fade",
				"pattern_leave": "circle",
			}
		)
func _on_red_pressed():
	SceneManager.get_entity("Start").set_disabled(false)
	color = 1

func _on_blue_pressed():
	SceneManager.get_entity("Start").set_disabled(false)
	color = 2
