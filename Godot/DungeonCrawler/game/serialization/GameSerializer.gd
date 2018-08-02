extends Reference

const GameSceneGd = preload("res://game/GameScene.gd")
const LevelLoaderGd = preload("res://levels/LevelLoader.gd")
const UtilityGd          = preload("res://Utility.gd")

# JSON names
const NameModule = "Module"
const NameCurrentLevel = "CurrentLevel"
const NamePlayerUnitsPaths = "PlayerUnitsPaths"

var m_game


signal deserializationComplete()


func _init(game):
	m_game = game


func serialize( filePath ):
	var saveFile = File.new()

	if OK != saveFile.open(filePath, File.WRITE):
		return

	var saveDict = {}

	saveDict[NameModule] = m_game.m_module_.script.resource_path

	saveDict[m_game.m_currentLevel.get_name()] = m_game.m_currentLevel.serialize()
	saveDict[NameCurrentLevel] = m_game.m_currentLevel.get_name()

	var playerUnitsPaths = []
	for unit in m_game.m_playerUnits:
		playerUnitsPaths.append( unit[GameSceneGd.NODE].get_path() )
	saveDict[NamePlayerUnitsPaths] = playerUnitsPaths

	saveFile.store_line(to_json(saveDict))
	saveFile.close()


func deserialize( filePath ):
	var saveFile = File.new()

	if not OK == saveFile.open(filePath, File.READ):
		UtilityGd.showAcceptDialog( "File %s" % filePath + " does not exist", "No such file" )
		return

	var gameStateDict = parse_json(saveFile.get_as_text())
	var hadLevel = m_game.m_currentLevel != null

	assert( File.new().file_exists(gameStateDict[NameModule]) )
	var module_ = load( gameStateDict[NameModule] ).new()
	m_game.setCurrentModule( module_ )

	var currentLevelDict = gameStateDict[ gameStateDict[NameCurrentLevel] ]
	var levelLoader = m_game.m_levelLoader

	if hadLevel:
		yield( levelLoader, "levelUnloaded" )
	assert( m_game.m_currentLevel == null )
	levelLoader.loadLevel( currentLevelDict.scene, m_game )

	assert( m_game.m_currentLevel )
	m_game.m_currentLevel.deserialize( currentLevelDict )

	m_game.resetPlayerUnits( gameStateDict["PlayerUnitsPaths"] )

	emit_signal("deserializationComplete")
	

