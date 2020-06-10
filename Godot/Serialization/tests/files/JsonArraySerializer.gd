extends Reference

const NodeGuardGd = preload("res://NodeGuard.gd")

enum Index { Name, Scene, OwnData, FirstChild }

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


func getKeys() -> PoolStringArray:
	return PoolStringArray( _serializedDict.keys() )


func saveToFile( filename : String, format := false ) -> int:
	var saveFile = File.new()
	var openResult = saveFile.open(filename, File.WRITE)
	if OK != openResult:
		return openResult

	if format:
		saveFile.store_line( JSON.print( _serializedDict, '\t' ) )
	else:
		saveFile.store_line( to_json( _serializedDict ) )
	saveFile.close()
	return OK


func loadFromFile( filename : String ) -> int:
	var saveFile = File.new()
	var openResult = saveFile.open(filename, File.READ)
	if OK != openResult:
		return openResult

	_serializedDict = {}
	_serializedDict = parse_json( saveFile.get_as_text() )
	saveFile.close()
	return OK


# returns an Array with: node name, scene, node's own data, serialized children (if any)
static func serialize( node : Node ) -> Array:
	var data := [
		node.name,
		node.filename,
		node.serialize() if node.has_method("serialize") else null
	]

	for child in node.get_children():
		var childData = serialize( child )
		if not childData.empty():
			data.append( childData )

	if data[ Index.OwnData ] == null and data.size() <= Index.FirstChild:
		return []
	else:
		return data


# parent can be null
static func deserialize( data : Array, parent : Node ) -> NodeGuardGd:
	var nodeName  = data[Index.Name]
	var sceneFile = data[Index.Scene]
	var ownData   = data[Index.OwnData]

	var node : Node
	if not parent:
		if !sceneFile.empty():
			node = load( sceneFile ).instance()
			node.name = nodeName
	else:
		node = parent.get_node_or_null( nodeName )
		if not node:
			if !sceneFile.empty():
				node = load( sceneFile ).instance()
				parent.add_child( node )
				assert( parent.is_a_parent_of( node ) )
				node.name = nodeName

	if not node:
		return NodeGuardGd.new()# node didn't exist and could not be created by serializer

	if node.has_method("deserialize"):
		# warning-ignore:return_value_discarded
		node.deserialize( ownData )

	for childIdx in range( Index.FirstChild, data.size() ):
		# warning-ignore:return_value_discarded
		deserialize( data[childIdx], node )

	if node.has_method("post_deserialize"):
		node.post_deserialize()

	return NodeGuardGd.new( node )


static func serializeTest( node : Node ) -> SerializeTestResults:
	var results = SerializeTestResults.new()

	if node.owner == null and node.filename.empty():
		results._addNotInstantiable( node )

	if node.has_method("serialize") and not node.has_method("deserialize"):
		results._addNoMatchingDeserialize( node )

	for child in node.get_children():
		results.merge( serializeTest( child ) )

	return results



class SerializeTestResults extends Reference:
	var _nodesNotInstantiable := [] # Array of Nodes
	var _nodesNoMatchingDeserialize := []

	func merge( results ):
		for i in results._nodesNotInstantiable:
			_nodesNotInstantiable.append( i )
		for i in results._nodesNoMatchingDeserialize:
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
