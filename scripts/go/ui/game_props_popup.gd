class_name GamePropsPopup
extends Popup

@onready var width: SpinBox = $MarginContainer/GridContainer/HBoxContainer/Width
@onready var height: SpinBox = $MarginContainer/GridContainer/HBoxContainer/Height

signal new_tree_created(root: SGF.SgfNode)
signal new_file_created(file: SGF.SgfFile)

enum TYPE {
	NEW_TREE,
	NEW_FILE,
}

const TITLES = {
	TYPE.NEW_TREE: "New tree",
	TYPE.NEW_FILE: "New file",
}

var type: TYPE = TYPE.NEW_TREE

func show_popup():
	title = TITLES[type]
	popup_centered()


func _on_button_pressed() -> void:
	var new_file = SGF.SgfFile.create_empty(Vector2(int(width.value), int(height.value)))
	if type == TYPE.NEW_TREE:
		new_tree_created.emit(new_file.roots[0])
	else:
		new_file_created.emit(new_file)
