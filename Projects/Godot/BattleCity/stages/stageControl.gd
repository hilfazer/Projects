extends Node

const SpawnLightScn = preload("res://effects/SpawningLight.tscn")
const PlayerAgentGd = preload("res://actors/PlayerAgent.gd")
const ComputerAgentGd = preload("res://actors/ComputerAgent.gd")
const TankGd = preload("res://units/Tank.gd")
const StagePreparationGd = preload("res://stages/StagePreparation.gd")

# Player spawns need to start with string below and have number at the end
const TankPlayerPrefix = "TankPlayer"
# Spawns need to start with string below and have number at the end
const EnemySpawnPrefix = "EnemySpawn"
const PlayerSpawnPrefix = "PlayerSpawn"

const BRICKS_GROUP = "Bricks"
const PLAYERS_GROUP = "Players"
const ENEMIES_GROUP = "Enemies"

var m_playerCount = 2
var m_previousScene = null
onready var m_stagePreparation = StagePreparationGd.new()

var params = { playerCount = 1 }


func _ready():
	m_previousScene = SceneSwitcher.m_previousScene
	params = SceneSwitcher.m_sceneParams
	if ( params != null ):
		m_playerCount = params.playerCount


	m_stagePreparation.prepareStage(self)
	set_process( true )
	set_process_unhandled_input( true )
	prepareSpawns(m_playerCount)


func _unhandled_input(event):
	if (event.is_action_pressed("ui_cancel")):
		SceneSwitcher.switchScene( m_previousScene )


func init(previousScene, playerCount):
	m_previousScene = previousScene
	m_playerCount = playerCount


func processBulletCollision( bullet, collidingBody ):
	var collidingObject = collidingBody.get_parent()
	
	if collidingObject.is_in_group(BRICKS_GROUP):
		collidingObject.queue_free()
	
	if collidingObject.has_method("getTeam"):
		if collidingObject.getTeam() != bullet.getTeam() and collidingObject.has_method("destroy"):
			collidingObject.destroy()


func findNodesWithName(name):
	var nodes = Array()
	for child in get_children():
		if child.get_name().find(name) == 0:
			nodes.append(child)
	return nodes

func prepareSpawns(playerCount):
	var enemySpawns = findNodesWithName("EnemySpawn")
	var spawningData = []
	
	for enemyDefinition in get_node("EnemyDefinitions").get_children():
		var spawnNode = enemySpawns[randi() % enemySpawns.size()] \
			if enemyDefinition.spawnIndices.size() == 0 \
			else get_node( EnemySpawnPrefix + str(enemyDefinition.spawnIndices[randi() % enemyDefinition.spawnIndices.size()]) )
		spawningData.append( [enemyDefinition, spawnNode] )

	var spawnTimers = []
	for spawningDatum in spawningData:
		var enemySpawnTimer = Timer.new()
		enemySpawnTimer.set_wait_time( spawningDatum[0].spawnTime )
		enemySpawnTimer.set_one_shot(true)
		enemySpawnTimer.connect( "timeout", self, "startSpawningEnemy", [spawningDatum[0], spawningDatum[1]] )
		enemySpawnTimer.connect( "timeout", enemySpawnTimer, "queue_free" )
		spawnTimers.append( enemySpawnTimer )

	for playerId in range (1, playerCount+1):
		var playerTank = get_node( TankPlayerPrefix + str(playerId) )
		var playerSpawn = get_node( PlayerSpawnPrefix + str(playerId) )
		var playerSpawnTimer = Timer.new()
		playerSpawnTimer.set_wait_time( 0.5 )
		playerSpawnTimer.set_one_shot(true)
		playerSpawnTimer.connect( "timeout", self, "spawnPlayer", [playerTank, playerSpawn, playerId] )
		playerSpawnTimer.connect( "timeout", playerSpawnTimer, "queue_free" )
		spawnTimers.append( playerSpawnTimer )

	for spawnTimer in spawnTimers:
		self.add_child( spawnTimer )
		spawnTimer.start()
	
	
func startSpawningEnemy(enemyDefinition, spawnNode):
	if ( spawnNode == null ):
		return

	var light = SpawnLightScn.instance()
	self.add_child(light)
	light.set_pos(spawnNode.get_pos())
	light.connect("expired", self, "spawnEnemy", [enemyDefinition, spawnNode])
	light.glitterForSeconds(2)


func spawnEnemy(enemyDefinition, spawnNode):
	var enemyTank = enemyDefinition.get_node("TankPrototype").duplicate()
	enemyTank.set_pos( spawnNode.get_pos() )
	enemyTank.assignTeam( ENEMIES_GROUP )
	var computerAgent = Node.new()
	computerAgent.set_script( ComputerAgentGd )
	computerAgent.set_name("Agent")
	computerAgent.readDefinition( enemyDefinition )
	computerAgent.assignToTank( enemyTank )

	self.add_child(enemyTank)


func spawnPlayer(unit, spawnNode, playerId):
	var playersActions = [
		["player1_move_up", "player1_move_down", "player1_move_left", "player1_move_right", "player1_shoot"],
		["player2_move_up", "player2_move_down", "player2_move_left", "player2_move_right", "player2_shoot"]
	]

	var playerTank = unit.duplicate()
	playerTank.set_pos( spawnNode.get_pos() )
	playerTank.assignTeam( PLAYERS_GROUP )

	var playerAgent = Node.new()
	playerAgent.set_script( PlayerAgentGd )
	playerAgent.set_name("Agent")
	playerAgent.setActions( playersActions[playerId - 1] )
	playerAgent.assignToTank( playerTank )
	
	self.add_child(playerTank)