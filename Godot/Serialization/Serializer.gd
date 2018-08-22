extends Reference

const KeyScene = "SCENE"
const KeyChildren = "CHILDREN"

# dict returned from .serialize() function can't have these keys
const ForbiddenKeys = [ KeyScene, KeyChildren ]

var m_serializedDict : Dictionary = {} setget deleted


func deleted(a):
	assert(false)


func add( keyAndValue : Array ):
	if keyAndValue[1] == null:
		if m_serializedDict.has(keyAndValue[0]):
			remove( keyAndValue[0] )
	else:
	#	m_serializedDict[ keyAndValue[0] ] = {}
		m_serializedDict[ keyAndValue[0] ] = keyAndValue[1] 


func remove( key : String ):
	m_serializedDict.erase( key )
	

func getValue( key : String ):
	return m_serializedDict[key] if m_serializedDict.has(key) else null


func getKeys() -> Array:
	return m_serializedDict.keys()


func saveToFile( filename : String ):
	var saveFile = File.new()
	if OK != saveFile.open(filename, File.WRITE):
		return

	saveFile.store_line(to_json(m_serializedDict))
	saveFile.close()


func loadFromFile( filename : String ):
	var saveFile = File.new()
	if OK != saveFile.open(filename, File.READ):
		return

	m_serializedDict = {}
	m_serializedDict = parse_json( saveFile.get_as_text() )


# return two element Array: [node name, data serialized to Dictionary]
# or an empty array if there was nothing to serialize
static func serialize( node : Node ) -> Array:
	var nameAndData = [node.name, null]
	nameAndData[1] = node.serialize() if node.has_method("serialize") else {}

	if node.filename:
		nameAndData[1][KeyScene] = node.filename
		
	var children = {}
	for ch in node.get_children():
		var childNameAndData = serialize(ch)
		if not childNameAndData.empty():
			children[childNameAndData[0]] = childNameAndData[1]

	if not children.empty():
		nameAndData[1][KeyChildren] = children

	if nameAndData[1].empty() or nameAndData[1].keys() == [KeyScene]:
		return []
	else:
		return nameAndData


# it will work if 'node' is not in SceneTree but keep in mind
# some of Node's functions (like 'enter_tree()') will not be called
# first argument is return value of serialize(node)
static func deserialize( nameAndData : Array, parent : Node ):
	var name = nameAndData[0]
	var data = nameAndData[1]
	var node = null
	if parent.has_node(name):
		node = parent.get_node( name )
	else:
		if data.has(KeyScene) and !data[KeyScene].empty():
			node = load( data[KeyScene] ).instance()
			parent.add_child( node, true )
			node.name = name
	
	if not node:
		return # node didn't exist and could not be created by serializer

	node.deserialize( data )
	
	if data.has(KeyChildren):
		for childName in data[KeyChildren]:
			deserialize( [childName, data[KeyChildren][childName]], node )
	
	if node.has_method("postDeserialize"):
		node.postDeserialize()
	pass


static func serializeTest( node : Node ):
	var results = SerializeTestResults.new()
	var nodeData : Dictionary = node.serialize() if node.has_method("serialize") else {}

	for key in ForbiddenKeys:
		if nodeData.has(key):
			results.nodesForbiddenKeys.append( node.get_path() if node.get_path() else node.name )

	if node.owner == null and node.filename.empty():
		results._addNotInstantiable( node )

	for child in node.get_children():
		results.merge( serializeTest( child ) )

	return results


class SerializeTestResults extends Reference:
	var nodesForbiddenKeys = []
	var nodesNotInstantiable = []

	func merge( results ):
		for i in results.nodesForbiddenKeys:
			nodesForbiddenKeys.append( i )
		for i in results.nodesNotInstantiable:
			nodesNotInstantiable.append( i )

	func canSave():
		return nodesForbiddenKeys.size() == 0

	# deserialize( node ) can only add nodes via scene instancing
	# creation of other nodes needs to be taken care of outside of 
	# deserialize( node ) (i.e. _init(), _ready())
	# or deserialize( node ) won't deserialize them nor their branch
	func getNotInstantiableNodes():
		return nodesNotInstantiable
		
	func _addNotInstantiable( node ):
		nodesNotInstantiable.append( node.get_path() if node.get_path() else node.name )

