extends Control

const prop_scene: PackedScene = preload("res://scenes/sgf_prop.tscn")

var props: Array[Control] = []

func create(node: SGF.SgfNode) -> void:
	for i in props:
		i.queue_free()
	props.clear()
	
	for i in node.properties:
		var p: SgfPropUI = prop_scene.instantiate()
		#var l := Label.new()
		#l.text = "%s | %s | %s" % [i, node.properties[i].typename(), node.properties[i]]
		
		p.create(i, node.properties[i])
		props.append(p)
		add_child(p)

func _on_state_changed(_state: GameState, node: SGF.SgfNode) -> void:
	if node:
		create(node)
