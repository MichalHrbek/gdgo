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

var black_captured := 0 # Black stones that have been captured
var white_captured := 0 # White stones that have been captured

var arrows: Array[Arrow] = []
var lines: Array[Line] = []

func get_stone(pos: Vector2i) -> Stone:
	if not is_valid_position(pos):
		return null
	if not pos in stones:
		stones[pos] = Stone.new()
	return stones[pos]

func is_valid_position(pos: Vector2i) -> bool:
	return pos.x > 0 and pos.y > 0 and pos.x <= board_size.x and pos.y <= board_size.y

func neighbours(source: Vector2i) -> Array[Vector2i]:
	return [
	source+Vector2i(1,0),
	source+Vector2i(-1,0),
	source+Vector2i(0,1),
	source+Vector2i(0,-1)]

func ffil(source: Vector2i) -> Array[Vector2i]:
	var source_color = get_stone(source).color
	var group: Array[Vector2i] = []
	var queue: Array[Vector2i] = [source]
	while queue:
		var s = queue.pop_front()
		if not is_valid_position(s):
			continue
		if get_stone(s).color != source_color:
			continue
		if s in group:
			continue
		group.append(s)
		queue.push_back(s+Vector2i(1,0))
		queue.push_back(s+Vector2i(-1,0))
		queue.push_back(s+Vector2i(0,1))
		queue.push_back(s+Vector2i(0,-1))
	return group

func flib(source: Vector2i) -> Array[Array]:
	var source_color = get_stone(source).color
	var group: Array[Vector2i] = []
	var queue: Array[Vector2i] = [source]
	var liberties: Array[Vector2i] = []
	while queue:
		var s = queue.pop_front()
		if not is_valid_position(s):
			continue
		var c := get_stone(s).color
		if c != source_color:
			if c == Stone.StoneColor.NONE:
				if s not in liberties:
					liberties.append(s)
			continue
		if s in group:
			continue
		group.append(s)
		queue.push_back(s+Vector2i(1,0))
		queue.push_back(s+Vector2i(-1,0))
		queue.push_back(s+Vector2i(0,1))
		queue.push_back(s+Vector2i(0,-1))
	return [group, liberties]

func clear_if_dead(source: Vector2i) -> int:
	var result = flib(source)
	var group = result[0]
	var liberties = result[1]
	if not liberties:
		for i in group:
			get_stone(i).color = Stone.StoneColor.NONE
		return len(group)
	return 0

func record_captured(color: Stone.StoneColor, ammount: int) -> void:
	if color == Stone.StoneColor.WHITE: white_captured += ammount
	elif color == Stone.StoneColor.BLACK: black_captured += ammount

func after_move_check(move: Vector2i):
	var c := get_stone(move).color
	for i in neighbours(move):
		var s := get_stone(i)
		if not s:
			continue
		if s.color not in [Stone.StoneColor.NONE, c]:
			record_captured(s.color, clear_if_dead(i))
	
	record_captured(c, clear_if_dead(move))

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
					s.after_move_check(value.to_ivec())
					s.to_play = WHITE
					s.move_number += 1
				"W":
					assert(value is SgfTypes.SgfPoint)
					s.get_stone(value.to_ivec()).color = Stone.StoneColor.WHITE
					s.after_move_check(value.to_ivec())
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
