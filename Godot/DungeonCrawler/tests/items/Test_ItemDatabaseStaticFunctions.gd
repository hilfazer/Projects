extends "res://tests/GutTestBase.gd"

const ItemDbFactoryGd        = preload("res://engine/items/ItemDbFactory.gd")
const EmptyItemDatabasePath  = "res://tests/items/DB0/EmptyItemDB.gd"
const ItemDatabase1Path      = "res://tests/items/DB1/ItemDB1.gd"
const FooBarBasePath         = "res://tests/items/duplicates/FooBarBase.gd"
const BarBazBasePath         = "res://tests/items/duplicates/BarBazBase.gd"


var params = ParameterFactory.named_parameters( ['path1', 'path2', 'idsArray'],
	[
		[EmptyItemDatabasePath, EmptyItemDatabasePath, [] ],
		[EmptyItemDatabasePath, ItemDatabase1Path, [] ],
		[ItemDatabase1Path, ItemDatabase1Path, ["HELMET"] ],
		[FooBarBasePath, BarBazBasePath, ["BAR"] ],
		[FooBarBasePath, ItemDatabase1Path, [] ],
	]
)

var findItemIdParams = ParameterFactory.named_parameters( ['filePath', 'id'],
	[
		["res://tests/items/DB1/Helmet.tscn", "HELMET"],
		["res://tests/items/DB1/helmet.png",  ItemBase.INVALID_ID],
		["res://tests/does/not.exist",        ItemBase.INVALID_ID],
	]
)


func test_itemDatabaseCheckForDuplicates(prm = use_parameters(params)):
	var db1 = ItemDbFactoryGd.createItemDb(prm.path1)
	var db2 = ItemDbFactoryGd.createItemDb(prm.path2)

	var duplicateIds := ItemDbBase.checkForDuplictates(db1, db2)
	assert_eq_shallow(PoolStringArray(prm.idsArray), duplicateIds)


func test_findIdInItemFile(prm = use_parameters(findItemIdParams)):
	var foundId = ItemDbBase.findIdInItemFile(prm['filePath'])
	assert_eq(prm['id'], foundId)

