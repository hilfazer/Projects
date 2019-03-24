extends "LobbyBase.gd"

const CharacterCreationScn   = preload("res://core/gui/CharacterCreation.tscn")
const UnitLineScn            = preload("UnitLine.tscn")

var _module                            setget setModule
# array of dicts
var _unitsCreationData = []            setget deleted
var _characterCreationWindow           setget deleted


signal unitNumberChanged( unitNumber )


func deleted(_a):
	assert(false)


func _ready():
	connect("unitNumberChanged", self, "onUnitNumberChanged")


func refreshLobby( clientList ):
	.refreshLobby( clientList )


func deleteUnownedUnits( playerIds ):
	var indicesToRemove = []
	for unitIdx in range( _unitsCreationData.size() ):
		if not _unitsCreationData[unitIdx].owner in playerIds:
			indicesToRemove.append( unitIdx )
	indicesToRemove.sort_custom(Utility, "greaterThan")

	for idx in indicesToRemove:
		removeUnit( idx )


func clearUnits():
	_unitsCreationData.clear()
	for child in get_node("Players/Scroll/UnitList").get_children():
		child.queue_free()

	emit_signal("unitNumberChanged", _unitsCreationData.size())


func addUnit( creationDatum : Dictionary ):
	if _unitsCreationData.size() >= _maxUnits:
		return false
	else:
		_unitsCreationData.append( creationDatum )
		emit_signal("unitNumberChanged", _unitsCreationData.size())
		return addUnitLine( _unitsCreationData.size() - 1 )


func requestAddUnit( creationDatum : Dictionary ):
	addUnit( creationDatum )


func addUnitLine( unitIdx ):
	var unitLine = UnitLineScn.instance()

	get_node("Players/Scroll/UnitList").add_child( unitLine )
	unitLine.initialize( unitIdx )
	unitLine.setUnit( _unitsCreationData[unitIdx].name )
	unitLine.connect("deletePressed", self, "onDeleteUnit")
	return true


func createCharacter( creationDatum : Dictionary ):
	addUnit( creationDatum )


func removeUnit( unitIdx ):
	_unitsCreationData.remove( unitIdx )
	get_node("Players/Scroll/UnitList").get_child( unitIdx ).queue_free()
	emit_signal("unitNumberChanged", _unitsCreationData.size())


func onDeleteUnit( unitIdx ):
	removeUnit( unitIdx )


func onCreateCharacterPressed():
	if _characterCreationWindow != null:
		return

	_characterCreationWindow = CharacterCreationScn.instance()
	add_child(_characterCreationWindow)
	_characterCreationWindow.connect("tree_exited", self, "removeCharacterCreationWindow")
	_characterCreationWindow.connect("madeCharacter", self, "createCharacter")
	_characterCreationWindow.initialize(_module)


func removeCharacterCreationWindow():
	if not _characterCreationWindow.is_queued_for_deletion():
		_characterCreationWindow.queue_free()

	_characterCreationWindow = null


func onUnitNumberChanged( unitNumber ):
	get_node("UnitLimit").setCurrent( _unitsCreationData.size() )
	get_node("CreateCharacter").disabled = _unitsCreationData.size() == _maxUnits


func setModule( module ):
	_module = module


func setMaxUnits( maxUnits ):
	.setMaxUnits( maxUnits )
	get_node("CreateCharacter").disabled = _unitsCreationData.size() == _maxUnits

