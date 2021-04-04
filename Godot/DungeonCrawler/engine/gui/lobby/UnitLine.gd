extends HBoxContainer

const UnitCreationDatumGd    = preload("res://engine/UnitCreationDatum.gd")

var _lineIdx       setget deleted, getIdx

signal deletePressed( lineIdx )


func deleted(_a):
	assert(false)


func initialize( idx ):
	_lineIdx = idx


func setUnit( unitDatum : UnitCreationDatumGd ):
	$"Name".text = unitDatum.name
	$"TextureRect".texture = unitDatum.icon


func onDeletePressed():
	emit_signal( "deletePressed", get_index() )


func getIdx():
	return _lineIdx

