extends HFlowContainer

@export var player_color: Stone.StoneColor

@export var color_rect: Control
@export var name_label: Control
@export var rank_label: Control
@export var team_label: Control
@export var time_label: Control
@export var by_label: Control
@export var prisoners_label: Control

func update(player: Player):
	if player.color == Stone.StoneColor.WHITE: color_rect.self_modulate = Color.WHITE
	elif player.color == Stone.StoneColor.BLACK: color_rect.self_modulate = Color.BLACK

	name_label.visible = player.name != ""
	rank_label.visible = player.rank != ""
	team_label.visible = player.team != ""
	by_label.visible = player.moves_left != 0
	
	name_label.text = "Name: %s" % player.name
	rank_label.text = "Rank: %s" % player.rank
	team_label.text = "Team: %s" % player.team
	time_label.text = "Time left: %.2fs" % player.time_left
	by_label.text = "Byo-yomi: %d" % player.moves_left
	prisoners_label.text = "Enemy prisoners: %d" % player.enemy_prisoners


func _on_state_changed(state: GameState, _node: SGF.SgfNode) -> void:
	if player_color == Stone.StoneColor.WHITE:
		update(state.white_player)
	elif player_color == Stone.StoneColor.BLACK:
		update(state.black_player)
