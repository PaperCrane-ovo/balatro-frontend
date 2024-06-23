extends Node2D

@onready var label:RichTextLabel = $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	var game_result = GameCore.game_state
	match game_result:
		"Lose":
			label.set_text("[font_size=100][center]你[color=red]输了——[/color][/center][/font_size]")
		"FinalWin":
			label.set_text("[font_size=100][center]你[color=green]过关 ![/color][/center][/font_size]")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
