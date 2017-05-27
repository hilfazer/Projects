extends Node

#stages need to be located in
const StagesPath = "res://stages/"
# Stages need to start with string below and have number at the end
const StagePrefix = "Stage"
const StageExtension = ".tscn"

const GameOverScreenDelay = 2

var m_stages = []
var m_nextStage = 0


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
	SceneSwitcher.switchScene( m_stages[0], {playerCount = playerCount} )
	
	
func onPlayersWon():
	var timer = Timer.new()
	timer.set_wait_time(GameOverScreenDelay)
	timer.connect("timeout", timer, "queue_free")
	timer.connect("timeout", self, "gameOver")
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
	SceneSwitcher.switchScene(SceneSwitcher.m_previousScene)