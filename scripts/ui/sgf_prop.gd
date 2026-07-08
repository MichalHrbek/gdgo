class_name SgfPropUI
extends Control

@export var l1: SgfTypeButton
@export var list: SgfTypeButton
@export var left: SgfTypeButton
@export var right: SgfTypeButton
@export var value: TextEdit
@export var key: Label

func create(prop_name: String, prop_value: SgfTypes.SgfTypeBase) -> void:
	var type = prop_value.get_type()
	l1.should_select = type
	if prop_value is SgfTypes.SgfCompose:
		left.should_select = prop_value.left_value.get_type()
		if prop_value.right_value: right.should_select = prop_value.right_value.get_type()
	elif prop_value is SgfTypes.SgfList:
		if prop_value.values:
			list.should_select = prop_value.values[0].get_type()
			if list.should_select == SgfTypes.SgfCompose:
				left.should_select = prop_value.values[0].left_value.get_type()
				if prop_value.values[0].right_value: right.should_select = prop_value.values[0].right_value.get_type()
	elif prop_value is SgfTypes.SgfPointList:
		l1.should_select = SgfTypes.SgfList
		list.should_select = SgfTypes.SgfPoint
	
	value.text = str(prop_value)
	key.text = prop_name
