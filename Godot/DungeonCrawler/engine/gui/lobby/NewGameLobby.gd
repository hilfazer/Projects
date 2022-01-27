extends "LobbyBase.gd"

const UnitLineScn            = preload("./UnitLine.tscn")
const CharacterCreationScn   = preload("res://engine/gui/CharacterCreation.tscn")
const UnitCreationDataGd    = preload("res://engine/units/UnitCreationData.gd")

var _module                            setget setModule

var _unitsCreationData = []            setget deleted
var _characterCreationWindow           setget deleted
onready var _unitList = $"Players/Scroll/UnitList"
onready var _unitLimit = $"UnitLimit"
onready var _createCharacter = $"CreateCharacter"


signal unitNumberChanged(newNumber)


func deleted(_a):
	assert(false)


func _ready():
	connect("unitNumberChanged", self, "onUnitNumberChanged")


func refreshLobby( clientList ):
	.refreshLobby( clientList )


func clearUnits():
	_unitsCreationData.clear()
	for child in _unitList.get_children():
		child.queue_free()

	emit_signal("unitNumberChanged", _unitsCreationData.size())


func addUnit( creationDatum : UnitCreationDataGd ):
	if _unitsCreationData.size() >= _maxUnits:
		return false
	else:
		_unitsCreationData.append( creationDatum )
		emit_signal("unitNumberChanged", _unitsCreationData.size())
		return addUnitLine( _unitsCreationData.size() - 1 )


func addUnitLine( unitIdx ):
	var unitLine = UnitLineScn.instance()

	_unitList.add_child( unitLine )
	unitLine.initialize( unitIdx )
	unitLine.setUnit( _unitsCreationData[unitIdx] )
	unitLine.connect("deletePressed", self, "onDeleteUnit")
	return true


func createCharacter( creationDatum : UnitCreationDataGd ):
	addUnit( creationDatum )


func removeUnit( unitIdx ):
	_unitsCreationData.remove( unitIdx )
	_unitList.get_child( unitIdx ).queue_free()
	emit_signal("unitNumberChanged", _unitsCreationData.size())


func onDeleteUnit( unitIdx ):
	removeUnit( unitIdx )


func onCreateCharacterPressed():
	if _characterCreationWindow != null:
		return

	_characterCreationWindow = CharacterCreationScn.instance()
	add_child( _characterCreationWindow )
	_characterCreationWindow.connect("tree_exited", self, "removeCharacterCreationWindow")
	_characterCreationWindow.connect("madeCharacter", self, "createCharacter")
	_characterCreationWindow.initialize(_module)


func removeCharacterCreationWindow():
	if not _characterCreationWindow.is_queued_for_deletion():
		_characterCreationWindow.queue_free()

	_characterCreationWindow = null


func onUnitNumberChanged( newNumber ):
	assert(newNumber <= _maxUnits)
	_unitLimit.setCurrent( newNumber )
	_createCharacter.disabled = _unitsCreationData.size() == _maxUnits


func setModule( module ):
	_module = module


func setMaxUnits( maxUnits ):
	.setMaxUnits( maxUnits )
	_createCharacter.disabled = _unitsCreationData.size() == _maxUnits

