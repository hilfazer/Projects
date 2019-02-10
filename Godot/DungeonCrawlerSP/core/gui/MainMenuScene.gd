extends Control

const NewGameScnPath         = "res://core/gui/NewGameScene.tscn"

func newGame():
	var params = {}
	params["playerName"] = get_node("PlayerData/Name").text

	SceneSwitcher.switchScene(NewGameScnPath, params)


func exitProgram():
	get_tree().quit()
