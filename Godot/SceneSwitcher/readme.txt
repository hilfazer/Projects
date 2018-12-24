A script that handles switching scenes based on example from Godot's documentation.
This version handles passing parameters.

Add SceneSwitcher.gd to autoloads.
Change your scene with switchScene( targetScenePath, params ) function. 'params' is a variable of arbitrary type. It can be accessed in new scene with getParams() function.
sceneInstanced( scene ) signal is emitted right after new scene gets instanced, before it's added to SceneTree.
