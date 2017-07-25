extends Node


var m_player1LivesSprite
var m_player2LivesSprite
var m_playerIdToLives = {}


func _ready():
	setPlayerLives(1, 0)
	setPlayerLives(2, 0)


func setPlayerLives(playerNumber, lives):
	var livesSprite = get_node("Numbers").get_node(str(lives)).duplicate()
	add_child(livesSprite)
	var position = get_node( "Player" + str(playerNumber) + "Lives" ).get_pos()
	livesSprite.set_pos( position )

	m_playerIdToLives[playerNumber] = lives

	if ( playerNumber == 1 ):
		if m_player1LivesSprite != null:
			m_player1LivesSprite.queue_free()
		m_player1LivesSprite = livesSprite
	elif ( playerNumber == 2 ):
		if m_player2LivesSprite != null:
			m_player2LivesSprite.queue_free()
		m_player2LivesSprite = livesSprite


func getPlayerLives(playerNumber):
	return m_playerIdToLives[playerNumber]
	
	
	