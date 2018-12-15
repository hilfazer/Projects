A script that hanldes switching scenes based on exemple from Godot's documentation.
This version handles passing parameters.

Add SceneSwitcher.gd to autoloads.
Change your scene with switchScene( targetScenePath, params ) function. 'params' is a variable of arbitrary type. It can be accessed in new scene with getParams() function, that will also remove it from SceneSwitcher.
sceneInstanced( scene ) signals is emitted right after new scene gets instanced, before it's added to SceneTree.
