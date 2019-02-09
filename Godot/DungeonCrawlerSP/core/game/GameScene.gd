extends Node


enum Params { Module, PlayerUnitsData }


signal gameFinished()


func finish():
	call_deferred( "emit_signal", "gameFinished" )
