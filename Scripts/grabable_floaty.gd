@tool extends Grabable

func _activate_effect(instigator: GAD2010Character):
	instigator.fall_multiplier = 0.05

func _disable_effect(_instigator: GAD2010Character):
	_instigator.fall_multiplier = 1.0
