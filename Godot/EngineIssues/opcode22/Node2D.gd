extends Node2D

const InnerClass =           preload("res://InnerClass.gd").InnerClass

func _ready():
	InnerClass.make()
