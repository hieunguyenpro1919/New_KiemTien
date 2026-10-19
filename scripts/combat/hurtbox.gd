class_name Hurtbox
extends Area2D

signal hit_received(hitbox: Hitbox)

@export var owner_node: Node = null

func _ready() -> void:
	if owner_node == null:
		owner_node = get_parent()
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var hitbox: Hitbox = area
		if hitbox.can_hit(owner_node):
			hitbox.register_hit(owner_node)
			hit_received.emit(hitbox)
