extends Area3D
class_name HealthComponent

@export var max_hp:int :
	set(value):
		var old_max_hp = max_hp
		max_hp = value
		current_hp = current_hp # Re-clamp HP and emit hp_changed if necessary
		max_hp_changed.emit(old_max_hp, value)

@export var current_hp:int = max_hp :
	set(value):
		var old_hp = current_hp
		current_hp = clamp(value, 0, max_hp)
		hp_changed.emit(old_hp, value)

signal hp_changed(old_hp:int, new_hp:int)
signal max_hp_changed(old_max_hp:int, new_max_hp:int)
