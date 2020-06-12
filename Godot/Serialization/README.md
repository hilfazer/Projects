# Hierarchical Serializer #

*When "Docs » I/O » Saving games" from Godot documentation web page doesn't cut it.*


## Main features

* serialization of selected Node branch instead of always everything
* serializing to RAM and later to a file instead of straight to a file
* preserving the order of children Nodes
* scanning node branches for potential problems
* ability to define custom function for choosing nodes to be serialized
* calling custom code right after all children were deserialized
* serialized data doesn't require specific format (like Dictionary)
* save files need to have .res/.tres extension


### Files You need

HierarchicalSerializer.gd, NodeGuard.gd, SaveGameFile.gd, Probe.gd

Put those files into YourGameFolder/addons/HierarchicalSerializer/ folder. If You want You can name that last folder something else.

### Modifying your nodes
In order to have your nodes serialized they need to define following methods (3rd one is optional):

* func **serialize**()        - returns dat you want serialized; returning `null` from here means "no data"
* func **deserialize**( x )   - takes return value of *serialize*() as its only argument
* func **post_deserialize**() - is called after node and all its children get deserialized

It gives you good control in how you want to save and load your objects.


### Saving and loading

HierarchicalSerializer.gd object stores serialized nodes' data in a Dictionary where all keys are Strings. Values can be anything that can be serialized to/from a Resource.
To serialize your nodes use following function:

* func **addAndSerialize**( key : String, node : Node )   - serializes and saves a tree starting with *node*

To deserialize previously saved node tree use:

* func **getAndDeserialize**( key : String, parent : Node )   - deserializes node tree as a child of *parent*

That function will fail if key doesn't exist so make sure it does with **hasKey**() function.
Other functions for operating on serialized nodes are:
**addSerialized**(), **removeSerialized**(), **getSerialized**(), **getKeys**().

Serializer will try to read game's version with this code:
`ProjectSettings.get_setting("application/config/version")`
To retrieve version from previously saved file use **getVersion**().

There's also a Dictionary for any other data the user may want to save. It is accessed with **userData** property.

**addAndSerialize**(key, node) and **serialize**(node) will serialize *node* node and will call themselves recursively on its children.

**getAndDeserialize**(key, parent) and **deserialize**(data, parent) will deserialize node tree as a child of *parent* argument if it's not `null`. If it is `null` deserialized tree will not have a parent.
In any case deserialized node is accessible via function's return value. It is NodeGuard.gd object that prevents memory leak (Nodes leak if they're outside of SceneTree). You can access its node with *node* property.

You can deserialize to a parent who already has nodes you want to load. In that case Serializer will call **deserialize**() on them.

### File operations

Data you put into HierarchicalSerializer.gd object doesn't automatically go to a file. Saving to and loading from a file is done with following functions:

* func **saveToFile**( filename : String )
* func **loadFromFile**( filename : String )

HierarchicalSerializer object doesn't store file's name anywhere, you need to store it somewhere else. On the upside one object can be used to handle multiple files.

### Scanning your nodes

Probe.gd allows you to extract information from your Node branch. Call this function on the branch root:

static func **scan**( node : Node )

Return value is an object with following properties:

* **nodesNotInstantiable**   - a list of Nodes serializer will not be able to create
* **nodesNoMatchingDeserialize**   - a list of Nodes that have a *serialize*() but not *deserialize*() function

### Customization

You can set a custom function to tell which nodes will be serialized. Remember to define required methods on them!
First, you need a function object with **is_serializable**() that takes a Node and returns bool. Example:
```
class DetectPersistentGroupFunctor extends Reference:
	func is_serializable( node : Node ) -> bool:
		return node.is_in_group( "persistent" )
```
It needs to extend Reference as well. Now you need to call **setCustomIsNodeSerializable**( functor : Reference ) of your serializer object to set it. You can revert to defaul behaviour with **setDefaultIsNodeSerializable**().

#### Credits

GDQuest YouTube channel with a [video](https://www.youtube.com/watch?v=ML-hiNytIqE&t=200s) about serialization with Resource.

Bitwes and his [GUT](https://github.com/bitwes/Gut) project i used to test my buggy code.

Godot [documentation](https://docs.godotengine.org/en/stable/) team.