extends Node


var m_consumeInput : bool = true      setget setConsumingInput
var m_sequences : Dictionary          setget deleted
var m_possibleSequences : Array       setget deleted
var m_bestMatch = null                setget deleted
var m_positionInSequence : int = 0    setget deleted


signal sequenceDetected( id )


func deleted(_a):
	assert(false)


func _ready():
	reset()


func _input(event):
	var action : String
	for seqId in m_possibleSequences:
		var sequence = m_sequences[seqId]
		if m_positionInSequence < sequence.size():
			if event.is_action_pressed( sequence[m_positionInSequence] ):
				action = sequence[m_positionInSequence]

	if not action.empty():
		validateSequences( action )
	
	
func validateSequences( action : String ):
	var newPossibleSequences : Array = []
	for seqId in m_possibleSequences:
		if m_sequences[seqId][m_positionInSequence] == action:
			if m_sequences[seqId].size() > m_positionInSequence + 1:
				 newPossibleSequences.append(seqId)
			else:
				m_bestMatch = seqId
	
	if m_consumeInput:
		get_tree().set_input_as_handled()
		
	if newPossibleSequences.empty():
		emit_signal("sequenceDetected", m_bestMatch)
		reset()
	else:
		$Timer.start( $Timer.wait_time )
		m_possibleSequences = newPossibleSequences
		m_positionInSequence += 1


func reset():
	m_possibleSequences = m_sequences.keys()
	m_positionInSequence = 0
	m_bestMatch = null


func addSequence( id : int, sequence : Array ):
	if sequence.size() == 0:
		return "Input sequence is empty"
		
	if m_sequences.has( id ):
		return "Sequence ID %d already exists" % id
		
	for seq in m_sequences.values():
		if seq == sequence:
			return "Sequence %s already exists" % str(sequence)
	
	m_sequences[id] = sequence
	reset()
	return OK
	
	
func removeSequence( id : int ):
	m_sequences.erase( id )
	
	
func setConsumingInput( consume : bool ):
	m_consumeInput = consume


