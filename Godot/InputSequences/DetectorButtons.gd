extends VBoxContainer

const LongestSequenceDetectorPath = "res://LongestSequenceDetector.tscn"
const SubsequenceDetectorPath = "res://SubsequenceDetector.tscn"

#warning-ignore:unused_signal
signal detectorSelected( path )


func _ready():
	$ButtonLongest.connect("button_down", \
		self, "emit_signal", ["detectorSelected", LongestSequenceDetectorPath] )
	$ButtonSubsequence.connect("button_down", \
		self, "emit_signal", ["detectorSelected", SubsequenceDetectorPath] )

