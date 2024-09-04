@icon("res://main/hand/open-hand-svgrepo-com.svg")

extends Node2D

class_name hand

var current_seeds: Array[seed]

func set_current_seeds(seed_list: Array[seed]):
	current_seeds = seed_list

func set_seeds_pos():
	for s in current_seeds:
		s.global_position = global_position

func get_current_seeds() -> Array[seed]:
	return current_seeds

func get_seed_count():
	return current_seeds.size()
