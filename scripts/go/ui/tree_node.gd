class_name TreeNodeUI
extends Control

@export var line: Line2D
@export var texture: TextureRect
@export var label: Label

func select():
	grab_focus.call_deferred()
	texture.self_modulate = Color.LIGHT_CORAL

func deselect():
	texture.self_modulate = Color.WHITE
