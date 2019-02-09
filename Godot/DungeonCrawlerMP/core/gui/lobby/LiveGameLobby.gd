extends "LobbyBase.gd"


func _ready():
	pass


func _input(event):
	if event.is_action("ui_cancel"):
		queue_free()
		get_tree().set_input_as_handled()


func _unhandled_input(event):
	get_tree().set_input_as_handled()


func refreshLobby( players ):
	get_node("Players/PlayerList").clear()
	for pId in players:
		var playerString = players[pId] + " (" + str(pId) + ") "
		playerString += " (You)" if pId == get_tree().get_network_unique_id() else ""
		get_node("Players/PlayerList").add_item(playerString)
