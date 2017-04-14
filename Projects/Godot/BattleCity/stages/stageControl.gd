extends Node

const TilesetScn = preload("res://assets/BattleCityTiles.tscn")
const SpawnLightScn = preload("res://effects/SpawningLight.tscn")
const PlayerAgentGd = preload("res://actors/PlayerAgent.gd")
const ComputerAgentGd = preload("res://actors/ComputerAgent.gd")
const TankGd = preload("res://units/Tank.gd")
const MainMenu = "res://gui/MainMenu.tscn"

# Player 1's tank needs to be called:
const TankPlayer1 = "TankPlayer1"
# Player 2's tank needs to be called:
const TankPlayer2 = "TankPlayer2"
# Enemy spawns need to start with:
const EnemySpawnPrefix = "EnemySpawn"
const BRICKS_GROUP = "Bricks"
const PLAYERS_GROUP = "Players"
const ENEMIES_GROUP = "Enemies"

var m_cellIdMap = {}


func _enter_tree():
	prepareStage()


func _ready():
	set_process( true )
	set_process_input( true )
	var groundTiles = get_node("Ground")
	var ids = groundTiles.get_tileset().get_tiles_ids()
	var bar = groundTiles.get_used_cells()
	prepareSpawns()


func _process(delta):
	process_input()


func process_input():
	if (Input.is_action_pressed("ui_cancel")):
		get_tree().change_scene( MainMenu )
	
	
func processBulletCollision( bullet, collidingBody ):
	var collidingObject = collidingBody.get_parent()
	
	if collidingObject.is_in_group(BRICKS_GROUP):
		collidingObject.queue_free()
	
	if collidingObject.has_method("getTeam"):
		if collidingObject.getTeam() != bullet.getTeam() and collidingObject.has_method("destroy"):
			collidingObject.destroy()
	
	
func assignCellIds():
	var tileNames = [ "Water", "Trees", "Ice", "Grey", 
		"WallSteel", "WallSteel2", "WallSteel4", "WallSteel6", "WallSteel8",
		"WallBrick", "WallBrick2", "WallBrick4", "WallBrick6", "WallBrick8"
		]
	var tileset = get_node("Ground").get_tileset()
	
	for name in tileNames:
		assert( tileset.find_tile_by_name(name) != -1 )
		m_cellIdMap[name] = tileset.find_tile_by_name(name)
		
	
func prepareStage():
	assignCellIds()
	var groundTilemap = get_node("Ground")

	if ( TilesetScn != null and groundTilemap != null):
		replaceBrickWallTilesWithNodes(groundTilemap, TilesetScn)
		replaceWaterTilesWithNodes(groundTilemap, TilesetScn)

	assignActors()


