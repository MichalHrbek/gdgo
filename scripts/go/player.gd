class_name Player
extends RefCounted

var color: Stone.StoneColor
var name: String = ""
var rank: String = ""
var team: String = ""
var time_left: float = 0.0
var moves_left: int = 0 # Moves left in this byo-yomi period
var enemy_prisoners: int = 0

func _init(color_: Stone.StoneColor) -> void:
	color = color_

func compare(other: Player) -> bool:
	return color == other.color and name == other.name and rank == other.rank and team == other.team and time_left == other.time_left and moves_left == other.moves_left and enemy_prisoners == other.enemy_prisoners
