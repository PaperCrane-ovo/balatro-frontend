extends Player

var times = 0.0
var past_message:Dictionary
enum RoomType{
	BlindRoom,
	ShopRoom,
}
var room_type:RoomType


@onready var chip:Label = $"Message/筹码*倍率/筹码/计数"
@onready var mag:Label = $"Message/筹码*倍率/倍率/计数"
@onready var score:Label = $"Message/回合分数/计数"
@onready var room:RichTextLabel = $"Message/房间"
@onready var joker_discription:RichTextLabel = $"Message/小丑"

# Called when the node enters the scene tree for the first time.
func _ready():
	past_message = get_message()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	times += delta
	if times > 0.5:
		times = 0
		_update_message()
func _update_message():	
	var message = get_message()
	$"Message/出牌/计数".set_text("%s" % message["play_hand_count"])
	$"Message/弃牌/计数".set_text("%s" % message['discard_count'])
	$"Message/钱数/计数".set_text("$ %s" % message["gold"])
	$"Message/底注/计数".set_text("{cur}/{max}".format({"cur":message["cur_ante"],"max":message["max_ante"]}))
	$"Message/回合/计数".set_text("%s" % message["round"])
	
		
	
func _update_category():
	print("should update category")
	var category = GameCore.get_category()
	
	$"Message/筹码*倍率/牌型".set_text(category)
	if category.is_empty():
		$"Message/筹码*倍率/等级".set_text("")
	else:
		$"Message/筹码*倍率/等级".set_text("等级1")
	_update_chip_mag()
func _update_chip_mag():
	var score:Array = Array()
	score.push_back(GameCore.this_round_score_chip)
	score.push_back(GameCore.this_round_score_mult)
	var tween = create_tween()
	var new_chip = score[0]
	var new_mag = score[1]

	var cur_chip = chip.text.to_int()
	var cur_mag = mag.text.to_float()
	
	#tween.tween_property($"Message/筹码*倍率/倍率/计数","text",mag,0.5)
	#tween.parallel().tween_property($"Message/筹码*倍率/筹码/计数","text",chip,0.5)
	tween.tween_method(set_int_to_text.bind(chip,false),cur_chip,new_chip,0.25)
	tween.parallel().tween_method(set_float_to_text.bind(mag,false),cur_mag,new_mag,0.25)

func set_int_to_text(value: int, label: Label, add: bool = false) -> void:
	if add:
		label.text = "+" + str(value)
	else:
		label.text = str(value)
func set_float_to_text(value:float,label:Label,decimal = 2,add:bool = false):
	if add:
		label.text = "+" + String.num(value,decimal)
	else:
		label.text = String.num(value,decimal)

func _on_card_played():
	_update_chip_mag()
	_update_score()
	
	
	
	
func _on_card_discarded():
	pass
	
func _update_score():
	var s = GameCore.cur_score

	var new_score = s
	var tween = create_tween()
	var old_score = score.text.to_int()
	tween.tween_method(set_int_to_text.bind(score,false),old_score,new_score,1.0)

func _select_blind():
	add_child(load("res://scenes/blind.tscn").instantiate())
	var node = $Blind
	if not node.enter_room.is_connected(_on_blind_enter_room):
		node.enter_room.connect(_on_blind_enter_room)

func _exit_blind():
	add_child(load("res://scenes/win_blind.tscn").instantiate())
	var node = $WinBlind
	node.clicked.connect(_select_blind)
	node.clicked.connect($JokerList._joker_added)
	

func _on_judge_game_over():
	var result = judge_battle_win_or_lose()
	match result:
		0:
			GameCore.game_state = "Win"
			$HandCard.exit_from_player = true
			GameCore.win_current_blind()
			_update_category()
			
			if GameCore.game_state == "FinalWin":
				SceneManager.change_scene(
					"res://scenes/game_over.tscn"
				)
		1:
			GameCore.game_state = "Lose"
			SceneManager.change_scene(
				"res://scenes/game_over.tscn"
			)
		2:
			$HandCard.next_draw()

func _on_blind_enter_room():
	add_child(load("res://scenes/hand_card.tscn").instantiate())
	$HandCard.exited.connect(_exit_blind)
	_update_score()

	
	room.clear()
	
	var cur_blind:Blind = GameCore.get_blinds()[GameCore.cur_blind_index]
	room.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
	room.push_font_size(30)
	room.append_text("至少得分：")
	room.push_color(Color("red"))
	room.append_text("%d"%cur_blind.hp)
	room.pop_all()
	room.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
	room.push_font_size(30)
	room.push_color(Color("yellow"))
	room.append_text("奖励：$%d" % cur_blind.award)
	room.pop_all()
	
	$HandCard.draw_card()

func judge_battle_win_or_lose() -> int:
	# 0 presents win this battle
	# 1 presents lose this game
	# 2 presents continue
	var hp = GameCore.get_blinds()[GameCore.cur_blind_index].hp
	var cur_score = GameCore.cur_score
	if cur_score>=hp:
		return 0
	else:
		var rest_play_count = GameCore.play_hand_count
		if rest_play_count>0:
			var playable_cards_count = GameCore.get_specific_pile_count("draw_pile")+GameCore.get_specific_pile_count("hand_pile")
			if playable_cards_count>0:
				return 2
			else:
				return 1
		else:
			return 1

func update_joker_description(discription:JokerDisplayInfo):
	joker_discription.clear()
	if discription != null:
		joker_discription.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		joker_discription.push_font_size(20)
		var color:Color
		match discription.rarity:
			"Common":
				color = Color("White")
			"Uncommon":
				color = Color("Green")
			"Rare":
				color = Color("Red")
			"Legendary":
				color = Color("Purple")
		joker_discription.push_color(color)
		joker_discription.append_text(discription.name)
		joker_discription.pop_all()
		joker_discription.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		joker_discription.push_color(Color("Yellow"))
		joker_discription.append_text("%d $" % discription.price)
		joker_discription.pop_all()
		joker_discription.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
		joker_discription.push_font_size(15)
		joker_discription.append_text(discription.description)
		joker_discription.pop_all()
