extends Node2D

@onready var player: PlayerController = $Player
@onready var info_label: Label = $UI/InfoLabel

func _process(_delta: float) -> void:
	if player != null and info_label != null:
		var state_str = "IDLE" if player.current_state == PlayerController.State.IDLE else "MOVE"
		var speed_current = player.velocity.length()
		info_label.text = (
			"Kiếm Tiên Prototype — Milestone M1\n" +
			"Điều khiển: WASD / Phím mũi tên để di chuyển (8 hướng)\n" +
			"Trạng thái: %s | Vận tốc: (%.1f, %.1f) | Tốc độ: %.1f px/s\n" +
			"Hướng nhìn: (%.2f, %.2f)\n" +
			"Phím R: Đặt lại vị trí nhân vật"
		) % [state_str, player.velocity.x, player.velocity.y, speed_current, player.facing_direction.x, player.facing_direction.y]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_scene"):
		if player != null:
			player.position = Vector2(640, 360)
			player.velocity = Vector2.ZERO
			player.current_state = PlayerController.State.IDLE
