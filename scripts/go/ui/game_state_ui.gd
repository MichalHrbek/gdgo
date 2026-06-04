extends Label

func color_str(color: Stone.StoneColor) -> String:
	return {
		Stone.StoneColor.NONE: "None",
		Stone.StoneColor.WHITE: "White",
		Stone.StoneColor.BLACK: "Black",
		Stone.StoneColor.BOTH: "Both",
	}[color]

func _on_state_changed(state: GameState, _node: RefCounted) -> void:
	text = "To play: %s | Passed: %s | Black stones captured: %d | White stones captured: %d" % [color_str(state.to_play), color_str(state.passed), state.black_captured, state.white_captured]
