extends Control

var m_stages = []
var m_nextStage = 0

func _ready():
	OS.set_window_size(Vector2(1024,768))
	
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
	return ["res://stages/Stage1.tscn"]


func _on_1PlayerButton_pressed():
	assert( !m_stages.empty() )
	SceneSwitcher.switchScene( m_stages[0], {playerCount = 1} )


func _on_2PlayersButton_pressed():
	assert( !m_stages.empty() )
	SceneSwitcher.switchScene( m_stages[0], {playerCount = 2} )
