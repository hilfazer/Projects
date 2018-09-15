extends ItemList


var m_variables = {}                   setget deleted


func deleted(_a):
	assert(false)


func _ready():
	refreshView()


func updateVariable(varName, value, addValue):
	if value == null:
		m_variables.erase(varName)
	elif addValue == true and m_variables.has(varName):
		m_variables[varName] += value
	else:
		m_variables[varName] = value

	refreshView()


func reset():
	m_variables = {}
	refreshView()


func refreshView():
	clear()
	add_item("  VARIABLE")
	add_item("  VALUE")

	for variable in m_variables:
		add_item(str(variable))
		add_item(str(m_variables[variable]))
