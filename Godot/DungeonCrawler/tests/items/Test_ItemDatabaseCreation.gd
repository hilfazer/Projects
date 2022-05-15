extends "res://tests/GutTestBase.gd"

const ItemDbFactoryGd        = preload("res://engine/items/ItemDbFactory.gd")
const EmptyItemDatabasePath  = "res://tests/items/DB0/EmptyItemDB.gd"
const ItemDatabase1Path      = "res://tests/items/DB1/ItemDB1.gd"


func test_emptyDatabaseCreation():
	var db = ItemDbFactoryGd.createItemDb(EmptyItemDatabasePath)
	assert_true(is_instance_valid(db))


func test_singleItemBaseCreation():
	var db = ItemDbFactoryGd.createItemDb(ItemDatabase1Path)
	assert_true(is_instance_valid(db))


func test_setupItemDatabase():
	var db: ItemDbBase = load(ItemDatabase1Path).new()
	var errors := []
	db.setupItemDatabase(errors)

	assert_lt(errors.size(), 1)
