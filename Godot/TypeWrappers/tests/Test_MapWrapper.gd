extends "res://tests/GutTestBase.gd"


const MapWrapperGd = preload("res://MapWrapper.gd")


func test_create():
	var map1 = MapWrapperGd.new()
	assert_eq( map1.container().hash(), {}.hash() )

	var map2 = MapWrapperGd.new( {1:2} )
	assert_eq( map2.container().hash(), {1:2}.hash() )


func test_copy():
	var map1 = MapWrapperGd.new( {'3':2, 1:2.0} )
	var map2 = map1.copy()
	assert_eq( map1.container().hash(), map2.container().hash() )


func test_add():
	var map1 = MapWrapperGd.new( {1:2, 2:3} )
	map1.add( {'s':1, 8:'e'} )
	assert_eq( map1.container().hash(), {1:2, 2:3,'s':1, 8:'e'}.hash() )
	map1.add( {'s':'p', 8:5} )
	assert_eq( map1.container().hash(), {1:2, 2:3,'s':1, 8:'e'}.hash() )


func test_remove():
	var map1 = MapWrapperGd.new( {1:2, 2:3, 3:4} )

	map1.remove( {2:3} )
	assert_eq( map1.container().hash(), {1:2, 3:4}.hash() )
	map1.remove( {2:3} )
	assert_eq( map1.container().hash(), {1:2, 3:4}.hash() )


func test_reset():
	var map1 = MapWrapperGd.new( {1:2, 2:3, 3:4} )
	map1.reset( {1:0, 's':'w'} )
	assert_eq( map1.container().hash(), {1:0, 's':'w'}.hash() )


func test_replace():
	var map1 = MapWrapperGd.new( {'3':2, 1:2.0} )
	map1.replace( {1:3.3, 7:9} )
	assert_eq( map1.container().hash(), {'3':2, 1:3.3}.hash() )


func test_addReplace():
	var map1 = MapWrapperGd.new( {'3':2, 1:2.0} )
	map1.addReplace( {1:3.3, 7:9} )
	assert_eq( map1.container().hash(), {'3':2, 1:3.3, 7:9}.hash() )


func test_signalChanged():
	var map1 = MapWrapperGd.new()
	assert_has_signal(map1, "changed")
	watch_signals(map1)

	map1.add( {2:2} )
	assert_signal_emitted(map1, "changed")
	map1.replace( {3:3} )
	assert_signal_emit_count(map1, "changed", 1)
	map1.addReplace( {2:0, 1:9} )
	assert_signal_emit_count(map1, "changed", 2)


class TestStaticMethods:
	extends "res://tests/GutTestBase.gd"

	func test_notEqual():
		assert_false( MapWrapperGd._notEqual(2, 2) )
		assert_false( MapWrapperGd._notEqual([22], [22]) )
		assert_true( MapWrapperGd._notEqual(2, 2.0) )
		assert_true( MapWrapperGd._notEqual("", ' ') )



