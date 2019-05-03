extends AgentBase

const LevelLoaderGd          = preload("res://core/game/LevelLoader.gd")

var _game : Node                       setget setGame


func _physics_process(delta):
	var movement := Vector2(0, 0)

	if Input.is_action_pressed("gameplay_up"):
		movement.y -= 1
	if Input.is_action_pressed("gameplay_down"):
		movement.y += 1
	if Input.is_action_pressed("gameplay_left"):
		movement.x -= 1
	if Input.is_action_pressed("gameplay_right"):
		movement.x += 1

	if movement:
		for unit in _unitsInTree:
			assert( unit.is_inside_tree() )
			unit.moveInDirection( movement )


func _unhandled_input(event):
	if event.is_action_pressed("travel"):
		_onTravelRequest()


func _onTravelRequest():
	yield( get_tree(), "idle_frame" )
	var currentLevel : LevelBase = _game.currentLevel
	var entrance : Area2D = currentLevel.findEntranceWithAllUnits( _unitsInTree )

	if entrance == null:
		return

	var levelAndEntranceNames : Array = _game._module.getTargetLevelFilenameAndEntrance(
		currentLevel.name, entrance.name )

	if levelAndEntranceNames.empty():
		return

	var levelName : String = levelAndEntranceNames[0].get_file().get_basename()
	var entranceName : String = levelAndEntranceNames[1]
	var result : int = yield( _game.loadLevel( levelName ), "completed" )

	if result != OK:
		return

	assert( _unitsInTree.empty() )

	LevelLoaderGd.insertPlayerUnits( _units.container(), _game.currentLevel, entranceName )


func setGame( gameScene : Node ):
	assert( is_instance_valid(gameScene) )
	_game = gameScene

