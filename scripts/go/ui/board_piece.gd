class_name BoardPiece
extends Control

var star := false
@export var black_stone: Control
@export var white_stone: Control

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
	
	if stone.color == Stone.StoneColor.WHITE:
		white_stone.show()
		black_stone.hide()
	elif stone.color == Stone.StoneColor.BLACK:
		white_stone.hide()
		black_stone.show()
	else:
		white_stone.hide()
		black_stone.hide()
