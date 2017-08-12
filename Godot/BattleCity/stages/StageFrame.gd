extends Node


var m_playerIdToLives = {}
var m_playerIdToSprites = {}


func _ready():
	setPlayerLives(1, 0)
	setPlayerLives(2, 0)


func setPlayerLives(playerNumber, lives):
	var livesSprite = get_node("Numbers").get_node(str(lives)).duplicate()
	add_child(livesSprite)
	livesSprite.set_pos( get_node( "Player" + str(playerNumber) + "Lives" ).get_pos() )

	m_playerIdToLives[playerNumber] = lives

	if m_playerIdToSprites.has(playerNumber):
		m_playerIdToSprites[playerNumber].queue_free()

	m_playerIdToSprites[playerNumber] = livesSprite


func getPlayerLives(playerNumber):
	return m_playerIdToLives[playerNumber]
	
	
	