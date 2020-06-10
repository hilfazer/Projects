extends "./SequenceDetectorBase.gd"


var m_sequences : = {}                 setget deleted
var m_possibleSequences := []          setget deleted
var m_bestMatch = null                 setget deleted
var m_positionInSequence := 0          setget deleted
var m_allActions : = []                setget deleted

onready var _timer : Timer = $"Timer"


func deleted(_a):
	assert(false)


func _enter_tree():
	reset()


func reset():
	m_possibleSequences = m_sequences.keys()
	m_positionInSequence = 0
	m_bestMatch = null


func addSequences( idToSequence : Dictionary ) -> Dictionary:
	var discardedIdToMessage : Dictionary = {}
	for id in idToSequence:
		var result = _addSequence( id, idToSequence[id] )
		if not typeof(result) == TYPE_INT or not result == OK:
			discardedIdToMessage[id] = result

	reset()
	_updateAllActions()
	return discardedIdToMessage


func removeSequences( ids : Array ):
	for id in ids:
		m_sequences.erase( id )
	_updateAllActions()
	reset()


func addActions( actions : Array ):
	.addActions( actions )
	_updateAllActions()


func removeActions( actions : Array ):
	.removeActions( actions )
	_updateAllActions()


func _handleEvent( event ):
	var action : String
	for seqId in m_possibleSequences:
		var sequence = m_sequences[seqId]
		if m_positionInSequence < sequence.size():
			if event.is_action_pressed( sequence[m_positionInSequence] ):
				action = sequence[m_positionInSequence]

	if not action.empty():
		_validateSequences( action )
		if m_consumeInput:
			get_tree().set_input_as_handled()


func _validateSequences( action : String ):
	var newPossibleSequences : Array = []
	for seqId in m_possibleSequences:
		if m_sequences[seqId][m_positionInSequence] == action:
			if m_sequences[seqId].size() > m_positionInSequence + 1:
				 newPossibleSequences.append(seqId)
			else:
				m_bestMatch = seqId


	if newPossibleSequences.empty():
		emit_signal("sequenceDetected", m_bestMatch)
		reset()
	else:
		_timer.start( _timer.wait_time )
		m_possibleSequences = newPossibleSequences
		m_positionInSequence += 1


func _addSequence( id : int, sequence : Array ):
	if sequence.size() == 0:
		return "Input sequence is empty"

	if m_sequences.has( id ):
		return "Sequence ID %d already exists" % id

	for seq in m_sequences.values():
		if seq == sequence:
			return "Sequence %s already exists" % str(sequence)
		elif isSubsequence( sequence, seq ):
			return "Sequence is a subsequence of %s" % str(seq)
		elif isSubsequence( seq, sequence ):
			return "Sequence is a supersequence of %s" % str(seq)

	m_sequences[id] = sequence
	return OK


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


static func isSubsequence( seq1, seq2 ):
	if seq1.size() > seq2.size():
		return false

	for i in seq1.size():
		if seq1[i] != seq2[i]:
			return false
		elif i == seq2.size() - 1:
			return false

	return true
