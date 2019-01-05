extends Panel

const GameCreatorGd          = preload("res://core/game/GameCreator.gd")

signal madeCharacter( creationData )


func initialize( module ):
	if module == null:
		return

	for unitPath in module.getUnitsForCreation():
		$"UnitChoice".add_item( unitPath )


func makeCharacter():
	var creationData = GameCreatorGd.UnitCreationData.new()
	creationData.name = $"UnitChoice".get_item_text( $"UnitChoice".get_selected() )
	creationData.owner = 0 if not get_tree().has_network_peer() else get_tree().get_network_unique_id()

	emit_signal( "madeCharacter", creationData )
	self.queue_free()
