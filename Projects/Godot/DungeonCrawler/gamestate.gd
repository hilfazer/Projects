extends Node


const DwarfScn = preload("res://units/Dwarf.tscn")
const WorldScn = preload("res://levels/World.tscn")

# Default game port
const DEFAULT_PORT = 10567

# Max number of players
const MAX_PEERS = 12

# Name for my player
var player_name

# Names for remote players in id:name format, including host
var players = {}

# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)
signal sendVariable(name, value)
signal networkPeerChanged()

# Callback from SceneTree
func _player_connected(id):
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.
	pass

# Callback from SceneTree
func _player_disconnected(id):
	if (get_tree().is_network_server()):
		if (isGameInProgress()): # Game is in progress
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)


func _connected_ok():
	assert(not get_tree().is_network_server())
	# Registration of a client beings here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	register_player(get_tree().get_network_unique_id(), player_name)
	emit_signal("connection_succeeded")


func _server_disconnected():
	assert(not get_tree().is_network_server())
	emit_signal("game_error", "Server disconnected")
	end_game()


func _connected_fail():
	assert(not get_tree().is_network_server())
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions

remote func register_player(id, name):
	if (get_tree().is_network_server()):
		for p_id in players: # Then, for each remote player
			rpc_id(id, "register_player", p_id, players[p_id]) # Send player to new dude
			rpc_id(p_id, "register_player", id, name) # Send new dude to player

	players[id] = name
	emit_signal("player_list_changed")

remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")


var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if (not id in players_ready):
		players_ready.append(id)

	if (players_ready.size() == players.size()):
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(name):
	player_name = name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	setNetworkPeer(host)
	

func join_game(ip, name):
	player_name = name
	if (get_tree().is_network_server()):
		register_player(get_tree().get_network_unique_id(), player_name)
		return

	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	setNetworkPeer(host)

func get_player_list():
	return players

func get_player_name():
	return player_name


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	
func begin_game():
	assert(get_tree().is_network_server())

	for p in players:
		rpc_id(p, "pre_start_game", players)

	pre_start_game(players)


remote func pre_start_game(playersOnServer):
	# Change scene
	var world = WorldScn.instance()
	get_tree().get_root().add_child(world)

	var spawnNumber = 1
	for pid in playersOnServer:
		if spawnNumber > 4:
			break

		var dwarf = DwarfScn.instance()
		dwarf.set_position( world.get_node("Spawn"+str(spawnNumber)).get_position() )
		dwarf.set_network_master(pid)
		dwarf.set_name(str(pid))
		var nameLabel = Label.new()
		nameLabel.text = players[pid]
		dwarf.add_child(nameLabel)
		world.add_child(dwarf)
		spawnNumber += 1

	if (not get_tree().is_network_server()):
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!


func end_game():
	if (isGameInProgress()):
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking
	emit_signal("sendVariable", "network_host_ID", null)
	
	
func isGameInProgress():
	return has_node("/root/World")
	
	
func setNetworkPeer(host):
	get_tree().set_network_peer(host)
	
	var peerId = str(host.get_instance_ID()) if get_tree().has_network_peer() else null
	if peerId != null and get_tree().is_network_server():
		peerId += " (server)" 
	emit_signal("sendVariable", "network_host_ID", peerId )
	emit_signal("networkPeerChanged")
