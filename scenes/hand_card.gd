extends Node2D

signal card_played
signal card_discarded
signal judge_game_over

signal exited

var exit_from_player:bool
var exit_from_player_time:float


@onready var hand_pile:ColorRect = $ColorRect

var poker_script = preload("res://scenes/poker.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	$"出牌".set_disabled(true)
	$"弃牌".set_disabled(true)
	card_played.connect(get_parent()._on_card_played)
	card_discarded.connect(get_parent()._on_card_discarded)
	judge_game_over.connect(get_parent()._on_judge_game_over)
	exit_from_player = false
	exit_from_player_time = 0.0
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# 都是相对父节点的坐标
	if(exit_from_player and exit_from_player_time<0.5):
		position.y += (get_window().size.y) * delta / 0.5
		exit_from_player_time += delta
	else:
		if (exit_from_player_time > 0.5):
			exited.emit()
			var len = hand_pile.get_child_count()
			for j in range(len):
				var child = hand_pile.get_child(0)
				hand_pile.remove_child(child)

			queue_free()
	

	
func play_card():
	_hand_card_to_display()
	GameCore.on_play_card()
	card_played.emit()

	await get_tree().create_timer(1.0).timeout
	remove_selected_card_from_hand_pile()
	GameCore.move_selected_pokers_to_discard_pile()
	judge_game_over.emit()
	
	
func next_draw():
	
	
	draw_card()
	GameCore.this_round_score_chip = 0
	GameCore.this_round_score_mult = 0
	get_parent()._update_category()
	
	
	
	
	
func discard_card():
	GameCore.on_discard_card()
	card_discarded.emit()
	
	remove_selected_card_from_hand_pile()
	GameCore.move_selected_pokers_to_discard_pile()
	
	
	
	draw_card()
	GameCore.this_round_score_chip = 0
	GameCore.this_round_score_mult = 0
	get_parent()._update_category()
	

func draw_card():
	var max_hand_card = GameCore.hand_limit
	var draw_count = max_hand_card-GameCore.get_hand_pile().size()
	GameCore.draw_pokers(draw_count)
	var hand_pile = GameCore.get_hand_pile()
	hand_pile.sort_custom(
		func(a:PokerSprite,b:PokerSprite):
			return a.get_value_to_sort()>b.get_value_to_sort()
	)
	var node = $ColorRect
	

	for i in range(hand_pile.size()):
		if hand_pile[i].is_inside_tree():
			continue
		else:
			var poker = hand_pile[i]
			poker.set_script(poker_script)
			node.add_child(poker)
			node.move_child(poker,i)
			if not poker.category_changed.is_connected(get_parent()._update_category):
				poker.category_changed.connect(get_parent()._update_category)
			if not poker.category_changed.is_connected(_update_play_discard_button):
				poker.category_changed.connect(_update_play_discard_button)
	_set_pokers_pos(node.get_children(),node.get_rect())
	
	
func _update_play_discard_button():
	var has_selected_pokers = GameCore.has_selected_pokers()
	var can_play_card = GameCore.play_hand_count>0
	var can_discard_card = GameCore.discard_count>0
	$"出牌".set_disabled(!(has_selected_pokers && can_play_card))
	$"弃牌".set_disabled(!(has_selected_pokers && can_discard_card))
		
func _set_pokers_pos(pokers:Array[Node],rect:Rect2):
	var size = rect.size

	var gap = size.x/(pokers.size()+1)
	var x = rect.position.x
	var y = rect.get_center().y
	var i = 1
	for poker in pokers:
		poker.set_global_position(Vector2(i*gap+x,y))
		poker.set_start_pos(Vector2(i*gap+x,y))

		poker.set_scale(Vector2(1.25,1.25))
		i+=1
func _hand_card_to_display():
	var display_pokers:Array[Node]
	var hand_pokers:Array[Node]
	var children = $ColorRect.get_children()
	for child in children:
		if child.is_selected:
			display_pokers.append(child)
		else:
			hand_pokers.append(child)

	_set_pokers_pos(hand_pokers,$ColorRect.get_rect())
	_set_pokers_pos(display_pokers,$DisplayZone.get_rect())

func remove_selected_card_from_hand_pile():

	var len = hand_pile.get_child_count()
	var i:int = 0
	for j in range(len):
		var child = hand_pile.get_child(i)
		if child.is_selected:
			hand_pile.remove_child(child)
		else:
			i+=1
	



