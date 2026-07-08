extends MenuButton

@export var tree: SgfTreeVis
@export var root_index_label: Label
@onready var open_file_dialog: FileDialog = $OpenFileDialog
@onready var save_file_dialog: FileDialog = $SaveFileDialog
@onready var game_props_popup: GamePropsPopup = $GamePropsPopup

var current_sgf_file: SGF.SgfFile
var current_root_index := 0

func _ready() -> void:
	get_popup().index_pressed.connect(_on_index_pressed)
	open_file_dialog.file_selected.connect(_on_file_selected)
	save_file_dialog.file_selected.connect(_on_file_saved)
	new_sgf(SGF.SgfFile.create_empty(Vector2i(19,19)))
	tree.create_tree(current_sgf_file.roots[current_root_index])
	game_props_popup.popup_centered()

func _on_index_pressed(index: int) -> void:
	if index == 0:
		open_file_dialog.popup_file_dialog()
	elif index == 1:
		save_file_dialog.popup_file_dialog()
	elif index == 2:
		game_props_popup.type = GamePropsPopup.TYPE.NEW_TREE
		game_props_popup.show_popup()
	elif index == 3:
		game_props_popup.type = GamePropsPopup.TYPE.NEW_FILE
		game_props_popup.show_popup()

func _on_file_selected(path: String) -> void:
	new_sgf(SGF.SgfFile.new(FileAccess.open(path, FileAccess.READ).get_as_text()))

func _on_file_saved(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(current_sgf_file.serialize())

func new_sgf(sgf_file: SGF.SgfFile) -> void:
	current_sgf_file = sgf_file
	current_root_index = 0
	assert(len(current_sgf_file.roots) > 0)
	update_label()
	tree.create_tree(current_sgf_file.roots[current_root_index])

func new_root(node: SGF.SgfNode) -> void:
	assert(node.parent == null)
	current_sgf_file.roots.append(node)
	current_root_index = len(current_sgf_file.roots)-1
	update_label()
	tree.create_tree(current_sgf_file.roots[current_root_index])

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
