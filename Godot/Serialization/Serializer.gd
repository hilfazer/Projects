extends Reference

const KeyScene = "SCENE"
const KeyChildren = "CHILDREN"
const KeyNodeKeys = "NODE_KEYS"

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
		if not serializedNodes[nodeName][KeyScene].empty():
			var newNode = load( serializedNodes[nodeName][KeyScene] ).instance()
			newNode.name = nodeName
			parent.add_child(newNode)
		
	pass
	

