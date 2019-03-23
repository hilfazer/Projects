extends Panel


signal madeCharacter( creationDatum )


func initialize( module ):
	if module == null:
		return

	for unitPath in module.getUnitsForCreation():
		$"UnitChoice".add_item( unitPath )


func makeCharacter():
	var creationDatum : Dictionary = makeUnitDatum(
		$"UnitChoice".get_item_text( $"UnitChoice".get_selected() )
	)

	emit_signal( "madeCharacter", creationDatum )
	self.queue_free()


func makeUnitDatum( unitName : String ):
	return { name = unitName }
