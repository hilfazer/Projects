extends "res://engine/agent/PlayerAgent.gd"


func _ready():
	var parent = get_parent()
	if parent is UnitBase:
		call_deferred( 'addUnit', parent )


func _onTravelRequest():
	pass
