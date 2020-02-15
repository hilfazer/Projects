extends "res://units/Tank.gd"

const TankGd = preload("res://units/Tank.gd")
const HpToColor = {
	4 : TankGd.ColorOffset.GREEN,
	3 : TankGd.ColorOffset.GOLD,
	2 : TankGd.ColorOffset.SILVER,
	1 : TankGd.ColorOffset.SILVER
}

var m_hitPoints = 4    setget deleted


func deleted(_a):
	assert(false)


func _ready():
	._ready()
	setColor( HpToColor[m_hitPoints] )


func handleBulletCollision(bullet):
	if self.m_team != bullet.m_team:
		m_hitPoints -= 1
		if ( m_hitPoints <= 0 ):
				self.destroy()
		else:
			setColor( HpToColor[m_hitPoints] )
