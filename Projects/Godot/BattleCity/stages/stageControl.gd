extends Node

const GlitterScn = preload("res://effects/Glitter.tscn")
const PlayerAgentGd = preload("res://actors/PlayerAgent.gd")
const ComputerAgentGd = preload("res://actors/ComputerAgent.gd")
const TankFactoryScn = preload("res://units/TankFactory.tscn")
const StagePreparationGd = preload("res://stages/StagePreparation.gd")
const EnemyDispatcherGd = preload("res://enemies/EnemyDispatcher.gd")
const ShieldScn = preload("res://effects/Shield.tscn")
const ShieldGd = preload("res://powerups/Shield.gd")


# Spawns need to start with string below and have number at the end
const EnemySpawnPrefix = "EnemySpawn"
const PlayerSpawnPrefix = "PlayerSpawn"
const BricksGroup = "Bricks"
const PlayersGroup = "Players"
const EnemiesGroup = "Enemies"
const EnemySpawnsGroup = "EnemySpawns"
const EnemySpawnDelay = 2
const PlayerSpawnDelay = 1.5
const FlagSpriteId = 70
const SizeInTiles = Vector2(13, 13)

onready var m_stagePreparation = StagePreparationGd.new()
onready var m_tankFactory = TankFactoryScn.instance()
onready var m_cellSize = get_node("Frame/TileMap").get_cell_size()
var m_enemyDispatcher = EnemyDispatcherGd.new()
var m_params = { 
	playerData = {} 
}
var m_enemyCounter

signal playersWon
signal playersLost


func _ready():
	if ( SceneSwitcher.m_sceneParams != null ):
		m_params = SceneSwitcher.m_sceneParams

	m_stagePreparation.prepareStage(self)
	m_enemyDispatcher.setStage(self)

	for definition in get_node("EnemyDefinitions").get_children():
		definition.get_node("TankPrototype").setStage(self)
	prepareSpawns( m_params.playerData.size() )

	self.connect("playersLost", Game, "onPlayersLost")
	self.connect("playersWon", Game, "onPlayersWon")

	get_node("Frame").setPlayerLives(1, m_params.playerData[1].lives)
	if ( m_params.playerData.has(2) ):
		get_node("Frame").setPlayerLives(2, m_params.playerData[2].lives)


func _exit_tree():
	m_tankFactory.free()


func processBulletCollision( bullet, collidingBody ):
	var collidingObject = collidingBody.get_parent()
	if collidingObject.is_in_group(BricksGroup):
		collidingObject.queue_free()
	elif collidingObject.get_name() == "Eagle":
		collidingObject.get_node("Sprite").set_frame(FlagSpriteId)
		collidingObject.get_node("StaticBody2D").queue_free()
		emit_signal("playersLost")
		disconnect("playersWon", Game, "onPlayersWon")


func prepareSpawns(playerCount):
	m_enemyDispatcher.setSpawnNumber( get_tree().get_nodes_in_group(EnemySpawnsGroup).size() )
	m_enemyDispatcher.setDefinitions( get_node("EnemyDefinitions").get_children() )
	add_child(m_enemyDispatcher)
	m_enemyCounter = m_enemyDispatcher.getRemainingEnemies()
	get_node("Frame").placeEnemyIcons((m_enemyCounter + 1) / 2)

	for playerId in range (1, playerCount+1):
		startSpawningPlayer(playerId, 0.5)


func startSpawningPlayer(playerId, delay):
		var playerTank = m_tankFactory.makeTankForPlayer(playerId)
		self.connect("exit_tree", playerTank, "free")
		var playerSpawn = get_node( PlayerSpawnPrefix + str(playerId) )

		var playerSpawnTimer = Timer.new()
		playerSpawnTimer.set_wait_time( delay )
		playerSpawnTimer.connect( "timeout", self, "spawnPlayer", [playerTank, playerSpawn, playerId] )
		playerSpawnTimer.connect( "timeout", playerSpawnTimer, "queue_free" )
		self.add_child( playerSpawnTimer )
		playerSpawnTimer.start()
	
	
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
	var enemyTank = enemyDefinition.get_node("TankPrototype")
	enemyTank.set_pos( spawnNode.get_pos() )
	enemyTank.setTeam( EnemiesGroup )
	var computerAgent = Node.new()
	computerAgent.set_script( ComputerAgentGd )
	computerAgent.readDefinition( enemyDefinition )
	computerAgent.assignToTank( enemyTank )
	enemyDefinition.remove_child(enemyTank)
	self.add_child(enemyTank)
	enemyTank.connect("exit_tree", self, "onEnemyExitTree")


func spawnPlayer(playerTank, spawnNode, playerId):
	playerTank.setTeam( PlayersGroup )

	var playerAgent = m_params.playerData[playerId].agent.duplicate()
	m_params.playerData[playerId].agent.copyState(playerAgent)
	playerAgent.assignToTank( playerTank )

	self.add_child(playerTank)
	self.disconnect("exit_tree", playerTank, "free")
	playerTank.connect("destroyed", self, "onPlayerTankDestroyed", [playerId])
	playerTank.set_pos( spawnNode.get_pos() )
	
	var shieldEffect = ShieldScn.instance()
	shieldEffect.set_script(ShieldGd)
	playerTank.add_child(shieldEffect)



func onEnemyExitTree():
	m_enemyCounter -= 1
	get_node("Frame").placeEnemyIcons((m_enemyCounter + 1) / 2)
	if m_enemyCounter == 0:
		emit_signal("playersWon")
		disconnect("playersLost", Game, "onPlayersLost")
		
		
func onPlayerTankDestroyed(playerNumber):
	m_params.playerData[playerNumber].lives -= 1

	if m_params.playerData[playerNumber].lives >= 0:
		get_node("Frame").setPlayerLives(playerNumber, m_params.playerData[playerNumber].lives)
		startSpawningPlayer(playerNumber, PlayerSpawnDelay)


func placePowerup(powerup):
	var x = randi() % int(SizeInTiles.x - 1)
	x = (x +2) * m_cellSize.x
	
	var y = randi() % int(SizeInTiles.y - 1)
	y = (y +2) * m_cellSize.y
	
	assert( x >= m_cellSize.x and y >= m_cellSize.y )

	add_child(powerup)
	powerup.m_stage = weakref(self)
	powerup.set_pos(Vector2(x,y))

