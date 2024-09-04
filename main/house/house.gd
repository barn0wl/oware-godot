@icon("res://main/house/house.svg")

extends Node2D

class_name house

@export var index: int
@export var seeds: Array[seed]
@export var player_owner : bool
signal house_clicked(chosen_house: house)

func _init(id: int = 0):
	self.index = id
	self.player_owner = index > 5
	
func get_id() -> int:
	return index

func empty_house() -> Array[seed]:
	var list = seeds
	seeds = []
	return list
	
func get_seeds():
	return seeds
	
func get_seed_count() -> int:
	return seeds.size()
	
func get_player() -> bool:
	return player_owner

func add_seed(myseed : seed) -> void:
	seeds.append(myseed)

func _on_area_2d_input_event(_viewport, _event, _shape_idx):
	if Input.is_action_pressed("click") && get_seed_count() > 0:
		house_clicked.emit(self)

func update_seeds_position():
	const MAX_L_SPREAD = 3
	const PAD = 8
	
	if get_seed_count() != 0 :
		var l_spread = MAX_L_SPREAD if get_seed_count() > MAX_L_SPREAD else get_seed_count()
		var v_spread = ceil(float(get_seed_count()) / MAX_L_SPREAD)
		var canv_length = PAD * (l_spread - 1)
		var canv_height = PAD * (v_spread - 1)
		var starting_point = Vector2(global_position.x - canv_length/2, global_position.y - canv_height/2)
		for s in get_seeds():
			var s_id = get_seeds().find(s)
			s.global_position = Vector2(starting_point.x + (s_id % MAX_L_SPREAD) * PAD, starting_point.y + floor(float(s_id)/MAX_L_SPREAD) * PAD)
	else:
		return
		
func is_capturable() -> bool:
	if get_seed_count() == 2 || get_seed_count() == 3:
		return true
	else:
		return false

func remove_seed(iseed : seed) -> seed:
	var seedId = seeds.find(iseed)
	var rseed = seeds.pop_at(seedId)
	return rseed
