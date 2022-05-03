extends "res://tests/GutTestBase.gd"

const ItemDbFactoryGd        = preload("res://engine/items/ItemDbFactory.gd")
const EmptyItemDatabasePath  = "res://tests/items/DB0/EmptyItemDB.gd"
const ItemDatabase1Path      = "res://tests/items/DB1/ItemDB1.gd"


var params = ParameterFactory.named_parameters( ['path1', 'path2', 'idsArray'],
	[
		[EmptyItemDatabasePath, EmptyItemDatabasePath, [] ],
		[EmptyItemDatabasePath, ItemDatabase1Path, [] ],
		[ItemDatabase1Path, ItemDatabase1Path, ["HELMET"] ],
	]
)


func test_itemDatabaseCheckForDuplicates(prm = use_parameters(params)):
	var db1 = ItemDbFactoryGd.createItemDb(prm.path1)
	var db2 = ItemDbFactoryGd.createItemDb(prm.path2)

	var duplicateIds : PoolStringArray = ItemDbBase.checkForDuplictates(db1, db2)
	assert_eq_shallow(prm.idsArray, duplicateIds)
	pending()
