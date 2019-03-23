extends Panel

const PlayerString = "%s (%s) %s"

var _maxUnits = 0                      setget setMaxUnits


func deleted(_a):
	assert(false)


func refreshLobby( clientList : Dictionary ):
	get_node("Players/PlayerList").clear()
	for pId in clientList:
		var playerString = PlayerString % [clientList[pId], pId, ""]
		get_node("Players/PlayerList").add_item( playerString )


func setMaxUnits( maxUnits : int ):
	_maxUnits = maxUnits
	get_node("UnitLimit").setMaximum( maxUnits )

