class_name Board
extends GridContainer

var control_grid: Dictionary[Vector2i, Control] = {}
var rows := 0

const board_piece_scene: PackedScene = preload("res://scenes/board_piece.tscn")
var last_viewport_size: Vector2

var current_state: GameState

func _board_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.size = Vector2(64,64)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func goto(state: GameState) -> void:
	for y in range(state.board_size.y):
		for x in range(state.board_size.x):
			var pos := Vector2i(x,y) + Vector2i.ONE
			control_grid[pos].get_child(0).update(state.get_stone(pos), pos, state.board_size)

func create(state: GameState) -> void:
	for i in get_children():
		i.queue_free()
	
	columns = state.board_size.x+1
	rows = state.board_size.y+1
	
	for y in range(rows):
		for x in range(columns):
			var pos := Vector2i(x,y)
			var c := Control.new()
			c.custom_minimum_size = Vector2(64, 64)
			control_grid[pos] = c
			add_child(c)
	
	for i in range(state.board_size.y):
		control_grid[Vector2i(0,i+1)].add_child(_board_label(str(i+1)))

	for i in range(state.board_size.x):
		control_grid[Vector2i(i+1,0)].add_child(_board_label(str(i+1)))
	
	for y in range(state.board_size.y):
		for x in range(state.board_size.x):
			var pos := Vector2i(x,y) + Vector2i.ONE
			
			var piece: BoardPiece = board_piece_scene.instantiate()
			piece.update(state.get_stone(pos), pos, state.board_size)
			piece.gui_input.connect(_on_piece_input_event.bind(pos))
			
			control_grid[pos].add_child(piece)

func _on_piece_input_event(event: InputEvent, pos: Vector2i) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
				pass

func ensure_size():
	var fit_scale = min(get_viewport_rect().size.y*0.75/(64.0*rows), get_viewport_rect().size.x*0.8/(64.0*columns))
	scale = Vector2(fit_scale,fit_scale)
	get_parent().custom_minimum_size = size*scale

func _on_state_changed(state: GameState, _node: SGF.SgfNode) -> void:
	current_state = state
	if control_grid:
		goto(state)
	else:
		create(state)
	ensure_size()

func _ready() -> void:
	resized.connect(ensure_size)
	get_viewport().size_changed.connect(ensure_size)
	ensure_size()
	
