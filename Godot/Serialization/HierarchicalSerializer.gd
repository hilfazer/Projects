extends Reference

const NodeGuardGd = preload("./NodeGuard.gd")

var _serializedDict : Dictionary = {}  setget deleted


func deleted(_a):
	assert(false)


func add( key : String, value ) -> void:
	_serializedDict[ key ] = value


func remove( key : String ) -> bool:
	return _serializedDict.erase( key )


func hasKey( key : String ) -> bool:
	return _serializedDict.has( key )


func getValue( key : String ):
	return _serializedDict[key]


func getKeys() -> Array:
	return _serializedDict.keys()


func saveToFile( filename : String, format := false ) -> int:
	return OK


func loadFromFile( filename : String ) -> int:
	return OK



class Probe extends Reference:
	var _nodesNotInstantiable := [] # Array of Nodes
	var _nodesNoMatchingDeserialize := []

	func _init( node : Node ):
		if node.owner == null and node.filename.empty():
			_addNotInstantiable( node )

		if node.has_method("serialize") and not node.has_method("deserialize"):
			_addNoMatchingDeserialize( node )

		for child in node.get_children():
			_merge( Probe.new( child ) )


	func _merge( other : Probe ):
		for i in other._nodesNotInstantiable:
			_nodesNotInstantiable.append( i )
		for i in other._nodesNoMatchingDeserialize:
			_nodesNoMatchingDeserialize.append( i )

	# deserialize( node ) can only add nodes via scene instancing
	# creation of other nodes needs to be taken care of outside of
	# deserialize( node ) (i.e. _init(), _ready())
	# or deserialize( node ) won't deserialize them nor their branch
	func getNotInstantiableNodes() -> Array:
		return _nodesNotInstantiable

	func getNodesNoMatchingDeserialize() -> Array:
		return _nodesNoMatchingDeserialize

	func _addNotInstantiable( node : Node ):
		if _nodesNotInstantiable.find( node ) == -1:
			_nodesNotInstantiable.append( node )

	func _addNoMatchingDeserialize( node : Node ):
		if _nodesNoMatchingDeserialize.find( node ) == -1:
			_nodesNoMatchingDeserialize.append( node )
