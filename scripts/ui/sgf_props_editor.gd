extends Control

signal node_edited(node: SGF.SgfNode)

const prop_scene: PackedScene = preload("res://scenes/sgf_prop.tscn")

var props: Array[SgfPropUI] = []
var _node: SGF.SgfNode
@export var add_line: LineEdit

func _ready():
	add_line.text_submitted.connect(add_prop)

func create(node: SGF.SgfNode) -> void:
	_node = node
	
	for i in props:
		i.queue_free()
	props.clear()
	
	for i in node.properties:
		create_prop(i, node.properties[i])
	
	add_line.get_parent().move_to_front()

func create_prop(prop_name, value) -> void:
	var p: SgfPropUI = prop_scene.instantiate()
	p.value_changed.connect(_on_prop_value_changed)
	p.prop_removed.connect(_on_prop_removed)
	p.create(prop_name, value)
	props.append(p)
	add_child(p)

func _on_state_changed(_state: GameState, node: SGF.SgfNode) -> void:
	if node:
		create(node)

func _on_prop_value_changed(prop_name: String, prop_value: SgfTypes.SgfTypeBase) -> void:
	if prop_value:
		_node.properties[prop_name] = prop_value
	node_edited.emit(_node)

func _on_prop_removed(prop_name: String) -> void:
	if prop_name in _node.properties:
		_node.properties.erase(prop_name)
	node_edited.emit(_node)

func add_prop(prop_name: String) -> void:
	if prop_name in _node.properties:
		return
	create_prop(prop_name, SgfTypes.SgfNone.new([]))
	add_line.get_parent().move_to_front()
	add_line.text = ""
	add_line.release_focus()
