extends Panel


func onHostPressed():
	if (get_node("Name").text == ""):
		get_node("ErrorLabel").text="Invalid name!"
		return

	get_node("ErrorLabel").text=""
	Network.hostGame( get_node("Name").text )


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

	Network.joinGame( ip, get_node("Name").text )


func onConnectionFailed():
	get_node("Buttons/Host").disabled=false
	get_node("Buttons/Join").disabled=false
	get_node("ErrorLabel").set_text("Connection failed.")


func onGameEnded():
	get_node("Buttons/Host").disabled=false
	get_node("Buttons/Join").disabled=false


func onGameError(errtxt):
	get_node("ErrorPopup").dialog_text=errtxt
	get_node("ErrorPopup").popup_centered_minsize()
	get_node("Buttons/Host").disabled=false
	get_node("Buttons/Join").disabled=false
	
	
func onStopPressed():
	get_node("Buttons/Stop").disabled= true
	
	
func onNetworkPeerChanged():
	get_node("Buttons/Stop").disabled= not get_tree().has_network_peer()
	