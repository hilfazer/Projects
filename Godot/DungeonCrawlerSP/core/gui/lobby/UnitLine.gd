extends HBoxContainer

const UnitCreationDatumGd    = preload("res://core/UnitCreationDatum.gd")

var _lineIdx       setget deleted, getIdx

signal acquired(ownerId)
signal released()
signal deletePressed( lineIdx )


func deleted(_a):
	assert(false)


func initialize( idx ):
	_lineIdx = idx


func acquire( playerId ):
	get_node("Owner").text = str(playerId)
	get_node("Acquire").hide()
	emit_signal("acquired", playerId)
	get_node("Delete").set_disabled(false)


func release( playerId ):
	get_node("Owner").text = "0"
	get_node("Acquire").show()
	get_node("Release").hide()
	emit_signal("released")
	get_node("Delete").set_disabled(true)


func setUnit( unitDatum : UnitCreationDatumGd ):
	get_node("Name").text = unitDatum.name
	$"TextureRect".texture = unitDatum.icon


func onDeletePressed():
	emit_signal("deletePressed", get_index())


func getIdx():
	return _lineIdx

