extends GridContainer

@export var board: Board

var root: SGF.SgfNode

var by_id: Dictionary[int, SGF.SgfNode] = {}
var by_pos: Dictionary[Vector2i, SGF.SgfNode] = {}
var id_by: Dictionary[SGF.SgfNode, int] = {}
var pos_by: Dictionary[SGF.SgfNode, Vector2i] = {}

func _ready() -> void:
	#var s := SGF.SgfFile.new("(;FF[4]GM[1]SZ[19];B[aa];W[bb];B[cc];W[dd];B[ad];W[bd])")
	var s := SGF.SgfFile.new(FileAccess.open("res://examples/ff4_ex.sgf.txt", FileAccess.READ).get_as_text())
	#var s := SGF.SgfFile.new(FileAccess.open("res://examples/tree.sgf.txt", FileAccess.READ).get_as_text())
	s.parse()
	print(s.roots)
	print(len(s.roots))
	root = s.roots[0]
	walk(root, 0, 0, 0)
	vis()
	print(by_id[18].properties)
	board.create(GameState.from_sgf(by_id[19]))

func walk(node: SGF.SgfNode, x: int, y: int, index: int) -> int:
	by_id[index] = node
	id_by[node] = index
	by_pos[Vector2i(x,y)] = node
	pos_by[node] = Vector2i(x,y)
	for i in range(len(node.children)):
		index = walk(node.children[i], x+1, y+i, index+1)
	return index

func vis() -> void:
	var height := 0
	var width := 0
	for i in by_pos.keys():
		height = max(height, i.y+1)
		width = max(width, i.x+1)
	
	columns = width
	for y in range(height):
		for x in range(width):
			var l := Label.new()
			var p := Vector2i(x,y)
			if by_pos.has(p):
				l.text = str(x)#str(id_by[by_pos[p]])
			add_child(l)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
