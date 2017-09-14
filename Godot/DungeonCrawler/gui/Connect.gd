extends Panel


func onHostPressed():
	if (get_node("Name").text == ""):
		get_node("ErrorLabel").text="Invalid name!"
		return

	get_node("ErrorLabel").text=""

	gamestate.hostGame( get_node("Name").text )


func onJoinPressed():
	if (get_node("Name").text == ""):
		get_node("ErrorLabel").text="Invalid name!"
		return

	var ip = get_node("Ip").text
	if (not ip.is_valid_ip_address()):
		get_node("ErrorLabel").text="Invalid IPv4 address!"
		return

	get_node("ErrorLabel").text=""
	get_node("Buttons/Host").disabled=true
	get_node("Buttons/Join").disabled=true

	gamestate.joinGame( ip, get_node("Name").text )
