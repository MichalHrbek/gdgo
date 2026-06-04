extends GridContainer

@export var board: Board

signal state_changed(state: GameState, node: SGF.SgfNode)

var root: SGF.SgfNode
var current_node: SGF.SgfNode
var current_state: GameState

var by_id: Dictionary[int, SGF.SgfNode] = {}
var by_pos: Dictionary[Vector2i, SGF.SgfNode] = {}
var id_by: Dictionary[SGF.SgfNode, int] = {}
var pos_by: Dictionary[SGF.SgfNode, Vector2i] = {}

const node_scene: PackedScene = preload("res://scenes/tree_node.tscn")

func _ready() -> void:
	#var s := SGF.SgfFile.new("(;FF[4]GM[1]SZ[19];B[aa];W[bb];B[cc];W[dd];B[ad];W[bd])")
	var s := SGF.SgfFile.new(FileAccess.open("res://examples/ff4_ex.sgf.txt", FileAccess.READ).get_as_text())
	#var s := SGF.SgfFile.new(FileAccess.open("res://examples/tree.sgf.txt", FileAccess.READ).get_as_text())
	#var s := SGF.SgfFile.new(FileAccess.open("res://examples/print1.sgf.txt", FileAccess.READ).get_as_text())
	s.parse()
	create_tree(s.roots[0])

func create_tree(new_root: SGF.SgfNode) -> void:
	root = new_root
	by_id = {}
	by_pos = {}
	id_by = {}
	pos_by = {}
	walk(new_root, 0, 0, 0, 0)
	vis()
	load_node(new_root)

func load_node(node: SGF.SgfNode):
	if current_node:
		_vis_node[current_node].deselect()
	_vis_node[node].select()
	current_node = node
	current_state = GameState.from_sgf(node)
	state_changed.emit(current_state, current_node)

func walk(node: SGF.SgfNode, x: int, y: int, max_y: int, index: int) -> Vector2i:
	by_id[index] = node
	id_by[node] = index
	by_pos[Vector2i(x,y)] = node
	pos_by[node] = Vector2i(x,y)
	for i in range(len(node.children)):
		if i:
			max_y += 1
		var w = walk(node.children[i], x+1, max_y if i else y, max_y, index+1)
		index = w.x
		max_y = w.y
	return Vector2i(index, max_y)

var _vis_node: Dictionary[SGF.SgfNode, Control] = {}

func vis() -> void:
	for i in get_children():
		i.queue_free()
	
	var height := 0
	var width := 0
	for i in by_pos.keys():
		height = max(height, i.y+1)
		width = max(width, i.x+1)
	
	columns = width
	for y in range(height):
		for x in range(width):
			var p := Vector2i(x,y)
			if by_pos.has(p):
				var node = by_pos[p]
				var control: TreeNodeUI = node_scene.instantiate()
				if node.parent:
					sort_children.connect(func(): control.line.points = PackedVector2Array([Vector2(32,32), _vis_node[node.parent].position-_vis_node[node].position+Vector2(32,32)]))
				_vis_node[node] = control
				control.label.text = str(id_by[by_pos[p]])
				control.gui_input.connect(_on_node_clicked.bind(id_by[by_pos[p]]))
				add_child(control)
			else:
				add_child(Control.new())
 
func _on_node_clicked(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if event.pressed:
				load_node(by_id[index])

func _unhandled_key_input(event: InputEvent) -> void:
	if current_node:
		if event is InputEventKey:
			if event.is_action_pressed("ui_right"):
				if current_node.children:
					load_node(current_node.children[0])
			elif event.is_action_pressed("ui_left"):
				if current_node.parent:
					load_node(current_node.parent)
			elif event.is_action_pressed("ui_down"):
				if current_node.parent:
					var l := len(current_node.parent.children)
					load_node(current_node.parent.children[(current_node.parent.children.find(current_node)+1)%l])
			elif event.is_action_pressed("ui_up"):
				if current_node.parent:
					var l := len(current_node.parent.children)
					load_node(current_node.parent.children[(current_node.parent.children.find(current_node)-1)%l])
