extends Node

#stages need to be located in
const StagesPath = "res://stages/"
# Stages need to start with string below and have number at the end
const StagePrefix = "Stage"
const StageExtension = ".tscn"

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