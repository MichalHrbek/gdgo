class_name Stone
extends RefCounted

var color: StoneColor = StoneColor.NONE
var territory: StoneColor = StoneColor.NONE
var markup: StoneMarkup = StoneMarkup.NONE
var dim: bool = false
var in_view: bool = true
var label: String = ""

enum StoneColor {
	NONE,
	WHITE,
	BLACK,
	BOTH, # Used for pass
}

enum StoneMarkup {
	NONE,
	CIRCLE,
	CROSS,
	SELECTED,
	SQUARE,
	TRIANGLE,
}

func compare(other: Stone) -> bool:
	return color == other.color and territory == other.territory and markup == other.markup and dim == other.dim and in_view == other.in_view and label == other.label
