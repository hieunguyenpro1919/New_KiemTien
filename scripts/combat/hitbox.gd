class_name Hitbox
extends Area2D

@export var attack_id: int = 0
@export var raw_damage: float = 0.0
@export var full_damage: int = 0

var attacker: Node = null
var hit_registry: Dictionary = {}

func init_attack(p_attack_id: int, p_raw: float, p_full: int, p_attacker: Node) -> void:
	attack_id = p_attack_id
	raw_damage = p_raw
	full_damage = p_full
	attacker = p_attacker
	hit_registry.clear()

## Kiểm tra xem mục tiêu đã bị trúng đòn này chưa
func can_hit(target: Node) -> bool:
	if target == attacker:
		return false
	if hit_registry.has(target):
		return false
	return true

## Đăng ký mục tiêu đã trúng để không nhận sát thương lặp cho cùng một attack_id
func register_hit(target: Node) -> void:
	hit_registry[target] = true
