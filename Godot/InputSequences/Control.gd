extends Control


const sequences = { 
	1 : ["ui_up", "ui_up", "ui_up"],
}


func _ready():
	
	$SequenceDetector.connect("sequenceDetected", self, "onSequenceDetected")
	
	for id in sequences:
		var added = $SequenceDetector.addSequence( id, sequences[id] )
		if added:
			$AvailableSequences.add_item( str(sequences[id]) )
	
	pass


func onSequenceDetected( id : int ):
	$PerformedSequences.add_item( str( sequences ) )
	
	