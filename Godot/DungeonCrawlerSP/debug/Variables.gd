extends ItemList

var _variables : Dictionary            setget deleted

func deleted(_a):
	assert(false)


func _ready():
	refreshView()


func updateVariable(varName, value):
	refreshView()


func refreshView():
	clear()
	add_item("  VARIABLE")
	add_item("  VALUE")

	for variable in _variables:
		add_item(str(variable))
		add_item(str(_variables[variable]))


func setVariables( variables : Dictionary ):
	_variables = variables
