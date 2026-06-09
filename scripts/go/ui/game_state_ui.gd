extends Label

func color_str(color: Stone.StoneColor) -> String:
	return {
		Stone.StoneColor.NONE: "None",
		Stone.StoneColor.WHITE: "White",
		Stone.StoneColor.BLACK: "Black",
		Stone.StoneColor.BOTH: "Both",
	}[color]

func _on_state_changed(state: GameState, node: SGF.SgfNode) -> void:
	text = "Move number: %d | To play: %s | Passed: %s | Black stones captured: %d | White stones captured: %d" % [state.move_number, color_str(state.to_play), color_str(state.passed), state.black_captured, state.white_captured]
	if node:
		var eval = node.get_evaluation()
		if eval:
			text += "\n" + eval
