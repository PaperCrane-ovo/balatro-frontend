extends JokerSprite

signal joker_clicked(joker)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not event.is_echo():
		if get_rect().has_point(to_local(event.position)):
			print("pressed")
			_clicked()
			get_tree().get_root().set_input_as_handled()
		
		
func _clicked():
	print("clicked")
		
	joker_clicked.emit(self)
