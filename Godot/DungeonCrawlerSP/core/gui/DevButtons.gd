extends VBoxContainer

const UtilityGd              = preload("res://core/Utility.gd")

const UnitCreatorName = "UnitCreator"

var m_mainMenu


func _ready():
	m_mainMenu = get_parent()
	m_mainMenu.get_node("Buttons/NewGame").connect("pressed", self, "deleteCreator")


func newCreator():
	var unitCreator = UnitCreator.new()
	unitCreator.name = UnitCreatorName
	Connector.connect("newGameSceneConnected", unitCreator, "connectOnReady" )

	deleteCreator()
	$"/root".add_child( unitCreator )


func deleteCreator():
	if not $"/root".has_node(UnitCreatorName):
		return

	var creator = $"/root".get_node(UnitCreatorName)
	UtilityGd.setFreeing( creator )


func _on_NewCreateButton_pressed():
	newCreator()
	m_mainMenu.newGame()


func _on_CreateGameSpinBox_value_changed(value):
	Debug.m_createGameDelay = value


func _on_GameDelaySpinBox_value_changed(value):
	Debug.m_gameSceneDelay = value


class UnitCreator extends Node:
	var m_creationDatum = makeUnitDatum( "" )

	func connectOnReady( newGameScene ):
		newGameScene.connect( "ready", self, "createUnit", [newGameScene] )


	func createUnit( newGameScene ):
		if is_queued_for_deletion():
			return

		var units = newGameScene.m_module.getUnitsForCreation()
		assert( units.size() > 0 )

		m_creationDatum.name = units[0]
		newGameScene.get_node( "Lobby" ).createCharacter( m_creationDatum )
		self.queue_free()


	func makeUnitDatum( unitName : String ):
		return { name = unitName }
