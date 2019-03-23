extends Panel


export var _defaultPlayerName = "Player"


func _ready():
	get_node("Name").text = _defaultPlayerName + str(PreStart._gameInstanceNumber)
