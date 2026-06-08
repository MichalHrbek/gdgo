class_name BoardPiece
extends Control

var star := false
@export var black_stone: Control
@export var white_stone: Control

@export var markup_circle: Control
@export var markup_cross: Control
@export var markup_square: Control
@export var markup_selected: Control
@export var markup_triangle: Control
@export var markup_territory: Control
@export var markup_label: Label

@export var grid_top: Control
@export var grid_bottom: Control
@export var grid_left: Control
@export var grid_right: Control


func update(stone: Stone, pos: Vector2, board_size: Vector2i) -> void:
	grid_top.show()
	grid_bottom.show()
	grid_left.show()
	grid_right.show()
	
	if pos.x == 1: grid_left.hide()
	if pos.y == 1: grid_top.hide()
	if pos.x == board_size.x: grid_right.hide()
	if pos.y == board_size.y: grid_bottom.hide()
	
	#white_stone.self_modulate.a = 0.5 if stone.dim else 1.0
	#black_stone.self_modulate.a = 0.5 if stone.dim else 1.0
	
	self.visible = stone.in_view
	self.modulate = Color.GRAY if stone.dim else Color.WHITE
	
	if stone.color == Stone.StoneColor.WHITE:
		white_stone.show()
		black_stone.hide()
	elif stone.color == Stone.StoneColor.BLACK:
		white_stone.hide()
		black_stone.show()
	else:
		white_stone.hide()
		black_stone.hide()
	
	var markup_nodes: Dictionary[Stone.StoneMarkup, Control] = {
		Stone.StoneMarkup.CIRCLE: markup_circle,
		Stone.StoneMarkup.CROSS: markup_cross,
		Stone.StoneMarkup.SQUARE: markup_square,
		Stone.StoneMarkup.TRIANGLE: markup_triangle,
		Stone.StoneMarkup.SELECTED: markup_selected,
	}
	for i in markup_nodes.values():
		i.hide()
	if markup_nodes.has(stone.markup):
		markup_nodes[stone.markup].show()
	
	if stone.territory == Stone.StoneColor.WHITE:
		markup_territory.show()
		markup_territory.self_modulate = Color.WHITE
	elif stone.territory == Stone.StoneColor.BLACK:
		markup_territory.show()
		markup_territory.self_modulate = Color.BLACK
	else:
		markup_territory.hide()
	
	markup_label.text = stone.label
