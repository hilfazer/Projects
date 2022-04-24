extends "res://tests/GutTestBase.gd"

const EmptyItemDatabaseGd    = preload("res://tests/items/DB0/EmptyItemDB.gd")
const ItemDatabase1Gd        = preload("res://tests/items/DB1/ItemDB1.gd")


func test_itemDatabaseAccessById():
	var db = ItemDatabase1Gd.new()

	db.initialize()

	var stats = db.getItemStats("HELMET")
	assert_has(stats, "name")
	assert_has(stats, "type")
	assert_has(stats, "defense")
	assert_eq(stats["name"], "Helmet")
	assert_eq(stats["type"], "equipment")
	assert_eq(stats["defense"], 3)


func test_getAllItemStats():
	var db = ItemDatabase1Gd.new()
	db.initialize()

	var stats = db.getAllItemsStats()
	assert_eq(1, stats.size())

	var emptyDb = EmptyItemDatabaseGd.new()
	emptyDb.initialize()

	stats = emptyDb.getAllItemsStats()
	assert_eq(0, stats.size())
