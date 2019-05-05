extends AgentBase

const LevelLoaderGd          = preload("res://core/game/LevelLoader.gd")
const SelectionBoxScn        = preload("res://core/SelectionBox.tscn")

var _game : Node                       setget setGame
var _selectedUnits := {}               setget deleted


func deleted(_a):
	assert(false)


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
		for unit in _selectedUnits:
			assert( unit is UnitBase )
			assert( unit.is_inside_tree() )
			unit.moveInDirection( movement )


func _unhandled_input(event):
	if event.is_action_pressed("travel"):
		_onTravelRequest()


func addUnit( unit : UnitBase ):
	.addUnit( unit )
	selectUnit( unit )


func removeUnit( unit : UnitBase ) -> bool:
	if unit in _selectedUnits:
		deselectUnit( unit )
	var removed = .removeUnit( unit )
	return removed


func setGame( gameScene : Node ):
	assert( is_instance_valid(gameScene) )
	_game = gameScene


func selectUnit( unit : UnitBase ):
	assert( not unit in _selectedUnits )
	assert( unit in _units.container() )

	print( "selectUnit %s" % unit )

	var selectionBox = SelectionBoxScn.instance()
	unit.add_child( selectionBox )
	_selectedUnits[ unit ] = selectionBox

	print( _selectedUnits )


func deselectUnit( unit : UnitBase ):
	assert( unit in _selectedUnits )

	print( "deselectUnit %s" % unit )

	if is_instance_valid( _selectedUnits[ unit ] ):
		_selectedUnits[ unit ].queue_free()

	_selectedUnits.erase( unit )

	print( _selectedUnits )


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
