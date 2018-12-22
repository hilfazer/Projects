extends Node

var m_consumeInput : bool = true       setget setConsumingInput

var m_sequences : Dictionary           setget deleted
var m_actions : Array                  setget deleted
var m_allActions : Array               setget deleted

var m_possibleSequences : Array        setget deleted
var m_positionInSequence : int = 0     setget deleted

onready var m_timer : Timer = $"Timer"


signal sequenceDetected( id )


func deleted(_a):
	assert(false)


func _input( event ):
	var eventAction : String
	for action in m_allActions:
		if event.is_action_pressed(action):
			eventAction = action
			break

	if not eventAction.empty():
		_validateSequence( eventAction )
		if m_consumeInput:
			get_tree().set_input_as_handled()


func reset():
	m_possibleSequences = m_sequences.keys()
	m_positionInSequence = 0


func addSequence( id : int, sequence : Array ):
	if sequence.size() == 0:
		return "Input sequence is empty"

	if m_sequences.has( id ):
		return "Sequence ID %d already exists" % id

	for seq in m_sequences.values():
		if seq == sequence:
			return "Sequence %s already exists" % str(sequence)

	m_sequences[id] = sequence
	_updateAllActions()
	reset()
	return OK


func removeSequence( id : int ):
	m_sequences.erase( id )
	_updateAllActions()
	reset()


# adds action that is not neccesarily part of any sequence
# those actions will be able to fail a sequence
func addAction( action : String ):
	if not m_actions.has( action ):
		m_actions.push_back( action )
	_updateAllActions()


func removeAction( action : String ):
	m_actions.remove( m_actions.find( action ) )
	_updateAllActions()


func setConsumingInput( consume : bool ):
	m_consumeInput = consume


func _updateAllActions():
	var allActions : Array = []
	for sequence in m_sequences.values():
		for action in sequence:
			if not allActions.has( action ):
				allActions.append( action )

	for action in m_actions:
		if not allActions.has( action ):
			allActions.append( action )

	m_allActions = allActions


func _validateSequence( action : String ):
	var newPossibleSequences : Array = []

	for seqId in m_possibleSequences:
		if m_sequences[seqId][m_positionInSequence] == action:
			if m_sequences[seqId].size() == m_positionInSequence + 1:
				emit_signal( "sequenceDetected", seqId )
			else:
				 newPossibleSequences.append(seqId)

	if newPossibleSequences.empty():
		reset()
	else:
		m_timer.start( m_timer.wait_time )
		m_possibleSequences = newPossibleSequences
		m_positionInSequence += 1
