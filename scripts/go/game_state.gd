class_name GameState
extends RefCounted

const NONE = Stone.StoneColor.NONE
const WHITE = Stone.StoneColor.WHITE
const BLACK = Stone.StoneColor.BLACK

var board_size: Vector2i = Vector2i(19,19)
var stones: Dictionary[Vector2i, Stone] = {}
var to_play: Stone.StoneColor = BLACK
var comment := ""
var move_number := 0

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
					s.move_number += 1
				"W":
					assert(value is SgfTypes.SgfPoint)
					s.get_stone(value.to_ivec()).color = Stone.StoneColor.WHITE
					s.to_play = BLACK
					s.move_number += 1
				"AB":
					assert(value is SgfTypes.SgfPointList)
					for i in value.points:
						s.get_stone(i).color = BLACK
				"AW":
					assert(value is SgfTypes.SgfPointList)
					for i in value.points:
						s.get_stone(i).color = WHITE
				"AE":
					assert(value is SgfTypes.SgfPointList)
					for i in value.points:
						s.get_stone(i).color = NONE
				"SZ":
					assert(value is SgfTypes.SgfCompose)
					assert(value.left_value is SgfTypes.SgfNumber)
					if value.right_value:
						assert(value.right_value is SgfTypes.SgfNumber)
						s.board_size = Vector2i(value.left_value.value, value.right_value.value)
					else:
						s.board_size = Vector2i(value.left_value.value, value.left_value.value)
				"PL":
					assert(value is SgfTypes.SgfColor)
					s.to_play = value.value
				"MN":
					assert(value is SgfTypes.SgfNumber)
					s.move_number = value.value

	for p in node.properties:
		var value = node.properties[p]
		match p:
			"C":
				s.comment = value.value
			"CR":
				assert(value is SgfTypes.SgfPointList)
				for i in value.points:
					s.get_stone(i).markup = Stone.StoneMarkup.CIRCLE
			"LB":
				assert(value is SgfTypes.SgfList)
				for i in value.values:
					assert(i is SgfTypes.SgfCompose)
					assert(i.left_value is SgfTypes.SgfPoint)
					assert(i.right_value is SgfTypes.SgfText)
					s.get_stone(i.left_value.to_ivec()).label = i.right_value.value
			"MA":
				assert(value is SgfTypes.SgfPointList)
				for i in value.points:
					s.get_stone(i).markup = Stone.StoneMarkup.CROSS
			"SL":
				assert(value is SgfTypes.SgfPointList)
				for i in value.points:
					s.get_stone(i).markup = Stone.StoneMarkup.SELECTED
			"SQ":
				assert(value is SgfTypes.SgfPointList)
				for i in value.points:
					s.get_stone(i).markup = Stone.StoneMarkup.SQUARE
			"TR":
				assert(value is SgfTypes.SgfPointList)
				for i in value.points:
					s.get_stone(i).markup = Stone.StoneMarkup.TRIANGLE
			"TW":
				assert(value is SgfTypes.SgfPointList)
				for i in value.points:
					s.get_stone(i).territory = Stone.StoneColor.WHITE
			"TB":
				assert(value is SgfTypes.SgfPointList)
				for i in value.points:
					s.get_stone(i).territory = Stone.StoneColor.BLACK
	return s
