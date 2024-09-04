extends Node

class_name move_manager

var moves_list : Array[move]

func add_move(iMove : move):
	moves_list.append(iMove)
	
func clear():
	moves_list = []

func get_capture_moves() -> Array[move]:
	var capture_moves_list: Array[move] = []
	var current_move : move = moves_list.pop_back()
	while current_move.get_type() == 2:
		capture_moves_list.append(current_move)
		current_move = moves_list.pop_back()
	return capture_moves_list
