class_name Stats
extends Node

## Tín hiệu khi máu thay đổi
signal hp_changed(current: int, max_hp: int)
## Tín hiệu khi thể lực thay đổi
signal stamina_changed(current: float, max_stamina: float)
## Tín hiệu khi hết máu
signal died

@export var max_hp: int = 1000
@export var current_hp: int = 1000

@export var atk_base: float = 100.0
@export var atk_bonus: float = 0.0

@export var defense: float = 50.0

@export var max_stamina: float = 100.0
@export var current_stamina: float = 100.0

@export var is_hostile: bool = false
@export var title: String = ""

var is_dead: bool = false

func _ready() -> void:
	current_hp = max_hp
	current_stamina = max_stamina

## Nhận sát thương, trừ máu và phát tín hiệu
func take_damage(amount: int) -> int:
	if is_dead or amount <= 0:
		return 0
	var actual_damage: int = mini(amount, current_hp)
	current_hp -= actual_damage
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		current_hp = 0
		is_dead = true
		died.emit()
	return actual_damage

## Hồi máu
func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	current_hp = mini(current_hp + amount, max_hp)
	hp_changed.emit(current_hp, max_hp)

## Trừ thể lực
func consume_stamina(amount: float) -> float:
	if is_dead or amount <= 0.0:
		return 0.0
	var actual: float = minf(amount, current_stamina)
	current_stamina -= actual
	stamina_changed.emit(current_stamina, max_stamina)
	return actual

## Hồi thể lực
func restore_stamina(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	current_stamina = minf(current_stamina + amount, max_stamina)
	stamina_changed.emit(current_stamina, max_stamina)

## Đặt lại trạng thái ban đầu
func reset() -> void:
	is_dead = false
	current_hp = max_hp
	current_stamina = max_stamina
	hp_changed.emit(current_hp, max_hp)
	stamina_changed.emit(current_stamina, max_stamina)
