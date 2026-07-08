class_name SgfPropUI
extends Control

@export var l1: SgfTypeButton
@export var list: SgfTypeButton
@export var left: SgfTypeButton
@export var right: SgfTypeButton
@export var value: TextEdit
@export var key: Label
@export var key_container: Control

signal value_changed(prop_name: String, prop_value: SgfTypes.SgfTypeBase)
signal prop_removed(prop_name: String)

var _prop_name: String

func create(prop_name: String, prop_value: SgfTypes.SgfTypeBase) -> void:
	_prop_name = prop_name
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
	
	if SgfTypes.PROP_HINTS.has(prop_name):
		key_container.tooltip_text = SgfTypes.PROP_HINTS[prop_name]

func parse_prop(text: String) -> Array[String]:
	var current_value := ""
	var values: Array[String] = []
	
	var l := len(text)
	var p := 0
	
	while p < l:
		if text[p] == "[":
			while p+1 < l:
				p += 1
				if text[p] == "\\":
					current_value += text[p]
					p += 1
					current_value += text[p]
				elif text[p] == "]":
					values.append(current_value)
					current_value = ""
					break
				else:
					current_value += text[p]
		else:
			p += 1 # Whitespace
	
	return values

func _on_save_button_pressed() -> void:
	value_changed.emit(_prop_name, l1.get_type().call(parse_prop(value.text)))


func _on_delete_button_pressed() -> void:
	prop_removed.emit(_prop_name)
