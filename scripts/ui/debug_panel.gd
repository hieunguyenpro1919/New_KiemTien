class_name DebugPanel
extends Control

@onready var content_label: Label = $Panel/ContentLabel

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle"):
		visible = not visible

func _process(_delta: float) -> void:
	if not visible or content_label == null:
		return
		
	var player: PlayerController = get_tree().get_first_node_in_group("player") as PlayerController
	var player_info = "=== PLAYER ===\n"
	if player != null and player.stats != null:
		var state_str = PlayerController.State.keys()[player.current_state]
		player_info += "Máu thật: %d / %d\n" % [player.stats.current_hp, player.stats.max_hp]
		player_info += "Thể lực: %.1f / %.1f\n" % [player.stats.current_stamina, player.stats.max_stamina]
		player_info += "Trạng thái: %s\n" % state_str
		player_info += "Hồi công pháp (K): %d ticks (%.2fs)\n" % [player.technique_cooldown_timer, float(player.technique_cooldown_timer) / 60.0]
		player_info += "Hồi đỡ đòn (L): %d ticks (%.2fs)\n" % [player.block_cooldown_timer, float(player.block_cooldown_timer) / 60.0]
		player_info += "Vị trí: (%.1f, %.1f)\n" % [player.global_position.x, player.global_position.y]
	else:
		player_info += "Không tìm thấy Player\n"
		
	var enemies = get_tree().get_nodes_in_group("enemies")
	var enemy_info = "\n=== QUÁI VẬT (%d) ===\n" % enemies.size()
	for i in range(enemies.size()):
		var enemy = enemies[i] as EnemyController
		if enemy != null and enemy.stats != null:
			var state_str = EnemyController.State.keys()[enemy.current_state]
			enemy_info += "[%s] Tọa độ: (%.1f, %.1f)\n" % [enemy.stats.title, enemy.global_position.x, enemy.global_position.y]
			enemy_info += "  Máu thật: %d / %d | Thể lực thật: %.1f / %.1f\n" % [enemy.stats.current_hp, enemy.stats.max_hp, enemy.stats.current_stamina, enemy.stats.max_stamina]
			enemy_info += "  AI State: %s | Miễn choáng: %d ticks\n" % [state_str, enemy.stun_immunity_timer]
			if enemy.current_state == EnemyController.State.STUNNED:
				enemy_info += "  Choáng còn lại: %d ticks (Cạn thể lực: %s)\n" % [enemy.stun_timer, str(enemy.is_stamina_broken)]
				
	content_label.text = (
		"=========================================\n" +
		"  BẢNG DEBUG — CHỈ ĐỂ PHÁT TRIỂN / DEBUG ONLY  \n" +
		"=========================================\n" +
		player_info +
		enemy_info
	)
