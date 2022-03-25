extends Reference


var _nodeArray : Array


func _init(nodes_ : Array = []):
	for node in nodes_:
		assert(node is Node)
		_nodeArray.append(node)


func add(node_ : Node) -> int:
	_nodeArray.append(node_)
	return _nodeArray.size() - 1


func release(nodeIdx : int) -> Node:
	if nodeIdx >= _nodeArray.size():
		return null

	var toReturn = _nodeArray[nodeIdx]
	_nodeArray[nodeIdx] = null
	return toReturn


func size():
	return _nodeArray.size()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for node in _nodeArray:
			if is_instance_valid( node ) \
				and not node.is_inside_tree() \
				and not node.get_parent():
				node.free()
