class_name MoveLegality
extends Node

@export var board_game: BoardGame

var _piece_selectable_criteria: Array[PieceSelectableCriteria]

func _ready():
	add_criteria(CurrentTurnCriteria.new())

func piece_selectable(position, piece: Piece) -> bool:
	for criteria in _piece_selectable_criteria:
		if not criteria.can_select_piece(board_game, position, piece):
			return false
	return true

func add_criteria(criteria: PieceSelectableCriteria):
	_piece_selectable_criteria.append(criteria)
