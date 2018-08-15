extends Reference

const KeyScene = "SCENE"
const KeyChildren = "CHILDREN"
const KeyNodeKeys = "NODE_KEYS"
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

	assert( not nodeData.has(KeyChildren) )
	var children = {}

	for ch in node.get_children():
		var childData = serialize(ch)
		if not childData.empty():
			children[ch.name] = childData

	if not children.empty():
		nodeData[KeyChildren] = children

	return nodeData


static func deserialize( serializedNodes : Dictionary, parent : Node ):
	for nodeName in serializedNodes:
		var nodeData = serializedNodes[nodeName]
		var node
		if nodeData.has(KeyScene) and !nodeData[KeyScene].empty():
			node = load( nodeData[KeyScene] ).instance()
			parent.add_child(node)
		else:
			node = parent.get_node(nodeName)

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
		results.nodesNonserializable.append( node.get_path() if node.get_path() else node.name )

	for child in node.get_children():
		results.merge( serializeTest( child ) )

	return results


class SerializeTestResults extends Reference:
	var nodesForbiddenKeys = []
	var nodesNonserializable = []

	func merge( results ):
		for i in results.nodesForbiddenKeys:
			nodesForbiddenKeys.append( i )
		for i in results.nodesNonserializable:
			nodesNonserializable.append( i )

	func canSave():
		return nodesForbiddenKeys.size() == 0



