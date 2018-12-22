
func _init():
	assert(false)


# don't forget to reset reference to your node after calling this function
static func setFreeing( node ):
	if node:
		node.set_name(node.get_name() + "_freeing")
		node.queue_free()


static func greaterThan(a, b):
	return a > b


static func getChildrenRecursive(node):
	var nodeReferences = []
	for N in node.get_children():
		nodeReferences.append( N )
		nodeReferences += getChildrenRecursive(N)
	return nodeReferences


static func toPaths(nodes):
	var paths = []
	for n in nodes:
		paths.append( n.get_path() )
	return paths


static func isSuperset( super, sub ):
	for elem in sub:
		if not super.has(elem):
			return false

	return true


static func scopeExit(object : Object, functionName : String, args : Array):
	return FunctionRAII.new( object, functionName, args )


class FunctionRAII extends Reference:
	func _init( object : Object, functionName : String, args : Array ):
		m_obj = object
		m_func = functionName
		m_args = args

	func _notification(what):
		match( what ):
			NOTIFICATION_PREDELETE:
				m_obj.callv(m_func, m_args)

	var m_obj
	var m_func
	var m_args

