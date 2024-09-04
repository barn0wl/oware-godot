extends Node

@onready var myboard : board = %board
@onready var myhand : hand = %hand
@onready var myinfolabel : Label = %game_info
@onready var harvestTimer : Timer = %harvest_timer
@onready var score_label : Label = %score_label
@onready var myMoveManager : move_manager = %"move manager"
var current_player : bool
var p1_score : int
var p2_score : int
enum GAMESTATES {GAME_OVER, AWAIT_INPUT, SOWING, CAPTURE}
var current_gamestate : GAMESTATES
var starting_house : house
var current_house : house

signal turn_start()
signal start_sowing()
signal finished_sowing()
signal start_capture()
signal capture_finished()

func _ready():
	current_player = randi_range(0,1)
	for h in myboard.get_house_list():
		h.house_clicked.connect(_on_house_clicked.bind())
	turn_start.emit()

func collect_seeds(ihouse : house):
	var new_move = move.new(ihouse, 0)
	new_move.execute()
	myMoveManager.add_move(new_move)
	var collected_seeds = new_move.get_seeds()
	myhand.set_current_seeds(collected_seeds)
	myhand.set_seeds_pos()
	
	harvestTimer.start(0.4)
	await harvestTimer.timeout
	start_sowing.emit()

func _on_house_clicked(ihouse: house):
	if current_gamestate == GAMESTATES.AWAIT_INPUT && current_player == ihouse.get_player():
		starting_house = ihouse
		current_house = starting_house
		collect_seeds(ihouse)
		myhand.global_position = current_house.global_position

func sowing():
	if current_house == starting_house:
		current_house = myboard.next_house(current_house)
	else:
		myhand.global_position = current_house.global_position
		var seed_to_add : Array[seed] = [myhand.get_current_seeds().pop_front()]
		var new_move = move.new(current_house, 1, seed_to_add)
		new_move.execute()
		myMoveManager.add_move(new_move)
		current_house.update_seeds_position()
		if myhand.get_seed_count() >= 1:
			current_house = myboard.next_house(current_house)
			
		harvestTimer.start(0.4)
		await harvestTimer.timeout

func _on_turn_start():
	current_player = not current_player
	current_gamestate = GAMESTATES.AWAIT_INPUT
	myinfolabel.text = 'Its player %s turn to play!' % int(current_player)

func _on_start_sowing():
	current_gamestate = GAMESTATES.SOWING
	while myhand.get_seed_count() > 0 :
		await sowing()
	finished_sowing.emit()

func _on_finished_sowing():
	myhand.global_position = Vector2(53, 185)
	if current_house.is_capturable():
		start_capture.emit()
	else:
		print(myMoveManager.moves_list)
		myMoveManager.clear()
		if not game_over_check():
			turn_start.emit()

func _on_start_capture():
	current_gamestate = GAMESTATES.CAPTURE
	while current_house.is_capturable() && current_player == not current_house.get_player():
		print('capturable')
		capture(current_house)
		current_house = myboard.prev_house(current_house)
		harvestTimer.start(0.4)
		await harvestTimer.timeout
	capture_finished.emit()

func capture(ihouse: house):
	match current_player:
		false:
			var new_move = move.new(ihouse, 2)
			new_move.execute()
			myMoveManager.add_move(new_move)
			p1_score += new_move.get_seeds().size()
			for s in new_move.get_seeds():
				s.visible = false
			update_score()
		true:
			var new_move = move.new(ihouse, 2)
			new_move.execute()
			myMoveManager.add_move(new_move)
			p2_score += new_move.get_seeds().size()
			for s in new_move.get_seeds():
				s.visible = false
			update_score()

func update_score():
	score_label.text = 'p1: %s - p2: %s' % [p1_score, p2_score]
	print('updated score')

func _on_capture_finished():
	if legal_capture():
		print(myMoveManager.moves_list)
		myMoveManager.clear()
		if not game_over_check():
			turn_start.emit()
	else:
		undo_capture()
		print('capture was forfeited because illegal')
		myMoveManager.clear()
		if not game_over_check():
			turn_start.emit()

func legal_capture() -> bool:
	match current_player as int:
		0:
			var half1 : Array[house] = myboard.get_house_list().slice(0, 6)
			for Ihouse in half1:
				if Ihouse.get_seed_count() != 0:
					return true
				else:
					pass
			return false
		1:
			var half2 : Array[house] = myboard.get_house_list().slice(6, 12)
			for Ihouse in half2:
				if Ihouse.get_seed_count() != 0:
					return true
				else:
					pass
			return false
		_:
			return false

func undo_capture() -> void:
	print(myMoveManager.get_capture_moves())
	for imove in myMoveManager.get_capture_moves():
		imove.undo()

func game_over_check() -> bool:
	if p1_score >= 25 || p2_score >= 25:
		return true
	elif p1_score == 24 && p2_score == 24:
		return true
	else:
		return false
