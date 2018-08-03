

static func showAcceptDialog( message, title, dialogParent ):
	var dialog = AcceptDialog.new()
	dialog.set_title( title )
	dialog.set_text( message )
	dialog.set_name( title )
	dialog.popup_exclusive = true
	dialog.connect("confirmed", dialog, "queue_free")
	dialog.connect("tree_entered", dialog, "call_deferred", ["popup_centered_minsize"])
	SceneSwitcher.connect("currentSceneChanged", dialog, "raise")
	dialogParent.call_deferred("add_child", dialog)
