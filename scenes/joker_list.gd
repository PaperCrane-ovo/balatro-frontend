extends Node2D

var selected_joker:JokerSprite = null
var joker_script = preload("res://scenes/joker.gd")
@onready var list:ColorRect = $小丑列表

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sold.set_visible(false)
	$"数量".set_text("%d/%d" % [GameCore.get_joker_list().size(), GameCore.joker_list_limit])

func _input(event):
	if selected_joker == null:
		return
	var offset = 0
	var pressed = false
	if event.is_action_pressed("ui_left"):
		offset = -1
		pressed = true
	elif event.is_action_pressed("ui_right"):
		offset = 1
		pressed = true
	if pressed:
		print("pressed dir key")
		var index = GameCore.swap_joker(selected_joker,offset)
		if index != -1:
			list.move_child(selected_joker,index)
			_set_joker_pos(list.get_children(),list.get_rect())

func _select_joker(joker:JokerSprite):
	if selected_joker == joker:
		joker.set_scale(Vector2(1.0,1.0))
		selected_joker = null
		$Sold.set_visible(false)
		get_parent().update_joker_description(null)
	else:
		if selected_joker != null:
			selected_joker.set_scale(Vector2(1.0,1.0))
		selected_joker = joker
		joker.set_scale(Vector2(1.5,1.5))
		$Sold.set_visible(true)
		get_parent().update_joker_description(joker.get_display_info())
		
func _joker_added():
	var jokers = GameCore.get_joker_list()
	for i in range(jokers.size()):
		if jokers[i].is_inside_tree():
			continue
		else:
			var joker = jokers[i]
			joker.set_script(joker_script)
			list.add_child(joker)
			list.move_child(joker,i)
			if not joker.joker_clicked.is_connected(_select_joker):
				joker.joker_clicked.connect(_select_joker)
	_set_joker_pos(list.get_children(),list.get_rect())
	$"数量".set_text("%d/%d" % [jokers.size(), GameCore.joker_list_limit])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _set_joker_pos(nodes:Array[Node],rect:Rect2):
	var size = rect.size

	var gap = size.x/(nodes.size()+1)
	var x = rect.position.x
	var y = rect.get_center().y
	var i = 1
	for node in nodes:
		node.set_global_position(to_global(Vector2(i*gap+x,y)))
		i+=1

func _on_sold_pressed():
	list.remove_child(selected_joker)
	GameCore.pop_joker(selected_joker)
	_set_joker_pos(list.get_children(),list.get_rect())
	selected_joker = null
	$Sold.set_visible(false)
	get_parent().update_joker_description(null)
	
	
