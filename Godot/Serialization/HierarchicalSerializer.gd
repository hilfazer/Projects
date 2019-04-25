extends Reference

enum Index {
	Name, Scene, OwnData, FirstChild
}

var _serializedDict : Dictionary = {}  setget deleted


func deleted(_a):
	assert(false)


func add( key : String, value ):
	if value == null:
		if _serializedDict.has( key ):
			remove( key )
	else:
		_serializedDict[ key ] = value


func remove( key : String ):
	return _serializedDict.erase( key )


func getValue( key : String ):
	return _serializedDict[key] if _serializedDict.has(key) else null


func getKeys() -> Array:
	return _serializedDict.keys()


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


static func deserialize( data : Array, parent : Node ):
	var nodeName  = data[Index.Name]
	var sceneFile = data[Index.Scene]
	var ownData   = data[Index.OwnData]

	var node = parent.get_node_or_null( nodeName )
	if not node:
		if !sceneFile.empty():
			node = load( sceneFile ).instance()
			parent.add_child( node )
			assert( parent.is_a_parent_of( node ) )
			node.name = nodeName

	if not node:
		return # node didn't exist and could not be created by serializer

	if node.has_method("deserialize"):
		node.deserialize( ownData )

	for childIdx in range( Index.FirstChild, data.size() ):
		deserialize( data[childIdx], node )

	if node.has_method("postDeserialize"):
		node.postDeserialize()



static func serializeTest( node : Node ) -> SerializeTestResults:
	var results = SerializeTestResults.new()
#	var nodeData : Dictionary = node.serialize() if node.has_method("serialize") else {}

	if node.owner == null and node.filename.empty():
		results._addNotInstantiable( node )

	for child in node.get_children():
		results.merge( serializeTest( child ) )

	return results



class SerializeTestResults extends Reference:
	var _nodesNotInstantiable = [] # Array of Nodes

	func merge( results ):
		for i in results._nodesNotInstantiable:
			_nodesNotInstantiable.append( i )

	# deserialize( node ) can only add nodes via scene instancing
	# creation of other nodes needs to be taken care of outside of
	# deserialize( node ) (i.e. _init(), _ready())
	# or deserialize( node ) won't deserialize them nor their branch
	func getNotInstantiableNodes() -> Array:
		return _nodesNotInstantiable

	func _addNotInstantiable( node : Node ):
		if _nodesNotInstantiable.find( node ) == -1:
			_nodesNotInstantiable.append( node )
