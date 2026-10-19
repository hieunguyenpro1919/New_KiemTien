class_name Hurtbox
extends Area2D

signal hit_received(hitbox: Hitbox)

@export var owner_node: Node = null

func _ready() -> void:
	if owner_node == null:
		owner_node = get_parent()
	monitoring = true
	monitorable = true
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		check_hit(area)

func check_hit(hitbox: Hitbox) -> void:
	var target = owner_node if owner_node != null else get_parent()
	if hitbox.can_hit(target):
		hitbox.register_hit(target)
		print("[COLLISION] Hitbox trúng Hurtbox: ", target.name if target != null else "Unknown")
		hit_received.emit(hitbox)


