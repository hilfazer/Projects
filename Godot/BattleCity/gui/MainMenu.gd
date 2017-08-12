extends Control


func _ready():
	setupButtonIcons()
	if (Game.m_delayedSceneSwitch):
		Game.m_delayedSceneSwitch.queue_free()
		Game.m_delayedSceneSwitch = null


func setupButtonIcons():
	for button in get_node("MainMenuButtons").get_button_list():
		button.set_button_icon( get_node("MainMenuButtons/CursorEmpty").get_texture() )
		button.connect("focus_enter", button, "set_button_icon", [get_node("MainMenuButtons/CursorTank").get_texture()])
		button.connect("focus_exit", button, "set_button_icon", [get_node("MainMenuButtons/CursorEmpty").get_texture()])

	assert( get_node("MainMenuButtons").get_button_list().empty() == false )
	get_node("MainMenuButtons").get_button_list()[0].grab_focus()


func _on_1PlayerButton_pressed():
	Game.startAGame(1)

func _on_2PlayersButton_pressed():
	Game.startAGame(2)
