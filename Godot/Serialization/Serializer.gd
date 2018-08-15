extends Reference

const KeyScene = "SCENE"
const KeyChildren = "CHILDREN"

var m_serializedDict : Dictionary = {}


func saveBranch( key : String, branchDict : Dictionary ):
	m_serializedDict[key] = {}
	m_serializedDict[key] = branchDict


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
		return null
		
	return parse_json( saveFile.get_as_text() )


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


static func deserialize( nodeDict, parent : Node ):
	pass
	

