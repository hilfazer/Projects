extends "./TestBase.gd"

const NodeBranchScn = preload("res://test/5NodeBranch.tscn")

var _nodesToSave : Node
var _loadedNodesGuard = null

func _initialize():
	var branch = NodeBranchScn.instance()
	add_child( branch )

	_nodesToSave = branch
	branch.get_node("Timer/ColorRect").s = "bar"


func _runTest():
	var savedNodes = SerializerGd.serialize( _nodesToSave )
	_loadedNodesGuard = SerializerGd.deserialize( savedNodes, null )


func _validate() -> int:
	var branchRoot = _loadedNodesGuard.node
	var modifiedNode = branchRoot.get_node("Timer/ColorRect")

	var passed = _loadedNodesGuard != null and \
		modifiedNode.s == "bar"

	_loadedNodesGuard = null
	passed = passed and not is_instance_valid( branchRoot ) and \
		not is_instance_valid( modifiedNode )

	return 0 if passed else 1
