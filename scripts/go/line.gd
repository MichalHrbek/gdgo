class_name Line
extends RefCounted

var start: Vector2i
var end: Vector2i

func _init(start_: Vector2i, end_: Vector2i) -> void:
	self.start = start_
	self.end = end_

func compare(other) -> bool:
	return start == other.start and end == other.end
