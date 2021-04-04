extends VBoxContainer

const UnitCreatorName = "UnitCreator"

var _mainMenu


func _ready():
	_mainMenu = get_parent()
	_mainMenu.get_node("Buttons/NewGame").connect("pressed", self, "deleteCreator")


func newCreator():
	var unitCreator = UnitCreator.new()
	unitCreator.name = UnitCreatorName
# warning-ignore:return_value_discarded
	$"/root/Connector".connect("newGameSceneConnected", unitCreator, "connectOnReady" )

	deleteCreator()
	$"/root".add_child( unitCreator )


func deleteCreator():
	if not $"/root".has_node( UnitCreatorName ):
		return

	var creator = $"/root".get_node( UnitCreatorName )
	Utility.setFreeing( creator )


func _on_NewCreateButton_pressed():
	newCreator()
	_mainMenu.newGame()


class UnitCreator extends Node:
	var CharacterCreationScn   = preload("res://engine/gui/CharacterCreation.tscn")

	func connectOnReady( newGameScene ):
		newGameScene.connect( "ready", self, "createUnit", [newGameScene] )

	func createUnit( newGameScene ):
		if is_queued_for_deletion():
			return

		var characterCreation = CharacterCreationScn.instance()
		add_child(characterCreation)
		characterCreation.queue_free()
		characterCreation.initialize( newGameScene._module )
		var characterDatum = characterCreation.makeCharacter()

		newGameScene.get_node( "Lobby" ).createCharacter( characterDatum )
		self.queue_free()
