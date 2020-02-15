extends Node


const EnemyTankIconSize = Vector2(8, 8)
const EnemyIconGroup = "EnemyTankIcons"
var m_playerIdToLives = {}
var m_playerIdToSprites = {}


func _ready():
	setPlayerLives(1, 0)
	setPlayerLives(2, 0)
	placeEnemyIcons(0)


func setPlayerLives(playerNumber, lives):
	var livesSprite = get_node("Numbers").get_node(str(lives)).duplicate()
	add_child(livesSprite)
	livesSprite.set_position( get_node( "Player" + str(playerNumber) + "Lives" ).position )

	m_playerIdToLives[playerNumber] = lives

	if m_playerIdToSprites.has(playerNumber):
		m_playerIdToSprites[playerNumber].queue_free()

	m_playerIdToSprites[playerNumber] = livesSprite


func getPlayerLives(playerNumber):
	return m_playerIdToLives[playerNumber]
	
	
func placeEnemyIcons( enemyNumber ):
	var startPos = get_node("EnemyTanksBeginPos").position
	var endPos = get_node("EnemyTanksEndPos").position
	var currentPos = startPos
	var remainingIcons = enemyNumber
	
	for node in get_tree().get_nodes_in_group(EnemyIconGroup):
		node.queue_free()

	while( currentPos.y <= endPos.y ):
		currentPos.x = startPos.x
		while( currentPos.x <= endPos.x ):
			if ( remainingIcons > 0 ):
				var enemyIcon = get_node("EnemyTankIcon").duplicate()
				enemyIcon.add_to_group(EnemyIconGroup)
				self.add_child(enemyIcon)
				enemyIcon.set_position(currentPos)
				remainingIcons -= 1
			else:
				var grayIcon = get_node("GrayIcon").duplicate()
				grayIcon.add_to_group(EnemyIconGroup)
				self.add_child(grayIcon)
				grayIcon.set_position(currentPos)
			currentPos.x += EnemyTankIconSize.x
		currentPos.y += EnemyTankIconSize.y
	
	
	
	