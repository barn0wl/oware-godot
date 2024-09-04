extends Object

class_name move

var Ihouse : house
enum moveType {collect, sow, capture}
var type : moveType
var Iseeds : Array[seed]

#this class makes use of the command pattern concept, where we transfor what could be a function
#or request, nto an object so that we can check for the rsult of a sequence of moves, or undo them

func _init(ihouse = null, itype = moveType.collect, iseeds: Array[seed] = []):
	self.Ihouse = ihouse
	self.type = itype
	self.Iseeds = iseeds

func execute():
	match type:
		moveType.collect:
			_collect()
		moveType.sow:
			_sow()
		moveType.capture:
			_capture()

func undo():
	match type:
		moveType.collect:
			_undo_collect()
		moveType.sow:
			_undo_sow()
		moveType.capture:
			_undo_capture()
	
func _collect() -> void:
	Iseeds = Ihouse.empty_house()
	
func _sow() -> void:
	#for this one, the iseeds argument that will be passed is the seed we want to be sowed into the house
	Ihouse.add_seed(Iseeds[0])

func _capture() -> void:
	Iseeds = Ihouse.empty_house()
	
func get_house() -> house:
	return Ihouse
	
func get_type() -> moveType:
	return type
	
func get_seeds() -> Array[seed]:
	return Iseeds

func _undo_collect():
	for s in Iseeds:
		Ihouse.add_seed(s)
		
func _undo_sow() -> seed:
	var rseed = Ihouse.remove_seed(Iseeds[0])
	return rseed

func _undo_capture():
	for s in Iseeds:
		Ihouse.add_seed(s)
		s.visible = true
