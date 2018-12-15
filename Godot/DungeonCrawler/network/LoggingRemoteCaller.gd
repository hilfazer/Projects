extends "res://network/RemoteCaller.gd"


func _init( sceneTree ).( sceneTree ):
	pass


# calls rpc for clients who are interested in it
func RPC( node : Node, functionAndArguments : Array ):
	.RPC( node, functionAndArguments )
	node.m_rpcTargets && logRPC_RSET( node, functionAndArguments )


func RPCu( node : Node, functionAndArguments : Array ):
	.RPCu( node, functionAndArguments )
	node.m_rpcTargets && logRPC_RSET( node, functionAndArguments )


func RPCid( node : Node, id : int, functionAndArguments : Array ):
	.RPCid( node, id, functionAndArguments )
	logRPCid_RSETid( node, id, functionAndArguments )


func RPCuid( node : Node, id : int, functionAndArguments : Array ):
	.RPCuid( node, id, functionAndArguments )
	logRPCid_RSETid( node, id, functionAndArguments )


func RSET( node : Node, arguments : Array ):
	.RSET( node, arguments )
	node.m_rpcTargets && logRPC_RSET( node, arguments )


func RSETu( node : Node, arguments : Array ):
	.RSETu( node, arguments )
	node.m_rpcTargets && logRPC_RSET( node, arguments )


func logRPC_RSET( node : Node, arguments ):
	UtilityGd.log( str(node.m_rpcTargets) +" "+ node.get_path() +" "+ str(arguments) )
	

func logRPCid_RSETid( node : Node, id, arguments ):
	UtilityGd.log( str(id) +" "+ node.get_path() +" "+ str(arguments) )