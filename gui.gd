extends Control

@onready var hpbar = $HpBar
@onready var hplabel = $HpLabel
@onready var ammolabel = $AmmoLabel
@onready var dmg_ind = $DmgInd

var hp: int = 0:
	set(value):
		hp = value
		hpbar.value = value
		hplabel.text = "%d/100" % int(value)

var magazine_ammo: int = 0:
	set(value):
		magazine_ammo = value
		ammolabel.text = "%d / %d" % [value, ammo]

var ammo: int = 0:
	set(value):
		ammo = value
		ammolabel.text = "%d / %d" % [magazine_ammo, value]
		
func take_damage():
	dmg_ind.visible = true
	dmg_ind.color = Color(1.0,0.0,0.0,0.5)
	var tween = create_tween()
	tween.tween_property(dmg_ind,"color:a",0.0,0.5)
	await tween.finished
	dmg_ind.visible = false

