extends Node


var m_sequences : Dictionary
var m_possibleSequences : Array


signal sequenceDetected( id )


func _ready():
	reset()


func _input(event):
	if event.is_action("ui_up"):
		$Timer.start( $Timer.wait_time )
	
#	event.actio


func reset():
	m_possibleSequences = m_sequences.keys()


func addSequence( id : int, sequence : Array ):
	if m_sequences.has( id ):
		return "Sequence ID %d already exists" % id
		
	for seq in m_sequences.values():
		if seq == sequence:
			return "Sequence %s already exists" % str(sequence)
	
	m_sequences[id] = sequence
	
	
func removeSequence( id : int ):
	m_sequences.erase( id )
	
	
