extends Reference

const KeyScene = "SCENE"
const KeyChildren = "CHILDREN"
const KeyNodeKeys = "NODE_KEYS"

# dict returned from .serialize() function can't have these keys
const ForbiddenKeys = [ KeyScene, KeyChildren ]

var m_serializedDict : Dictionary = { KeyNodeKeys : [] }


func saveBranch( key : String, branchDict : Dictionary ):
	m_serializedDict[key] = {}
	m_serializedDict[key] = branchDict
	m_serializedDict[KeyNodeKeys].append(key)


func removeBranch( branchPath : NodePath ):
	pass


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


func getSavedNodes():
	var dict = {}
	for nodeKey in m_serializedDict[KeyNodeKeys]:
		assert( m_serializedDict.has(nodeKey) )
		dict[nodeKey] = m_serializedDict[nodeKey]
	return dict


static func serialize( node : Node ):
	var nodeData = node.serialize() if node.has_method("serialize") else {}

	if node.filename:
		nodeData[KeyScene] = node.filename
		
	var children = {}
	for ch in node.get_children():
		var childData = serialize(ch)
		if not childData.empty():
			children[ch.name] = childData

	if not children.empty():
		nodeData[KeyChildren] = children

	return nodeData


# it will work if 'node' is not in SceneTree but keep in mind
# some of Node's functions (like 'enter_tree()') will not be called
static func deserialize( serializedNodes : Dictionary, parent : Node ):
	for nodeName in serializedNodes:
		var nodeData = serializedNodes[nodeName]
		var node
		if nodeData.has(KeyScene) and !nodeData[KeyScene].empty():
			node = load( nodeData[KeyScene] ).instance()
			parent.add_child( node, true )
		else:
			node = parent.get_node( nodeName )

		node.name = nodeName
		node.deserialize( nodeData )
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

