extends Control

#stages need to be located in
const StagesPath = "res://stages/"
# Stages need to start with string below and have number at the end
const StagePrefix = "Stage"
const StageExtension = ".tscn"

export var m_resolution = Vector2(1024, 768)
var m_stages = []
var m_nextStage = 0

func _ready():
	OS.set_window_size(m_resolution)
	
	if ( get_node("MainMenuButtons").get_button_list().empty() ):
		queue_free()
		return
		
	setupButtonIcons()
	m_stages = discoverStages()
	randomize()
	

func setupButtonIcons():
	for button in get_node("MainMenuButtons").get_button_list():
		button.set_button_icon( get_node("MainMenuButtons/CursorEmpty").get_texture() )
		button.connect("focus_enter", button, "set_button_icon", [get_node("MainMenuButtons/CursorTank").get_texture()])
		button.connect("focus_exit", button, "set_button_icon", [get_node("MainMenuButtons/CursorEmpty").get_texture()])
		
	assert( get_node("MainMenuButtons").get_button_list().empty() == false )
	get_node("MainMenuButtons").get_button_list()[0].grab_focus()
	
	
func discoverStages():
	var stages = [] 
	var stageNumber = 1
	var filename = StagesPath + StagePrefix + str(stageNumber) + StageExtension
	while ( File.new().file_exists(StagesPath + StagePrefix + str(stageNumber) + StageExtension) ):
		stages.append( StagesPath + StagePrefix + str(stageNumber) + StageExtension )
		stageNumber += 1
	
	return stages


func _on_1PlayerButton_pressed():
	assert( !m_stages.empty() )
	SceneSwitcher.switchScene( m_stages[0], {playerCount = 1} )


func _on_2PlayersButton_pressed():
	assert( !m_stages.empty() )
	SceneSwitcher.switchScene( m_stages[0], {playerCount = 2} )
