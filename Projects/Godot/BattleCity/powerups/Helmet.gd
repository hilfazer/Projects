const ShieldScn = preload("res://effects/shield.tscn")
const ShieldGd = preload("res://powerups/shield.gd")

func execute( stage, tank ):
	var shieldEffect = ShieldScn.instance()
	shieldEffect.set_script(ShieldGd)
	tank.add_child(shieldEffect)
	
	