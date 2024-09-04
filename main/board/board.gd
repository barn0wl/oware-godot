@icon("res://main/board/board.svg")

extends Node2D

class_name board

var tempseed = preload("res://main/seed/seed.tscn")
@onready var half1 = %board_half
@onready var half2 = %board_half2
var houseList : Array[house]

func _ready():
	initialize()

func initialize():
	set_house_list()
	for i in range(12):
		var Ihouse = house_with_index(i)
		for j in range(4):
			var new_seed = tempseed.instantiate()
			add_child(new_seed)
			Ihouse.add_seed(new_seed)
		Ihouse.update_seeds_position()

func house_with_index(id : int) -> house:
	for h in houseList:
		if h.get_id() == id:
			return h
	return null

func set_house_list() -> void:
	for h in half1.get_children():
		if h is house:
			houseList.append(h as house)
	for h in half2.get_children():
		if h is house:
			houseList.append(h as house)

func get_house_list() -> Array[house]:
	return houseList

func next_house(c_house: house) -> house:
	var id : int = c_house.get_id()
	if id > 0 && id <= 11 :
		return house_with_index(id - 1)
	elif id == 0 :
		return house_with_index(11)
	return null
	
func prev_house(c_house: house) -> house:
	var id : int = c_house.get_id()
	if id >= 0 && id < 11 :
		return house_with_index(id + 1)
	elif id == 11 :
		return house_with_index(0)
	return null

func gethalf(id : int) -> Node2D:
	match id:
		1:
			return half1
		2:
			return half2
		_:
			return null
