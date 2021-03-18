extends AgentBase

var _nextDirection := Vector2( 0, 0 )


func _ready():
	var parent = get_parent()
	if parent is UnitBase:
		addUnit( parent )
	parent.connect("moved", self, "_moveOpposite")
	_moveOpposite( Vector2( 1, 0 ) )


func _physics_process( _delta ):
	if _nextDirection:
		for unit in _unitsInTree:
			assert( unit.is_inside_tree() )
			unit.requestedDirection = _nextDirection
	_nextDirection = Vector2( 0, 0 )


func _moveOpposite( direction : Vector2 ):
	_nextDirection = Vector2( -direction.x, direction.y )

