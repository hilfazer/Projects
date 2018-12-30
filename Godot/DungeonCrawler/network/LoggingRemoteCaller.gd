extends "res://network/RemoteCaller.gd"


func setRpcTargets( node : Node, targetIds : Array ):
	.setRpcTargets( node, targetIds )
	Debug.info( self, "%s set as RPC targets for %s" % [targetIds, node.get_path()] )


# calls rpc for clients who are interested in it
func RPC( node : Node, functionAndArguments : Array ):
	.RPC( node, functionAndArguments )
	logRPC_RSET( node, functionAndArguments )


func RPCu( node : Node, functionAndArguments : Array ):
	.RPCu( node, functionAndArguments )
	logRPC_RSET( node, functionAndArguments )


func RPCid( node : Node, id : int, functionAndArguments : Array ):
	.RPCid( node, id, functionAndArguments )
	logRPCid_RSETid( node, id, functionAndArguments )
	
	
func RPCmaster( node : Node, functionAndArguments : Array ):
	.RPCid( node, node.get_network_master(), functionAndArguments )
	logRPCid_RSETid( node, node.get_network_master(), functionAndArguments )


func RPCuid( node : Node, id : int, functionAndArguments : Array ):
	.RPCuid( node, id, functionAndArguments )
	logRPCid_RSETid( node, id, functionAndArguments )


func RSET( node : Node, arguments : Array ):
	.RSET( node, arguments )
	logRPC_RSET( node, arguments )


func RSETu( node : Node, arguments : Array ):
	.RSETu( node, arguments )
	logRPC_RSET( node, arguments )


func logRPC_RSET( node : Node, arguments ):
	var rpcTargets = str(node.m_rpcTargets) if node.m_rpcTargets else "[NO RPC TARGETS]"
	Debug.info( self, rpcTargets +" "+ node.get_path() +" "+ str(arguments) )


func logRPCid_RSETid( node : Node, id, arguments ):
	Debug.info( self, str(id) +" "+ node.get_path() +" "+ str(arguments) )