# splitting each brick tile into WallBrickSmalls
func replaceBrickWallTilesWithNodes(groundTilemap, packedTilesScene):
	var tilesTree = packedTilesScene.instance()
	var wallBrickSmallPrototype = tilesTree.get_node("WallBrickSmall")
	assert( wallBrickSmallPrototype )
	wallBrickSmallPrototype.add_to_group(BRICKS_GROUP)
	var wallBrickPositions = []
	
	for cell in groundTilemap.get_used_cells():
		if ( groundTilemap.get_cellv(cell) == m_cellIdMap["WallBrick"] ):
			groundTilemap.set_cellv(cell, -1)
			var cellCoords = groundTilemap.map_to_world( cell )
			wallBrickPositions.append( Vector2(cellCoords.x + 4, cellCoords.y + 4) )
			wallBrickPositions.append( Vector2(cellCoords.x + 4 + 8, cellCoords.y + 4) )
			wallBrickPositions.append( Vector2(cellCoords.x + 4, cellCoords.y + 4 + 8) )
			wallBrickPositions.append( Vector2(cellCoords.x + 4 + 8, cellCoords.y + 4 + 8) )
		elif ( groundTilemap.get_cellv(cell) == m_cellIdMap["WallBrick6"] ):
			groundTilemap.set_cellv(cell, -1)
			var cellCoords = groundTilemap.map_to_world( cell )
			wallBrickPositions.append( Vector2(cellCoords.x + 4 + 8, cellCoords.y + 4) )
			wallBrickPositions.append( Vector2(cellCoords.x + 4 + 8, cellCoords.y + 4 + 8) )
		elif ( groundTilemap.get_cellv(cell) == m_cellIdMap["WallBrick4"] ):
			groundTilemap.set_cellv(cell, -1)
			var cellCoords = groundTilemap.map_to_world( cell )
			wallBrickPositions.append( Vector2(cellCoords.x + 4, cellCoords.y + 4) )
			wallBrickPositions.append( Vector2(cellCoords.x + 4, cellCoords.y + 4 + 8) )
		elif ( groundTilemap.get_cellv(cell) == m_cellIdMap["WallBrick2"] ):
			groundTilemap.set_cellv(cell, -1)
			var cellCoords = groundTilemap.map_to_world( cell )
			wallBrickPositions.append( Vector2(cellCoords.x + 4, cellCoords.y + 4 + 8) )
			wallBrickPositions.append( Vector2(cellCoords.x + 4 + 8, cellCoords.y + 4 + 8) )
		elif ( groundTilemap.get_cellv(cell) == m_cellIdMap["WallBrick8"] ):
			groundTilemap.set_cellv(cell, -1)
			var cellCoords = groundTilemap.map_to_world( cell )
			wallBrickPositions.append( Vector2(cellCoords.x + 4, cellCoords.y + 4) )
			wallBrickPositions.append( Vector2(cellCoords.x + 4 + 8, cellCoords.y + 4) )
	
	for position in wallBrickPositions:
		var wallBrickSmall = wallBrickSmallPrototype.duplicate()
		assert( wallBrickSmall.get_name() == "WallBrickSmall" )
		assert( wallBrickSmall.is_in_group(BRICKS_GROUP) )
		self.add_child( wallBrickSmall )
		wallBrickSmall.set_pos( position )
	
	
func replaceWaterTilesWithNodes(groundTilemap, packedTilesScene):
	var tilesTree = packedTilesScene.instance()
	var waterPrototype = tilesTree.get_node("Water")
	assert( waterPrototype )
	
	var waterPositions = []
	for cell in groundTilemap.get_used_cells():
		if ( groundTilemap.get_cellv(cell) == m_cellIdMap["Water"] ):
			groundTilemap.set_cellv(cell, -1)
			var cellCoords = groundTilemap.map_to_world( cell )
			waterPositions.append( Vector2(cellCoords.x + 8, cellCoords.y + 8) )
	
	for position in waterPositions:
		var water = waterPrototype.duplicate()
		assert( water.get_name() == "Water" )
		self.add_child( water )
		water.set_pos( position )
	
	
func assignActors():
	var agentPrototype = Node.new()
	agentPrototype.set_script( PlayerAgentGd )
	agentPrototype.set_name("Agent")
	
	var player1Tank = get_node( TankPlayer1 )
	if ( player1Tank != null ):
		var agentNode = agentPrototype.duplicate()
		agentNode.setActions( ["player1_move_up","player1_move_down",
			"player1_move_left", "player1_move_right", "player1_shoot"] )
		agentNode.assignToTank( player1Tank )
		player1Tank.assignTeam( PLAYERS_GROUP )
	
	var player2Tank = get_node( TankPlayer2 )
	if ( player2Tank != null ):
		var agentNode = agentPrototype.duplicate()
		agentNode.setActions( ["player2_move_up","player2_move_down",
			"player2_move_left", "player2_move_right", "player2_shoot"] )
		agentNode.assignToTank( player2Tank )
		player2Tank.assignTeam( PLAYERS_GROUP )


func findSpawns():
	var spawns = Array()
	for child in get_children():
		if child.get_name().find("EnemySpawn") == 0:
			spawns.append(child)
	return spawns

func prepareSpawns():
	var enemySpawns = findSpawns()
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
	
	for spawnTimer in spawnTimers:
		self.add_child( spawnTimer )
		spawnTimer.start()
	
	
func startSpawningEnemy(enemyDefinition, spawnNode):
	if ( spawnNode == null ):
		return

	var light = SpawnLightScn.instance()
	self.add_child(light)
	light.set_pos(spawnNode.get_pos())
	light.connect("exit_tree", self, "spawnEnemy", [enemyDefinition, spawnNode])
	light.glowForSeconds(2)


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
	