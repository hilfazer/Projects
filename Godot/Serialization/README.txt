HierarchicalSerializer stores data in a Dictionary where all keys are Strings.
Values can be anything that an be serialized to/from .json file. You don't need to store only serialized nodes, you can store other data as well.
You can operate on this Dictionary with following functions:
add(), remove(), hasKey(), getValue(), getKeys()

Main functionality of this class are serialize() and deserialize() static functions.
Return value of serialize() is supposed to be used as a value in aforementioned Dictionary.


To make any use of serialization your scripts need to define following methods:
func serialize()
func deserialize( x )
serialize() needs to return data that isn't null (Nulls are evil. If you really need to return one, do it with array: return [null]).
deserialize( x ) takes return value of serialize as its only argument.

It gives you good control in how you want to save and load your objects.


Static serialize(node) will serialize node given as argument and will call itself recursively on its children.

Static deserialize(data, parent) will deserialize nodes using 'data' argument. If 'parent' isn't null it will become parent of first deserialized node. Otherwise it won't.
In any case deserialized node is accessible via function's return value. It is NodeGuard object that prevents memory leak (Nodes leak if they're outside of SceneTree). You can access Node with 'node' property.

You can call deserialize() on existing nodes. deserialize() creates Nodes if they don't already exist and if they are also scenes. To get a list of Nodes serializer will not be able to create use:
func serializeTest() node : Node ) -> SerializeTestResults
and call this function on its return value:
func getNotInstantiableNodes() -> Array


Data you put into HierarchicalSerializer object doesn't automatically go to a file. Saving to a file is done with:
func saveToFile( filename : String, format := false ) -> int
If 'format' is true .json file will be formatted to be more readable. Otherwise it will be less readable but more compact.

Loading is done with:
func loadFromFile( filename : String ) -> int

HierarchicalSerializer object doesn't store filename anywhere, you need to store it somewhere else. On the upside one object can be used to handle multiple files.



Files You need:
HierarchicalSerializer.gd

#TODO: example
