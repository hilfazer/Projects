extends "res://tests/GutTestBase.gd"

const EmptyItemDatabaseGd    = preload("res://tests/items/DB0/EmptyItemDB.gd")
const ItemDatabase1Gd        = preload("res://tests/items/DB1/ItemDB1.gd")


func test_emptyDatabaseCreation():
	var db = EmptyItemDatabaseGd.new()
	var errors = db.initialize()

	assert_true(is_instance_valid(db))
	assert_true(db.isInitialized())
	assert_eq(errors.size(), 0)


func test_singleItemBaseCreation():
	var db = ItemDatabase1Gd.new()
	var errors = db.initialize()

	assert_true(is_instance_valid(db))
	assert_true(db.isInitialized())
	assert_eq(errors.size(), 0)
