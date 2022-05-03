extends GutTest


var params = ParameterFactory.named_parameters( ['array'],
	[
		[ ['p'] ]
	]
)


func test_assert_eq_shallow_array_from_param_to_pool_array(p = use_parameters(params)):
	var pool_array = PoolByteArray()
	assert_eq_shallow(p.array, pool_array)


func test_assert_eq_shallow_pool_array_to_array_from_param(p = use_parameters(params)):
	var pool_array = PoolByteArray()
	assert_eq_shallow(pool_array, p.array)


func test_compare(p = use_parameters(params)):
	var pool_array = PoolByteArray()
	var cmp = compare_shallow(['cxz'], pool_array)
	print( cmp.summary != null )
	assert_ne( cmp.summary, null )
