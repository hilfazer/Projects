extends KinematicBody2D


var _path := PoolVector2Array()
var _targetPointIdx := -1


func _physics_process(delta):
	pass


func followPath( path : PoolVector3Array ):
	var path2d : PoolVector2Array = []
	for point3 in path:
		path2d.append( Vector2(point3.x, point3.y) )

	setPath(path2d)
	pass


func setPath( path : PoolVector2Array ):
	if path.size() < 2:
		_path = PoolVector2Array()
		_targetPointIdx = -1
	else:
		_path = path
		_targetPointIdx = 1
		position = path[0]
