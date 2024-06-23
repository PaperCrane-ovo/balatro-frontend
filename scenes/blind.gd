extends Node2D


var blind_type:String
var current_blind:int
signal enter_room
var entering_room:bool
var entering_time:float

var blinds:Array[Blind]

# Called when the node enters the scene tree for the first time.
func _ready():
	blinds = GameCore.get_blinds()
	set_blinds()
	entering_room = false
	entering_time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(entering_room and entering_time<0.5):
		position.y += (get_window().size.y) * delta / 0.5
		entering_time += delta
	else:
		if (entering_time > 0.5):
			enter_room.emit()
			queue_free()
	
		
	
func set_blinds():
	var children = get_children()
	for i in range(3):
		children[i].get_child(0).set_disabled(true)
		children[i].get_child(3).set_disabled(true)
		children[i].get_child(3).set_text("跳过盲注")
		match blinds[i].blind_type:
			"SmallBlind":
				children[i].get_child(1).set_text("小盲注")
			"BigBlind":
				children[i].get_child(1).set_text("大盲注")
			"BossBlind":
				children[i].get_child(1).set_text("Boss盲注")
		children[i].get_child(2).set_text("[center][color=white][font_size=25]所需分数：%d[/font_size][/color][/center]" % blinds[i].hp)
		match blinds[i].state:
			"NotChoose":
				children[i].get_child(0).set_text("下一回合")				
			"Choose":
				children[i].position -= Vector2(0.0,35.0)
				children[i].get_child(0).set_disabled(false)
				children[i].get_child(0).set_text("选择")
				children[i].get_child(3).set_disabled(false)
				current_blind = i
			"Skip":
				children[i].get_child(0).set_text("跳过")
				children[i].get_child(3).set_visible(false)
			"Killed":
				children[i].get_child(0).set_text("已被击败")
				children[i].get_child(3).set_visible(false)
		children[i].get_child(0).button_down.connect(_choose_blind)
		children[i].get_child(3).button_down.connect(_skip_blind)
	children[2].get_child(3).set_text("不可跳过Boss盲注")
	children[2].get_child(3).set_disabled(true)

func _choose_blind():
	print("choose %d" % current_blind)
	GameCore.choose_current_blind()
	entering_room = true
	
	
func _skip_blind():
	print("skip %d" % current_blind)
