extends "res://tests/GutTestBase.gd"

const SetWrapperGd = preload("res://SetWrapper.gd")


func test_create():
	var setWrapper = SetWrapperGd.new( [2,4] )
	assert_eq( setWrapper.container(), [2,4] )

	var setWrapper2 = SetWrapperGd.new( [] )
	assert_eq( setWrapper2.container(), [] )


func test_copy():
	var setWrapper = SetWrapperGd.new( [2,4] )
	var setWrapper2 = setWrapper.copy()
	assert_eq( setWrapper.container(), setWrapper2.container() )


func test_add():
	var setWrapper = SetWrapperGd.new( [1,2,3] )
	setWrapper.add( [4] )
	assert_eq( setWrapper.container(), [1,2,3,4] )


func test_remove():
	var setWrapper = SetWrapperGd.new( [1,2,3,4] )
	setWrapper.remove( [3] )
	assert_eq( setWrapper.container(), [1,2,4] )
	setWrapper.remove( [8] )
	assert_eq( setWrapper.container(), [1,2,4] )


func test_reset():
	var setWrapper = SetWrapperGd.new( [1,'2y',3,4] )
	setWrapper.reset( [4,3,""] )
	assert_eq( setWrapper.container(), [4,3,""] )


func test_signalChanged():
	var setWrapper = SetWrapperGd.new( [1,2,4] )
	assert_has_signal(setWrapper, "changed")
	watch_signals(setWrapper)

	setWrapper.add( [{2:2}] )
	assert_signal_emitted(setWrapper, "changed")
	setWrapper.add( [4] )
	assert_signal_emit_count(setWrapper, "changed", 1)
	setWrapper.remove( [1] )
	assert_signal_emit_count(setWrapper, "changed", 2)


class TestStaticMethods:
	extends "res://tests/GutTestBase.gd"

	func test_unique():
		var array = SetWrapperGd.unique( [1, 2, 3, 2, 6, 8, 1] )
		assert_eq( array, [1, 2, 3, 6, 8])
