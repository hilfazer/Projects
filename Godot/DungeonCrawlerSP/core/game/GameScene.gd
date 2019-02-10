extends Node


enum Params { Module, PlayerUnitsData }
enum State { Initial, Creating, Running, Finished }

var m_state : int = State.Initial      setget deleted # _changeState

signal gameFinished()


func deleted(_a):
	assert(false)


func finish():
	_changeState( State.Finished )


func setPaused( enabled : bool ):
	get_tree().paused = enabled
	Debug.updateVariable( "Pause", "Yes" if get_tree().paused else "No" )


func _changeState( state : int ):
	assert( m_state != State.Finished )

	if state == m_state:
		Debug.warn(self, "changing to same state")
		return

	if state == State.Finished:
		call_deferred( "emit_signal", "gameFinished" )

	elif state == State.Running:
		setPaused(false)

	elif state == State.Creating:
		setPaused(true)

	m_state = state