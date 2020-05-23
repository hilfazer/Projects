extends Reference

const NodeGuardGd            = preload("./NodeGuard.gd")
const SerializedStateGd      = preload("./SerializedState.gd")

var _nodesData := {}
var userData := {}


func add( key : String, value ) -> void:
	_nodesData[ key ] = value


func remove( key : String ) -> bool:
	return _nodesData.erase( key )


func hasKey( key : String ) -> bool:
	return _nodesData.has( key )


func getValue( key : String ):
	return _nodesData[key]


func getKeys() -> Array:
	return _nodesData.keys()


func saveToFile( filename : String ) -> int:
	if not filename.is_valid_filename():
		print("not a valid filename")
		return ERR_CANT_CREATE

	var stateToSave = SerializedStateGd.new()
	var version = ProjectSettings.get_setting("application/config/version")
	if version != "":
		stateToSave.version = version

	var dir := Directory.new()
	if not dir.dir_exists( filename.get_base_dir() ):
		dir.make_dir_recursive( filename.get_base_dir() )

	var error := ResourceSaver.save( filename, stateToSave )
	if error != OK:
		print( "could not save a Resource" )
		return ERR_CANT_CREATE

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
