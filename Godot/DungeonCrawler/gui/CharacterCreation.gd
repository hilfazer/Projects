extends Panel

signal madeCharacter( creationData )


func initialize(module):
	if module == null:
		return

	for unitPath in module.getUnitsForCreation():
		get_node("UnitChoice").add_item(unitPath)


func makeCharacter():
	assert( get_tree().has_network_peer() )
	var creationData = {
		"path" : $"UnitChoice".get_item_text( $"UnitChoice".get_selected() ),
		"owner" : get_tree().get_network_unique_id()
	}

	emit_signal("madeCharacter", creationData )
	self.queue_free()
