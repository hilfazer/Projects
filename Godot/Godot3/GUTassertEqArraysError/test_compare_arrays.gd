extends GutTest

func test_assert_eq_shallow_array_to_pool_array():
	var pool_array = PoolByteArray()
	assert_eq_shallow([], pool_array)

func test_assert_eq_shallow_pool_array_to_array():
	var pool_array = PoolByteArray()
	assert_eq_shallow(pool_array, [8,0])


func test_assert_eq_deep_array_to_pool_array():
	var pool_array = PoolByteArray()
	assert_eq_deep([], pool_array)


func test_compare_array_to_pool_array():
	var pool_array = PoolByteArray()
	var cmp = compare_shallow(['cxz'], pool_array)
	assert_ne( cmp.summary, null )


func test_compare_pool_array_to_array():
	var pool_array = PoolByteArray()
	var cmp = compare_shallow(pool_array, ['cxz'])
	assert_ne( cmp.summary, null )

