extends Node


onready var m_timer  = $"Timer"        setget deleted
var m_consumeInput := true             setget deleted
var m_actions : Array                  setget deleted


signal sequenceDetected( id )


func deleted(_a):
	assert(false)


func _ready():
	enable( true )


func _input( event ):
	_handleEvent( event )


func _unhandled_input( event ):
	_handleEvent( event )


func disable():
	set_process_input( false )
	set_process_unhandled_input( false )


# will use _unhandled_input if argument is 'false'
func enable( useInput : bool = true ):
	set_process_input( useInput )
	set_process_unhandled_input( !useInput )


func setConsumingInput( consume : bool ):
	m_consumeInput = consume


# idToSequence is dict of int : array of Strings
func addSequences( idToSequence : Dictionary ) -> Dictionary:
	assert( false )
	return {}


func removeSequences( ids : Array ):
	assert( false )


# adds action that is not neccesarily part of any sequence
# those actions will be able to fail a sequence
func addActions( actions : Array ):
	for action in actions:
		if not m_actions.has( action ):
			m_actions.push_back( action )


func removeActions( actions : Array ):
	for action in actions:
		m_actions.remove( m_actions.find( action ) )


func _handleEvent( event ):
	assert( false )


