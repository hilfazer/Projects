HierarchicalSerializer stores serialized nodes' data in a Dictionary where all keys are Strings.
Values can be anything that an be serialized to/from a Resource. So you may use all Godot's built-in types.

You can operate on this Dictionary with following functions:
addSerialized(), remove(), hasKey(), getSerialized(), getKeys()


There's a second Dictionary for any other data the user may want to write. It is accessed with 'userData' property.

Main functionality of this class are serialize() and deserialize() static functions.
Return value of serialize() is supposed to be used as a value in the first Dictionary, like this:

serializer.addSerialized("myKey", serialize( myNode ) )


To make any use of serialization your scripts need to define following methods:
func serialize()
func deserialize( x )
serialize() needs to return data that isn't null (Nulls are evil. If you need to return one, do it with array: return [null]).
deserialize( x ) takes return value of serialize as its only argument.

It gives you good control in how you want to save and load your objects.


Static serialize(node) will serialize node given as argument and will call itself recursively on its children.

Static deserialize(data, parent) will deserialize nodes using 'data' argument. If 'parent' isn't null it will become parent of first deserialized node. Otherwise it won't.
In any case deserialized node is accessible via function's return value. It is NodeGuard object that prevents memory leak (Nodes leak if they're outside of SceneTree). You can access Node with 'node' property.

You can call deserialize() on existing nodes. deserialize() creates Nodes if they don't already exist and if they are also scenes.

Probe.gd allows you to extract information from your Node branch. Call this function on the branch root:

static func scan( node : Node )

on a return value you can call:

func getNotInstantiableNodes()   - to get a list of Nodes serializer will not be able to create

func getNodesNoMatchingDeserialize()   - list of Nodes that have a 

Data you put into HierarchicalSerializer object doesn't automatically go to a file. Saving to and loading from a file is done with following functions:

func saveToFile( filename : String ) -> int

func loadFromFile( filename : String ) -> int

HierarchicalSerializer object doesn't store filename anywhere, you need to store it somewhere else. On the upside one object can be used to handle multiple files.


Files You need:
HierarchicalSerializer.gd
NodeGuard.gd
SaveGameFile.gd
Probe.gd

