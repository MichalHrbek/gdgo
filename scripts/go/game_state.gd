class_name GameState
extends RefCounted

const WHITE = Stone.StoneColor.WHITE
const BLACK = Stone.StoneColor.BLACK

var board_size: Vector2i = Vector2i(19,19)
var stones: Dictionary[Vector2i, Stone] = {}
var to_play: Stone.StoneColor = BLACK
var comment := ""

var arrows: Array[Arrow] = []
var lines: Array[Line] = []

func get_stone(pos: Vector2i) -> Stone:
	if not pos in stones:
		stones[pos] = Stone.new()
	return stones[pos]

static func from_sgf(node: SGF.SgfNode) -> GameState:
	var s = GameState.new()
	var tree = node.build_tree()
	
	for n in tree:
		for p in n.properties:
			var value = n.properties[p]
			match p:
				"B":
					assert(value is SgfTypes.SgfPoint)
					s.get_stone(value.to_ivec()).color = BLACK
					s.to_play = WHITE
				"W":
					assert(value is SgfTypes.SgfPoint)
					s.get_stone(value.to_ivec()).color = Stone.StoneColor.WHITE
					s.to_play = BLACK
				"AB":
					assert(value is SgfTypes.SgfPointList)
					for i in value.points:
						s.get_stone(i).color = BLACK
				"AW":
					assert(value is SgfTypes.SgfPointList)
					for i in value.points:
						s.get_stone(i).color = WHITE
				"SZ":
					assert(value is SgfTypes.SgfCompose)
					assert(value.left_value is SgfTypes.SgfNumber)
					if value.right_value:
						assert(value.right_value is SgfTypes.SgfNumber)
						s.board_size = Vector2i(value.left_value.value, value.right_value.value)
					else:
						s.board_size = Vector2i(value.left_value.value, value.left_value.value)

	for p in node.properties:
		var value = node.properties[p]
		match p:
			"C":
				s.comment = value.value
	return s
