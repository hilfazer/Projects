extends Panel


export var m_defaultPlayerName = "Player"


func _ready():
	get_node("Name").text = m_defaultPlayerName + str(PreStart.m_gameInstanceNumber)
