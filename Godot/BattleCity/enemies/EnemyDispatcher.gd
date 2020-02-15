extends Node

var m_stage                         setget deleted
var m_spawnNumber                   setget deleted
var m_timeSpawnDefinitionArray = [] setget deleted
var m_spawns2SpawnTimes = {}        setget deleted
var m_timeElapsed = 0.0             setget deleted


func deleted(_a):
	assert(false)


func _ready():
	set_process(true)


func _process(delta):
	m_timeElapsed += delta

	var newSpawnArray = []
	for foo in m_timeSpawnDefinitionArray:
		if foo[0] > m_timeElapsed:
			newSpawnArray.append(foo)
		else:
			var spawnNode = m_stage.get_ref().get_node(m_stage.get_ref().EnemySpawnPrefix + str(foo[1]))
			m_stage.get_ref().call_deferred( "startSpawningEnemy", foo[2], spawnNode )

	m_timeSpawnDefinitionArray = newSpawnArray


func getRemainingEnemies():
	return m_timeSpawnDefinitionArray.size()


func setStage(stage):
	m_stage = weakref(stage)


func setSpawnNumber(spawnNumber):
	m_spawnNumber = spawnNumber
	for number in range(1, m_spawnNumber +1):
		m_spawns2SpawnTimes[number] = 0.0


func setDefinitions(definitions):
	computeTimesAndSpawns(definitions)


func computeTimesAndSpawns(enemyDefinitions):
	assert(enemyDefinitions.size() > 0)
	enemyDefinitions.sort_custom(self, "sortBySpawnTime")

	for definition in enemyDefinitions:
		var availableSpawns = definition.spawnIndices \
		if   definition.spawnIndices.size() != 0 \
		else range(1, m_spawnNumber +1)

		var timeAndSpawns = getTimeAndSpawnsAvailable(definition.spawnTime, availableSpawns)
		var spawnTime = timeAndSpawns[0]
		var availableSpawns = timeAndSpawns[1]

		scheduleTankSpawn(availableSpawns[randi() % availableSpawns.size()], spawnTime, definition)


func sortBySpawnTime(a, b):
	return a.spawnTime < b.spawnTime


func scheduleTankSpawn(spawn, time, enemyDefinition):
	assert( time >= m_spawns2SpawnTimes[spawn] )

	m_spawns2SpawnTimes[spawn] = time + m_stage.get_ref().EnemySpawnDelay
	m_timeSpawnDefinitionArray.append([time, spawn, enemyDefinition])


func getTimeAndSpawnsAvailable(desiredTime, spawns):
	var timesAvailable = []
	for spawn in spawns:
		timesAvailable.append(m_spawns2SpawnTimes[spawn])

	var sortedTimes = [] + timesAvailable
	sortedTimes.sort()

	var spawnTime = max(desiredTime, sortedTimes.front())
	var availableSpawns = []

	for i in range(0, timesAvailable.size()):
		if timesAvailable[i] <= spawnTime:
			availableSpawns.append(spawns[i])

	return [ spawnTime, availableSpawns ]

