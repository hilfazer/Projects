extends Reference

const SerializerGd           = preload("./HierarchicalSerializer.gd")

static func scan( node : Node ) -> Probe:
	return Probe.new( node )



class Probe extends Reference:
	var _nodesNotInstantiable := [] # Array of Nodes
	var _nodesNoMatchingDeserialize := []

	func _init( node : Node ):
		if node.owner == null and node.filename.empty():
			_addNotInstantiable( node )

		if node.has_method(SerializerGd.SERIALIZE) \
				and not node.has_method(SerializerGd.DESERIALIZE):
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
