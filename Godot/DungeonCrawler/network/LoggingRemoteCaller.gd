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


func RSET( node : Node, arguments : Array ):
	RSET( node, arguments )
	node.m_rpcTargets && logRPC_RSET( node, arguments )


func RSETu( node : Node, arguments : Array ):
	RSETu( node, arguments )
	node.m_rpcTargets && logRPC_RSET( node, arguments )


func logRPC_RSET( node : Node, arguments ):
	UtilityGd.log( str(node.m_rpcTargets) +" "+ node.get_path() +" "+ str(arguments) )
	