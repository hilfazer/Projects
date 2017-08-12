extends ItemList


var m_variables = {}


func _ready():
	refreshView()


func updateVariable(name, value):
	if value == null:
		m_variables.erase(name)
	else:
		m_variables[name] = value

	refreshView()


func refreshView():
	clear()
	add_item("  VARIABLE")
	add_item("  VALUE")

	for variable in m_variables:
		add_item(str(variable))
		add_item(str(m_variables[variable]))
	