extends ItemList

var m_variables : Dictionary           setget deleted

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

	for variable in m_variables:
		add_item(str(variable))
		add_item(str(m_variables[variable]))


func setVariables( variables : Dictionary ):
	m_variables = variables
	