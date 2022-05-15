extends Reference


static func createItemDb( ItemDbPath: String ) -> ItemDbBase:
	var databaseScene: ItemDbBase = load(ItemDbPath).new()
	var errors := []
	databaseScene.setupItemDatabase(errors)

	for error in errors:
		print(error)

	return databaseScene

