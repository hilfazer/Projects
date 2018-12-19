extends Control


const m_sequences = { 
	1 : ["ui_up", "ui_up", "ui_up"],
	2 : ["ui_up", "ui_up"],          # it won't be detected since it's a subsequence of first item
	3 : ["ui_down"],
	9 : ["ui_up", "ui_up", "ui_up"],
	8 : [],
}


func _ready():
	$"SequenceDetector".setConsumingInput( $"CheckBox".pressed )
	$SequenceDetector.connect("sequenceDetected", self, "onSequenceDetected")
	
	for id in m_sequences:
		var added = $"SequenceDetector".addSequence( id, m_sequences[id] )
		if typeof( added ) == TYPE_INT and added == OK:
			$"AvailableSequences".add_item( str(m_sequences[id]) )
		else:
			print( added )


func _input(event):
	if event is InputEventKey and event.pressed:
		print( "pressed key scancode ", event.scancode )


func onSequenceDetected( id : int ):
	$"PerformedSequences".add_item( str( m_sequences[id] ) )
	
	