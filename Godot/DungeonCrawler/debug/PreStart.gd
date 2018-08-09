extends Node

const GameInstancePrefix     = "_game_instance"
const FileExtension          = ".inst"

var m_gameInstanceFile                 setget deleted
var m_gameInstanceNumber               setget deleted


func deleted(a):
	assert(false)


func _enter_tree():
	openInstanceFile()
	assert(m_gameInstanceFile.is_open())
	assert(m_gameInstanceNumber > 0)
	setWindowPosition(m_gameInstanceNumber)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		closeInstanceFile()


func openInstanceFile():
	var number = 0
	var file = File.new()
	while not file.is_open():
		number += 1
		if not file.file_exists( numberToPath(number) ):
			file.open( numberToPath(number), File.WRITE )
		else:
			var error = Directory.new().remove( numberToPath(number) )
			if error == OK:
				file.open( numberToPath(number), File.WRITE )

	m_gameInstanceFile = file
	m_gameInstanceNumber = number


func closeInstanceFile():
	assert(m_gameInstanceFile != null)
	assert(m_gameInstanceFile.is_open())
	m_gameInstanceFile.close()
	var error = Directory.new().remove( numberToPath(m_gameInstanceNumber) )
	assert( error == OK )


func numberToPath( number ):
	var directory = get_script().get_path().get_base_dir()
	return directory + "/" + GameInstancePrefix + str(number) + FileExtension


func setWindowPosition( number ):
	var index = (number -1) % 5
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	var positionVectors = [
		(screen_size*0.5 - window_size*0.5),
		Vector2(screen_size.x - window_size.x, 0),
		Vector2(screen_size - window_size)       + Vector2(0, -80),
		Vector2(0,screen_size.y - window_size.y) + Vector2(0, -80),
		Vector2(0,0)
	]

	OS.set_window_position( positionVectors[index] )
