To make debugger crash your program perform following steps:

1. In file 'SceneSwitcher.gd' put a breakpoint on one of these lines:
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
2. Run the project
3. Click the button
