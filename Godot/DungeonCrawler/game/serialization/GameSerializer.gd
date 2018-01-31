extends Reference

const GameSceneGd = preload("res://game/GameScene.gd")
const LevelLoaderGd = preload("res://levels/LevelLoader.gd")

var m_game


func _init(game):
	m_game = game


func save( filePath ):
	var saveFile = File.new()
	if OK != saveFile.open(filePath, File.WRITE):
		return

	var saveDict = {}
	saveDict[m_game.m_currentLevel.get_name()] = m_game.m_currentLevel.save()
	
	var playerUnitsPaths = []
	for unit in m_game.m_playerUnits:
		playerUnitsPaths.append( unit[GameSceneGd.NODE].get_path() )
	saveDict["PlayerUnitsPaths"] = playerUnitsPaths

	saveFile.store_line(to_json(saveDict))
	saveFile.close()


func load(filePath):
	var saveFile = File.new()
	if not OK == saveFile.open(filePath, File.READ):
		Utility.showAcceptDialog( "File %s" % filePath + " does not exist", "No such file" )
		return

	m_game.setPaused(true)
	var gameStateDict = parse_json(saveFile.get_as_text())
	var currentLevelDict = gameStateDict.values()[0]
	var levelLoader = LevelLoaderGd.new()

	m_game.unloadLevel( m_game.m_currentLevel )
	m_game.setCurrentLevel( levelLoader.loadLevel( currentLevelDict.scene, m_game ) )
	m_game.m_currentLevel.load( currentLevelDict )

	m_game.resetPlayerUnits( gameStateDict["PlayerUnitsPaths"] )

	m_game.setPaused(false)
