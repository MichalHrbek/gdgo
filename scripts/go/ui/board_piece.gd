class_name BoardPiece
extends Control

var star := false
@export var black_stone: Control
@export var white_stone: Control

func update(stone: Stone) -> void:
	if stone.color == Stone.StoneColor.WHITE:
		#print("WHITE")
		white_stone.show()
		black_stone.hide()
	elif stone.color == Stone.StoneColor.BLACK:
		#print("BLACK")
		white_stone.hide()
		black_stone.show()
	else:
		white_stone.hide()
		black_stone.hide()
