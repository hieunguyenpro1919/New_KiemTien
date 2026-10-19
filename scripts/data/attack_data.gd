class_name AttackData
extends Resource

## Tên định danh đòn đánh
@export var name: String = "Normal Attack"

## Hệ số sát thương của đòn
@export var coef: float = 1.0

## Số tick của pha báo hiệu (windup)
@export var windup_ticks: int = 30

## Số tick của pha gây sát thương (active)
@export var active_ticks: int = 6

## Số tick của pha hồi chiêu (recovery)
@export var recovery_ticks: int = 30

## Tầm đánh hiệu dụng (px)
@export var attack_range: float = 60.0

## Kích thước vùng va chạm hitbox (px)
@export var hitbox_size: Vector2 = Vector2(40.0, 40.0)

## Đánh dấu đòn nặng
@export var is_heavy: bool = false
