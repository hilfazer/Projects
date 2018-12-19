extends Node


var m_sequences : Dictionary
var m_listenTime : float = 0.5
var m_sequenceBuffer : Array


signal sequenceDetected( id )

	
	
func _input(event):
	pass


func addSequence( id : int, sequence : Array ):
	if m_sequences.has( id ):
		return "Sequence ID %d already exists" % id
		
	for seq in m_sequences.values():
		if seq == sequence:
			return "Sequence %s already exists" % str(sequence)
	
	m_sequences[id] = sequence
	
	
func removeSequence( id : int ):
	m_sequences.erase( id )
	
	
