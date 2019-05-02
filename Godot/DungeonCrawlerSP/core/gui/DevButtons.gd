extends VBoxContainer

const UnitCreatorName = "UnitCreator"

var _mainMenu


func _ready():
	_mainMenu = get_parent()
	_mainMenu.get_node("Buttons/NewGame").connect("pressed", self, "deleteCreator")


func newCreator():
	var unitCreator = UnitCreator.new()
	unitCreator.name = UnitCreatorName
	$"/root/Connector".connect("newGameSceneConnected", unitCreator, "connectOnReady" )

	deleteCreator()
	$"/root".add_child( unitCreator )


func deleteCreator():
	if not $"/root".has_node(UnitCreatorName):
		return

	var creator = $"/root".get_node(UnitCreatorName)
	Utility.setFreeing( creator )


func _on_NewCreateButton_pressed():
	newCreator()
	_mainMenu.newGame()


func _on_CreateGameSpinBox_value_changed(value):
	Debug._createGameDelay = value


func _on_GameDelaySpinBox_value_changed(value):
	Debug._gameSceneDelay = value


class UnitCreator extends Node:
	var _creationDatum = makeUnitDatum( "" )

	func connectOnReady( newGameScene ):
		newGameScene.connect( "ready", self, "createUnit", [newGameScene] )


	func createUnit( newGameScene ):
		if is_queued_for_deletion():
			return

		var units = newGameScene._module.getUnitsForCreation()
		assert( units.size() > 0 )

		_creationDatum.name = units[0]
		newGameScene.get_node( "Lobby" ).createCharacter( _creationDatum )
		self.queue_free()


	func makeUnitDatum( unitName : String ):
		return { name = unitName }
