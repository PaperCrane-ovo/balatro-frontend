extends PokerSprite

var time:float = 0
var drag = false
var gap_time = 0.0

var init_pos = randf()
var start_pos:Vector2

signal category_changed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time+=delta
	var pos = get_global_position()
	pos.y = 5*sin(time*0.4*PI+init_pos) + start_pos.y
	set_global_position(pos)
	if time>10:
		time -= 10

func set_start_pos(pos:Vector2):
	start_pos = pos

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not event.is_echo():
		if get_rect().has_point(to_local(event.position)):
			print("pressed")
			_clicked()
			get_tree().get_root().set_input_as_handled()
		
		
func _clicked():
	print("clicked")

	
	if !is_selected:
		var result = GameCore.add_to_selected_cards(self)
		if result:
			start_pos.y += -30
			is_selected = true
	else:
		GameCore.remove_from_selected_cards(self)
		is_selected = false
		start_pos.y += 30
		
	category_changed.emit()

		
		
			
		
		

