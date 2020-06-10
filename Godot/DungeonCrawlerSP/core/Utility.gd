extends Object
class_name Utility


func _init():
	assert(false)


# don't forget to reset reference to your node after calling this function
static func setFreeing( node : Node ):
	if node:
		node.set_name(node.get_name() + "_freeing")
		node.queue_free()
		node.get_parent().remove_child( node )


static func freeIfNotInTree( nodes : Array ):
	for node in nodes:
		assert( node is Node )
		if is_instance_valid( node ) and not node.is_inside_tree():
			node.free()


static func greaterThan( a, b ) -> bool:
	return a > b


static func getChildrenRecursive( node : Node ) -> Array:
	var nodeReferences := []
	for N in node.get_children():
		nodeReferences.append( N )
		nodeReferences += getChildrenRecursive(N)
	return nodeReferences


static func toPaths( nodes : Array ) -> PoolStringArray:
	var paths = []
	for n in nodes:
		paths.append( n.get_path() )
	return paths


static func isSuperset( super, sub ) -> bool:
	for elem in sub:
		if not super.has(elem):
			return false

	return true


static func scopeExit( object : Object, functionName : String, args : Array = [] ):
	return FunctionRAII.new( object, functionName, args )


class FunctionRAII extends Reference:
	func _init( object : Object, functionName : String, args : Array ):
		_obj = object
		_func = functionName
		_args = args

	func _notification(what):
		if what == NOTIFICATION_PREDELETE and _obj:
			_obj.callv(_func, _args)

	func dismiss():
		_obj = null

	var _obj
	var _func
	var _args

