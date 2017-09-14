extends Panel


func onHostPressed():
	if (get_node("Name").text == ""):
		get_node("ErrorLabel").text="Invalid name!"
		return

	get_node("ErrorLabel").text=""

	var name = get_node("Name").text
	gamestate.hostGame(name)
