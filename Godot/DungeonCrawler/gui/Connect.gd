extends Panel


func isValidPlayerName( name ):
	if name.length() == 0:
		return false
	else:
		return true


func validate():
	var ip = get_node("Ip").text
	if (not ip.is_valid_ip_address()):
		get_node("ErrorLabel").text="Invalid IPv4 address!"
		return false

	var playerName = get_node("PlayerName").text
	if not isValidPlayerName( playerName ):
		get_node("ErrorLabel").text="Invalid player name"
		return false

	get_node("ErrorLabel").text=""
	return true
