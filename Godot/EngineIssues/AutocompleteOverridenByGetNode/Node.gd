extends Node

const DerivedParticles = preload("res://DerivedParticles2D.gd")

onready var foo: DerivedParticles
onready var bar: CPUParticles2D = $"CPUParticles2D"
onready var baz: CPUParticles2D = CPUParticles2D.new()


var my_array = [ CPUParticles2D.new(), 2]
var my_dict = { 1 : DerivedParticles.new() }

func _init():
	foo.emission_normals
	bar.emi
	baz.emission_colors

	my_array[0].emission_colors
	my_dict[1].
