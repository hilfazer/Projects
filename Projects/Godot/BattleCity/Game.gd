extends Node

const MainMenuScn = "res://gui/MainMenu.tscn"
#stages need to be located in
const StagesPath = "res://stages/"
# Stages need to start with string below and have number at the end
const StagePrefix = "Stage"
const StageExtension = ".tscn"

const GameOverScreenDelay = 2

var m_stages = []
var m_nextStage = 0
var m_playerCount


func _ready():
	m_stages = discoverStages()
	randomize()


func discoverStages():
	var stages = [] 
	var stageNumber = 1
	while ( File.new().file_exists(StagesPath + StagePrefix + str(stageNumber) + StageExtension) ):
		stages.append( StagesPath + StagePrefix + str(stageNumber) + StageExtension )
		stageNumber += 1

	assert(stages.empty() == false)
	return stages 


func startAGame(playerCount):
	m_playerCount = playerCount
	m_nextStage = 0
	loadStage(0, playerCount)
	
	
func onPlayersWon():
	var timer = Timer.new()
	timer.set_wait_time(GameOverScreenDelay)
	timer.connect("timeout", timer, "queue_free")
	timer.connect("timeout", self, "stageComplete")
	self.add_child(timer)
	timer.start()
	
	
func onPlayersLost():
	var timer = Timer.new()
	timer.set_wait_time(GameOverScreenDelay)
	timer.connect("timeout", timer, "queue_free")
	timer.connect("timeout", self, "gameOver")
	self.add_child(timer)
	timer.start()


func gameOver():
	SceneSwitcher.switchScene(MainMenuScn)


func stageComplete():
	m_nextStage += 1
	if m_nextStage < m_stages.size():
		loadStage(m_nextStage, m_playerCount)
	else:
		gameOver()


func loadStage(stageNumber, playerCount):
	SceneSwitcher.switchScene( m_stages[stageNumber], {playerCount = playerCount} )