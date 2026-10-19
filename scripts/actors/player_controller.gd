class_name PlayerController
extends CharacterBody2D

enum State {
	IDLE,
	MOVE
}

## Tốc độ di chuyển cơ bản (px/s) theo SPEC mục 5.1
@export var move_speed: float = 220.0

var current_state: State = State.IDLE
var facing_direction: Vector2 = Vector2.DOWN

@onready var facing_marker: Node2D = get_node_or_null("FacingMarker")

func _physics_process(_delta: float) -> void:
	var input_vec: Vector2 = get_movement_input()
	update_movement_and_state(input_vec)
	move_and_slide()

## Đọc vector đầu vào từ Input Map
func get_movement_input() -> Vector2:
	var input_vec := Vector2.ZERO
	input_vec.x = Input.get_axis("move_left", "move_right")
	input_vec.y = Input.get_axis("move_up", "move_down")
	
	# Chuẩn hóa vector di chuyển đường chéo để không nhanh hơn đi thẳng
	if input_vec.length_squared() > 0.0:
		input_vec = input_vec.normalized()
	return input_vec

## Cập nhật trạng thái và vận tốc dựa trên vector di chuyển
func update_movement_and_state(input_vec: Vector2) -> void:
	if input_vec != Vector2.ZERO:
		current_state = State.MOVE
		velocity = input_vec * move_speed
		facing_direction = input_vec
		if facing_marker != null:
			facing_marker.position = facing_direction * 24.0
	else:
		current_state = State.IDLE
		velocity = Vector2.ZERO
