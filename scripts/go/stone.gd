class_name Stone
extends RefCounted

var color: StoneColor = StoneColor.NONE
var markup: StoneMarkup = StoneMarkup.NONE
var dim: bool = false

enum StoneColor {
	NONE,
	WHITE,
	BLACK,
}

enum StoneMarkup {
	NONE,
	CIRCLE,
	CROSS,
	SELECTED,
	SQUARE,
	TRIANGLE,
}
