extends VBoxContainer

const LongestSequenceDetectorPath = "res://LongestSequenceDetector.tscn"
const SubsequenceDetectorPath = "res://SubsequenceDetector.tscn"

#warning-ignore:unused_signal
signal detectorSelected( path )


func _ready():
	$"ButtonLongest".connect("button_down", \
		self, "emit_signal", ["detectorSelected", LongestSequenceDetectorPath] )
	$"ButtonSubsequence".connect("button_down", \
		self, "emit_signal", ["detectorSelected", SubsequenceDetectorPath] )


	var evmb = InputEventMouseButton.new()
	evmb.button_index = BUTTON_LEFT
	evmb.pressed = true
	$"ButtonSubsequence"._gui_input(evmb)

	evmb = InputEventMouseButton.new()
	evmb.button_index = BUTTON_LEFT
	evmb.pressed = false
	$"ButtonSubsequence"._gui_input(evmb)
