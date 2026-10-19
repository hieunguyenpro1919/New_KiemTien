extends Node2D

@onready var player: PlayerController = $Player
@onready var info_label: Label = $UI/InfoLabel

func _process(_delta: float) -> void:
	if player != null and info_label != null:
		var state_str: String = "IDLE"
		match player.current_state:
			PlayerController.State.IDLE: state_str = "IDLE"
			PlayerController.State.MOVE: state_str = "MOVE"
			PlayerController.State.ATTACK: state_str = "ATTACK (Đòn cơ bản)"
			PlayerController.State.CAST: state_str = "CAST (Công pháp)"
			PlayerController.State.BLOCK: state_str = "BLOCK (Đỡ đòn)"
			
		var speed_current = player.velocity.length()
		var hp_str = "%d / %d" % [player.stats.current_hp, player.stats.max_hp] if player.stats != null else "1000 / 1000"
		var tech_cd_sec = float(player.technique_cooldown_timer) / 60.0
		var block_cd_sec = float(player.block_cooldown_timer) / 60.0
		
		info_label.text = (
			"Kiếm Tiên Prototype — Milestone M2.2\n" +
			"Điều khiển: WASD = Đi lại | J = Đòn cơ bản | K = Công pháp | L = Đỡ đòn | R = Đặt lại\n" +
			"Trạng thái: %s | Máu: %s | Tốc độ: %.1f px/s\n" +
			"Hồi công pháp (K): %.2fs | Hồi đỡ (L): %.2fs\n" +
			"Hướng nhìn: (%.2f, %.2f)"
		) % [state_str, hp_str, speed_current, tech_cd_sec, block_cd_sec, player.facing_direction.x, player.facing_direction.y]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_scene"):
		get_tree().reload_current_scene()
