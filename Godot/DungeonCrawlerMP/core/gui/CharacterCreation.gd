extends Panel

const GameCreatorGd          = preload("res://core/game/GameCreator.gd")

signal madeCharacter( creationDatum )


func initialize( module ):
	if module == null:
		return

	for unitPath in module.getUnitsForCreation():
		$"UnitChoice".add_item( unitPath )


func makeCharacter():
	var creationDatum : Dictionary = GameCreatorGd.makeUnitDatum()
	creationDatum.name = $"UnitChoice".get_item_text( $"UnitChoice".get_selected() )
	creationDatum.owner = 0 if not get_tree().has_network_peer() else get_tree().get_network_unique_id()

	emit_signal( "madeCharacter", creationDatum )
	self.queue_free()
