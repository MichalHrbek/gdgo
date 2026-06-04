extends Label


func _on_state_changed(state: GameState, _node: RefCounted) -> void:
	text = state.comment
