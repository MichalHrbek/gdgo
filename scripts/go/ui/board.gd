class_name Board
extends Control

@export var dragger: Control

var control_grid: Dictionary[Vector2i, Control] = {}
var markup_nodes: Array[Node] = []
var rows := 0
var columns := 0

const board_piece_scene: PackedScene = preload("res://scenes/board_piece.tscn")
var last_viewport_size: Vector2

var current_state: GameState

signal tree_edited(node: SGF.SgfNode)

func _board_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.size = Vector2(64,64)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func update_markup(state: GameState) -> void:
	for i in markup_nodes:
		i.queue_free()
	markup_nodes = []
	
	for i in state.lines:
		var line = Line2D.new()
		line.add_point(i.start*64+Vector2i(32,32))
		line.add_point(i.end*64+Vector2i(32,32))
		line.default_color = Color.BLUE
		line.width = 8
		markup_nodes.append(line)
		add_child(line)
	
	for i in state.arrows:
		var arrow = Line2D.new()
		var start: Vector2 = i.start*64+Vector2i(32,32)
		var end: Vector2 = i.end*64+Vector2i(32,32)
		var left_head = Vector2(-16,-16).rotated(start.angle_to_point(end))
		var right_head = Vector2(-16,16).rotated(start.angle_to_point(end))
		arrow.add_point(start)
		arrow.add_point(end)
		arrow.add_point(end+left_head)
		arrow.add_point(end)
		arrow.add_point(end+right_head)
		arrow.default_color = Color.BLUE
		arrow.width = 8
		markup_nodes.append(arrow)
		add_child(arrow)

func goto(state: GameState) -> void:
	current_state = state
	for y in range(state.board_size.y):
		for x in range(state.board_size.x):
			var pos := Vector2i(x,y) + Vector2i.ONE
			control_grid[pos].get_child(0).update(state.get_stone(pos), pos, state.board_size)
	update_markup(state)

func create(state: GameState) -> void:
	current_state = state
	for i in control_grid.values():
		i.queue_free()
	
	control_grid.clear()
	
	columns = state.board_size.x+1
	rows = state.board_size.y+1
	
	for y in range(rows):
		for x in range(columns):
			var pos := Vector2i(x,y)
			var c := Control.new()
			c.custom_minimum_size = Vector2(64, 64)
			control_grid[pos] = c
			add_child(c)
			c.position = pos*64
	
	for i in range(state.board_size.y):
		control_grid[Vector2i(0,i+1)].add_child(_board_label(str(i+1)))

	for i in range(state.board_size.x):
		control_grid[Vector2i(i+1,0)].add_child(_board_label(str(i+1)))
	
	for y in range(state.board_size.y):
		for x in range(state.board_size.x):
			var pos := Vector2i(x,y) + Vector2i.ONE
			
			var piece: BoardPiece = board_piece_scene.instantiate()
			piece.update(state.get_stone(pos), pos, state.board_size)
			piece.mouse_entered.connect(func(): piece.show_potenial(current_state.to_play))
			piece.mouse_exited.connect(piece.hide_potential)
			piece.gui_input.connect(_on_piece_input_event.bind(pos))
			
			control_grid[pos].add_child(piece)
	
	update_markup(state)
	
	dragger.position = Vector2(columns*64, rows*64)
	size = Vector2(columns*64, rows*64)+dragger.size

func _on_piece_input_event(event: InputEvent, pos: Vector2i) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
				if current_state.get_stone(pos).color == Stone.StoneColor.NONE:
					make_move(pos)


var y_prop := 0.75
var x_prop := 0.8
func ensure_size() -> void:
	var fit_scale = min(get_viewport_rect().size.y*y_prop/(64.0*rows), get_viewport_rect().size.x*x_prop/(64.0*columns))
	scale = Vector2(fit_scale,fit_scale)
	get_parent().custom_minimum_size = size*scale

func make_move(pos: Vector2i) -> void:
	var new_state = current_state.make_move(pos)
	if new_state.associated_node:
		tree_edited.emit(new_state.associated_node)
	goto(new_state)

func _on_state_changed(state: GameState, _node: SGF.SgfNode) -> void:
	if control_grid:
		goto(state)
	else:
		create(state)
	ensure_size()

func _ready() -> void:
	resized.connect(ensure_size)
	get_viewport().size_changed.connect(ensure_size)
	ensure_size()
	dragger.gui_input.connect(_on_dragger_input)

var dragging := false
func _on_dragger_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			dragging = event.pressed
	
	if dragging:
		if event is InputEventMouseMotion:
			var goal_size: Vector2 = event.global_position-global_position
			x_prop = clampf(goal_size.x/get_viewport_rect().size.x, 0.25, 0.9)
			y_prop = clampf(goal_size.y/get_viewport_rect().size.y, 0.25, 0.9)
			ensure_size()
