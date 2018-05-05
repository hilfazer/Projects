extends VBoxContainer


var m_mainMenu


func _ready():
	m_mainMenu = get_parent()
	
	
func newCreator():
	var unitCreator = UnitCreator.new()
	unitCreator.name = "UnitCreator"
	Connector.connect("newGameSceneConnected", unitCreator, "connectOnReady" )
	get_tree().get_root().add_child( unitCreator )


func _on_JoinCreateButton_pressed():
	newCreator()
	m_mainMenu.joinGame()


func _on_NewCreateButton_pressed():
	newCreator()
	m_mainMenu.newGame()




class UnitCreator extends Node:
	func connectOnReady( newGameScene ):
		newGameScene.connect( "ready", self, "createUnit", [newGameScene] )


	func createUnit( newGameScene ):

		var units = newGameScene.m_module_.getUnitsForCreation()
		assert( units.size() > 0 )

		var creationData = {
			"path" : units[0],
			"owner" : 0 if not get_tree().has_network_peer() else get_tree().get_network_unique_id()
		}

		newGameScene.get_node( "Lobby" ).createCharacter( creationData )
		self.queue_free()