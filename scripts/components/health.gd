extends Area3D
class_name HealthComponent

@export var max_hp:float :
	set(value):
		var old_max_hp = max_hp
		var new_max_hp = clamp(value, 0, INF)
		if new_max_hp == max_hp:
			return # Protect against infinite recursion
		max_hp = new_max_hp
		current_hp = current_hp # Re-clamp HP and emit hp_changed if necessary
		max_hp_changed.emit(old_max_hp, value)

@export var current_hp:float = max_hp :
	set(value):
		var old_hp = current_hp
		var new_hp = clamp(value, 0, max_hp)
		if new_hp == current_hp:
			return # Protect against infinite recursion
		current_hp = new_hp
		hp_changed.emit(old_hp, value)

signal hp_changed(old_hp:float, new_hp:float)
signal max_hp_changed(old_max_hp:float, new_max_hp:float)

func _ready() -> void:
	current_hp = max_hp
