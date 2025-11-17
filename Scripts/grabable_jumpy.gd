@tool extends Grabable

func _activate_effect(instigator: GAD2010Character):
	instigator.jump_multiplier = 1.5

func _disable_effect(instigator: GAD2010Character):
	instigator.jump_multiplier = 1.0
