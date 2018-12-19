extends Control


const m_sequences = { 
	1 : ["ui_up", "ui_up", "ui_up"],
}


func _ready():
	
	$SequenceDetector.connect("sequenceDetected", self, "onSequenceDetected")
	
	for id in m_sequences:
		var added = $SequenceDetector.addSequence( id, m_sequences[id] )
		if added == OK:
			$AvailableSequences.add_item( str(m_sequences[id]) )
	
	
	pass


func onSequenceDetected( id : int ):
	$PerformedSequences.add_item( str( m_sequences ) )
	
	