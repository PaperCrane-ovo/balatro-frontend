extends Node2D

var gold:int
signal clicked

var exit_from_player:bool
var exit_from_player_time:float

var award_list:Array[JokerSprite]
var award_index:Array[int]

@onready var slot:ColorRect = $JokerSlot
@onready var discription:RichTextLabel = $Discription
@onready var room:RichTextLabel = $text

var joker_script = preload("res://scenes/joker.gd")

var selected_joker:JokerSprite = null

# Called when the node enters the scene tree for the first time.
func _ready():

	room.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
	room.push_color(Color("red"))
	room.push_font_size(30)
	room.append_text("选择你的小丑牌")
	room.pop_all()
	
	var drop_number = 3;
	award_list = GameCore.get_random_jokers(drop_number);
	exit_from_player = false
	exit_from_player_time = 0.0
	
	for i in range(award_list.size()):
		award_list[i].set_script(joker_script)
		slot.add_child(award_list[i])
		award_list[i].set_scale(Vector2(1.5,1.5))
		award_list[i].joker_clicked.connect(_joker_clicked)
	_set_award_pos(slot.get_children(),slot.get_rect())
	$next.set_disabled(true)
	
	
func _set_award_pos(nodes:Array[Node],rect:Rect2):
	var size = rect.size

	var gap = size.x/(nodes.size()+1)
	var x = rect.position.x
	var y = rect.get_center().y
	var i = 1
	for node in nodes:
		node.set_global_position(Vector2(i*gap+x,y))
		i+=1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(exit_from_player and exit_from_player_time<0.5):
		position.y += (get_window().size.y) * delta / 0.5
		exit_from_player_time += delta
	else:
		if (exit_from_player_time > 0.5):
			if selected_joker != null:
				selected_joker.set_scale(Vector2(1.0,1.0))
			var len = slot.get_child_count()
			for j in range(len):
				var child = slot.get_child(0)
				slot.remove_child(child)
			clicked.emit()
			queue_free()

func _my_next_clicked():
	if (GameCore.can_push_joker()):
		GameCore.push_joker(selected_joker)
		exit_from_player = true
		

func _on_next_mouse_entered():
	if (!GameCore.can_push_joker()):
		$next.text = "已达上限"
		$next.set_disabled(true)

func _on_next_mouse_exited():
	$next.text = "确定"
	$next.set_disabled(false)

func _my_skip_clicked():
	exit_from_player = true
	
func _joker_clicked(joker:JokerSprite):

	if selected_joker == joker:
		joker.set_scale(Vector2(1.5,1.5))
		selected_joker = null
		discription.clear()
	else:
		if selected_joker != null:
			selected_joker.set_scale(Vector2(1.5,1.5))
		selected_joker = joker
		joker.set_scale(Vector2(2.0,2.0))
		discription.clear()
		var info:JokerDisplayInfo = selected_joker.get_display_info()
		var color:Color
		match info.rarity:
			"Common":
				color = Color("White")
			"Uncommon":
				color = Color("Green")
			"Rare":
				color = Color("Red")
			"Lagendary":
				color = Color("Purple")
		discription.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		discription.push_font_size(30)
		discription.push_color(color)
		discription.append_text(info.name)
		discription.pop_all()
		discription.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		discription.push_font_size(20)
		discription.append_text(info.description)
		discription.pop_all()
		
	$next.set_disabled(selected_joker == null)
