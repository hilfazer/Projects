extends Node
class_name AgentBase

var _units := SetWrapper.new()         setget deleted, getUnits
var _unitsInTree := []


func deleted(_a):
	assert(false)


func _init():
	_units.connect( "changed", self, "_updateActiveUnits" )


func addUnit( unit : UnitBase ):
	assert( unit )
	_units.add( [unit] )
	unit.connect( "tree_entered", self, "_setActive",   [unit] )
	unit.connect( "tree_exited" , self, "_setInactive", [unit] )
	unit.connect( "predelete",    self, "removeUnit",   [unit] )
	if unit.is_inside_tree():
		_setActive( unit )


func removeUnit( unit : UnitBase ):
	_units.remove( [unit] )


func _setActive( unit : UnitBase ):
	if not _unitsInTree.has( unit ):
		_unitsInTree.append( unit )


func _setInactive( unit : UnitBase ):
	_unitsInTree.remove( _unitsInTree.find( unit ) )


func _updateActiveUnits( units : Array ):
	var newUnitsInTree := []
	for activeUnit in _unitsInTree:
		if units.has( activeUnit ):
			newUnitsInTree.append( activeUnit )

	_unitsInTree = newUnitsInTree


func getUnits():
	return _units.container()


