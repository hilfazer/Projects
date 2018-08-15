extends Reference

const KeyScene = "SCENE"
const KeyChildren = "CHILDREN"

var m_serializedDict : Dictionary = {}


func saveBranch( branchDict : Dictionary ):
	pass
	
	
func removeBranch( branchPath : NodePath ):
	pass
	
	
func saveToFile( filename : String ):
	pass
	
	
func loadFromFile( filename : String ):
	pass


static func serialize( node : Node ):
	var nodeData
	if node.has_method("serialize"):
		nodeData = { node.name : node.serialize() }
	else:
		nodeData = { node.name : emptyDict() }
	
	print(nodeData)
	# serialize children
	for ch in node.get_children():
		if not ch.has_method("serialize"):
			continue
		
		if ch.name in nodeData[node.name][KeyChildren]:
			continue
		
		nodeData[node.name][KeyChildren][ch.name] = ch.serialize()
	print(nodeData)
	pass
	
	
static func deserialize( nodeDict ):
	pass
	
	
	
static func emptyDict():
	return { KeyScene : null, KeyChildren = {} }
	
	