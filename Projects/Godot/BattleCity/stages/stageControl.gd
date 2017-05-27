extends Node

const GlitterScn = preload("res://effects/Glitter.tscn")
const PlayerAgentGd = preload("res://actors/PlayerAgent.gd")
const ComputerAgentGd = preload("res://actors/ComputerAgent.gd")
const TankFactoryScn = preload("res://units/TankFactory.tscn")
const StagePreparationGd = preload("res://stages/StagePreparation.gd")
const EnemyDispatcherGd = preload("res://enemies/EnemyDispatcher.gd")

# Spawns need to start with string below and have number at the end
const EnemySpawnPrefix = "EnemySpawn"
const PlayerSpawnPrefix = "PlayerSpawn"
const BricksGroup = "Bricks"
const PlayersGroup = "Players"
const EnemiesGroup = "Enemies"
const EnemySpawnsGroup = "EnemySpawns"
const EnemySpawnDelay = 2
const FlagSpriteId = 70

onready var m_stagePreparation = StagePreparationGd.new()
onready var m_tankFactory = TankFactoryScn.instance()
var m_enemyDispatcher = EnemyDispatcherGd.new()
var m_cellIdMap
var m_params = { playerCount = 1 }
var m_enemyCounter

signal playersWon
signal playersLost


func _ready():
	set_process_unhandled_input( true )
	m_params = SceneSwitcher.m_sceneParams

	m_stagePreparation.prepareStage(self)
	m_cellIdMap = m_stagePreparation.m_cellIdMap
	
	m_enemyDispatcher.setStage(self)
	
	for definition in get_node("EnemyDefinitions").get_children():
		definition.get_node("TankPrototype").setStage(self)
	prepareSpawns(m_params.playerCount)
	
	self.connect("playersLost", Game, "onPlayersLost")
	self.connect("playersWon", Game, "onPlayersWon")


func _exit_tree():
	m_tankFactory.free()


func _unhandled_input(event):
	if (event.is_action_pressed("ui_cancel")):
		SceneSwitcher.switchScene( SceneSwitcher.m_previousScene )


func processBulletCollision( bullet, collidingBody ):
	var collidingObject = collidingBody.get_parent()
	if collidingObject.is_in_group(BricksGroup):
		collidingObject.queue_free()
	elif collidingObject.get_name() == "Eagle":
		collidingObject.get_node("Sprite").set_frame(FlagSpriteId)
		collidingObject.get_node("StaticBody2D").queue_free()
		emit_signal("playersLost")


func prepareSpawns(playerCount):
	m_enemyDispatcher.setSpawnNumber( get_tree().get_nodes_in_group(EnemySpawnsGroup).size() )
	m_enemyDispatcher.setDefinitions( get_node("EnemyDefinitions").get_children() )
	add_child(m_enemyDispatcher)
	m_enemyCounter = m_enemyDispatcher.getRemainingEnemies()

	var spawnTimers = []

	for playerId in range (1, playerCount+1):
		var playerTank = m_tankFactory.makeTankForPlayer(playerId)
		self.connect("exit_tree", playerTank, "free")
		var playerSpawn = get_node( PlayerSpawnPrefix + str(playerId) )
		var playerSpawnTimer = Timer.new()
		playerSpawnTimer.set_wait_time( 0.5 )
		playerSpawnTimer.connect( "timeout", self, "spawnPlayer", [playerTank, playerSpawn, playerId] )
		playerSpawnTimer.connect( "timeout", playerSpawnTimer, "queue_free" )
		spawnTimers.append( playerSpawnTimer )

	for spawnTimer in spawnTimers:
		self.add_child( spawnTimer )
		spawnTimer.start()
	
	
func startSpawningEnemy(enemyDefinition, spawnNode):
	if ( spawnNode == null ):
		return

	var glitter = GlitterScn.instance()
	self.add_child(glitter)
	glitter.set_pos(spawnNode.get_pos())
	glitter.connect("finished", self, "clearArea", [glitter.get_node("Area2D")])
	glitter.connect("finished", self, "spawnEnemy", [enemyDefinition, spawnNode])
	glitter.connect("finished", glitter, "queue_free")
	glitter.glitterForSeconds(EnemySpawnDelay)


func clearArea(area2d):
	var bodies = area2d.get_overlapping_bodies()
	for body in bodies:
		if (body.get_parent().has_method("destroy")):
			body.get_parent().destroy()


func spawnEnemy(enemyDefinition, spawnNode):
	var enemyTank = enemyDefinition.get_node("TankPrototype").duplicate()
	enemyTank.set_pos( spawnNode.get_pos() )
	enemyTank.setTeam( EnemiesGroup )
	var computerAgent = Node.new()
	computerAgent.set_script( ComputerAgentGd )
	computerAgent.readDefinition( enemyDefinition )
	computerAgent.assignToTank( enemyTank )
	self.add_child(enemyTank)
	enemyTank.connect("exit_tree", self, "onEnemyExitTree")


func spawnPlayer(playerTank, spawnNode, playerId):
	var playersActions = [
		["player1_move_up", "player1_move_down", "player1_move_left", "player1_move_right", "player1_shoot"],
		["player2_move_up", "player2_move_down", "player2_move_left", "player2_move_right", "player2_shoot"]
	]

	playerTank.setTeam( PlayersGroup )

	var playerAgent = Node.new()
	playerAgent.set_script( PlayerAgentGd )
	playerAgent.setActions( playersActions[playerId - 1] )
	playerAgent.assignToTank( playerTank )

	self.add_child(playerTank)
	self.disconnect("exit_tree", playerTank, "free")
	playerTank.set_pos( spawnNode.get_pos() )


func onEnemyExitTree():
	m_enemyCounter -= 1
	if m_enemyCounter == 0:
		emit_signal("playersWon")


