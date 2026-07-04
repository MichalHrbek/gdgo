extends MenuButton

@export var tree: SgfTreeVis
@export var root_index_label: Label
@onready var file_dialog: FileDialog = $FileDialog

var current_sgf_file: SGF.SgfFile = SGF.SgfFile.create_empty(Vector2i(19,19))
var current_root_index := 0

func _ready() -> void:
	get_popup().index_pressed.connect(_on_index_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	tree.create_tree(current_sgf_file.roots[current_root_index])

func _on_index_pressed(index: int) -> void:
	if index == 0:
		open_file_menu()

func open_file_menu() -> void:
	file_dialog.popup_file_dialog()

func _on_file_selected(path: String) -> void:
	current_sgf_file = SGF.SgfFile.new(FileAccess.open(path, FileAccess.READ).get_as_text())
	current_root_index = 0
	assert(len(current_sgf_file.roots) > 0)
	tree.create_tree(current_sgf_file.roots[current_root_index])
	update_label()

func update_label() -> void:
	if not current_sgf_file:
		root_index_label.text = ""
	else:
		root_index_label.text = "%d/%d" % [current_root_index+1, len(current_sgf_file.roots)]

func next_root() -> void:
	if not current_sgf_file or current_root_index+1 >= len(current_sgf_file.roots):
		return
	
	current_root_index += 1
	update_label()
	tree.create_tree(current_sgf_file.roots[current_root_index])


func prev_root() -> void:
	if not current_sgf_file or current_root_index-1 < 0:
		return
	
	current_root_index -= 1
	update_label()
	tree.create_tree(current_sgf_file.roots[current_root_index])
