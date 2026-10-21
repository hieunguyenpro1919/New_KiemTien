extends "res://tests/test_base.gd"

const PlayerController = preload("res://scripts/actors/player_controller.gd")
const EnemyController = preload("res://scripts/actors/enemy_controller.gd")
const DamageResolver = preload("res://scripts/combat/damage_resolver.gd")

func test_simulation_determinism_same_seed() -> void:
	var scenario_path = "res://tests/replay/combat_scenario_01.json"
	var seed_val = 12345
	
	# Chạy lượt 1
	var log1 = _run_scenario(scenario_path, seed_val)
	# Chạy lượt 2
	var log2 = _run_scenario(scenario_path, seed_val)
	
	assert_eq(log1.size(), log2.size(), "Both runs must produce the exact same number of event snapshots")
	
	var all_match: bool = true
	var mismatch_reason: String = ""
	
	for i in range(log1.size()):
		var s1: Dictionary = log1[i]
		var s2: Dictionary = log2[i]
		
		if s1["tick"] != s2["tick"] or \
		   s1["p_hp"] != s2["p_hp"] or \
		   s1["p_state"] != s2["p_state"] or \
		   s1["e_hp"] != s2["e_hp"] or \
		   abs(s1["e_stamina"] - s2["e_stamina"]) > 0.001 or \
		   s1["e_state"] != s2["e_state"]:
			all_match = false
			mismatch_reason = "Mismatch at tick %d: Run1=%s vs Run2=%s" % [s1["tick"], str(s1), str(s2)]
			break
			
	assert_true(all_match, "Run 1 and Run 2 must match bit-for-bit: " + mismatch_reason)

func test_damage_resolver_rng_determinism() -> void:
	# Kiểm tra với cùng seed
	var rng1 = RandomNumberGenerator.new()
	rng1.seed = 12345
	var results1: Array[int] = []
	for i in range(50):
		var is_crit = (rng1.randf() < 0.10)
		var dmg = DamageResolver.compute_damage(100.0, 0.0, 3.0, 1.0, is_crit, 0.5, 100.0)
		results1.append(dmg.final)
		
	var rng2 = RandomNumberGenerator.new()
	rng2.seed = 12345
	var results2: Array[int] = []
	for i in range(50):
		var is_crit = (rng2.randf() < 0.10)
		var dmg = DamageResolver.compute_damage(100.0, 0.0, 3.0, 1.0, is_crit, 0.5, 100.0)
		results2.append(dmg.final)
		
	assert_eq(results1, results2, "RNG seed 12345 must produce identical sequence of damage outcomes")
	
	# Kiểm tra với seed khác
	var rng3 = RandomNumberGenerator.new()
	rng3.seed = 99999
	var results3: Array[int] = []
	for i in range(50):
		var is_crit = (rng3.randf() < 0.10)
		var dmg = DamageResolver.compute_damage(100.0, 0.0, 3.0, 1.0, is_crit, 0.5, 100.0)
		results3.append(dmg.final)
		
	assert_true(results1 != results3, "Different seed should produce different crit pattern")

func test_determinism_scenario_02_parry_and_heavy_attack() -> void:
	var scenario_path = "res://tests/replay/combat_scenario_02_parry_and_heavy.json"
	var seed_val = 12345
	
	# Chạy lượt 1 và lượt 2
	var log1 = _run_scenario(scenario_path, seed_val)
	var log2 = _run_scenario(scenario_path, seed_val)
	
	assert_eq(log1.size(), 215, "Scenario 2 must run for 215 ticks")
	assert_eq(log1.size(), log2.size(), "Both runs must produce the exact same number of snapshots")
	
	# 1. Kiểm tra tính xác định bit-for-bit giữa hai lượt
	var all_match: bool = true
	var mismatch_reason: String = ""
	for i in range(log1.size()):
		var s1: Dictionary = log1[i]
		var s2: Dictionary = log2[i]
		if s1["tick"] != s2["tick"] or \
		   s1["p_hp"] != s2["p_hp"] or \
		   s1["p_state"] != s2["p_state"] or \
		   s1["e_hp"] != s2["e_hp"] or \
		   abs(s1["e_stamina"] - s2["e_stamina"]) > 0.001 or \
		   s1["e_state"] != s2["e_state"]:
			all_match = false
			mismatch_reason = "Mismatch at tick %d: Run1=%s vs Run2=%s" % [s1["tick"], str(s1), str(s2)]
			break
			
	assert_true(all_match, "Run 1 and Run 2 must match bit-for-bit in Scenario 2: " + mismatch_reason)
	
	# 2. Kiểm chứng sự kiện Đỡ Hoàn Hảo (Perfect Parry) đã thực sự diễn ra tại tick 31
	# Tại tick 31: Quái bị trừ 20 thể lực (100 -> 80), rơi vào trạng thái STUNNED, người chơi 0 mất máu
	var parry_snapshot = log1[30] # tick 31 (0-indexed 30)
	assert_almost_eq(parry_snapshot["e_stamina"], 80.0, 0.001, "Enemy stamina after perfect parry must be 80.0")
	assert_eq(parry_snapshot["e_state"], EnemyController.State.STUNNED, "Enemy state after parry must be STUNNED")
	assert_eq(parry_snapshot["p_hp"], 2000, "Player takes 0 damage on perfect parry")
	
	# 3. Kiểm chứng sự kiện Đòn Nặng (Heavy Attack) đã diễn ra tại tick 207
	# Quái 2 tung đòn nặng (raw 1000) phá vỡ đỡ đòn của người chơi, gây 889 sát thương (1644 - 889 = 755)
	var heavy_snapshot = log1[206] # tick 207 (0-indexed 206)
	assert_eq(heavy_snapshot["p_hp"], 755, "Player must take 889 heavy attack damage (2000 - 356 - 889 = 755)")

func _run_scenario(path: String, p_seed: int) -> Array[Dictionary]:
	var log_result: Array[Dictionary] = []
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("Cannot open scenario file: ", path)
		return log_result
		
	var json_str = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(json_str)
	if parsed == null:
		printerr("Failed to parse JSON: ", path)
		return log_result
		
	var total_ticks: int = int(parsed.get("total_ticks", 180))
	var timeline: Array = parsed.get("timeline", [])
	
	# Sắp xếp các sự kiện theo tick
	var events_by_tick: Dictionary = {}
	for ev in timeline:
		var t = int(ev.get("tick", 0))
		if not events_by_tick.has(t):
			events_by_tick[t] = []
		events_by_tick[t].append(ev)
		
	var rng = RandomNumberGenerator.new()
	rng.seed = p_seed
	
	var player = PlayerController.new()
	player._ready()
	var initial_p_hp = int(parsed.get("player_max_hp", 1000))
	player.stats.max_hp = initial_p_hp
	player.stats.current_hp = initial_p_hp
	var p_pos = parsed.get("player_start_pos", [100, 100])
	player.global_position = Vector2(p_pos[0], p_pos[1])
	
	var enemy = EnemyController.new()
	enemy.enemy_data = load("res://data/enemies/enemy_2.tres")
	enemy._ready()
	var e_pos = parsed.get("enemy_start_pos", [150, 100])
	enemy.global_position = Vector2(e_pos[0], e_pos[1])
	enemy.target_player = player
	
	for current_tick in range(1, total_ticks + 1):
		# Kích hoạt sự kiện theo tick
		if events_by_tick.has(current_tick):
			for ev in events_by_tick[current_tick]:
				var action = ev.get("action", "")
				var type = ev.get("type", "")
				if type == "press":
					if action == "move_right":
						player.update_movement_and_state(Vector2.RIGHT)
					elif action == "move_left":
						player.update_movement_and_state(Vector2.LEFT)
					elif action == "attack_basic":
						player.try_basic_attack()
					elif action == "attack_technique":
						player.try_technique_attack()
					elif action == "block":
						player.try_block()
				elif type == "release":
					if action == "move_right" or action == "move_left":
						player.update_movement_and_state(Vector2.ZERO)
					elif action == "block":
						player._end_block()
		
		# Mô phỏng 1 tick
		player.advance_physics_ticks(1)
		enemy.advance_physics_ticks(1)
		
		# Tương tác đòn đánh nếu player đang active
		if player.current_state == PlayerController.State.ATTACK and player.attack_phase == PlayerController.AttackPhase.ACTIVE:
			if enemy.global_position.distance_to(player.global_position) <= 60.0:
				var res = DamageResolver.compute_damage(player.stats.atk_base, 0.0, 1.0, 0.0, false, 0.5, enemy.stats.defense)
				enemy.stats.take_damage(res.final)
				
		# Tương tác đòn đánh từ quái nếu enemy đang ở tick đầu tiên của ACTIVE
		var cur_atk = enemy._get_current_attack()
		if enemy.current_state == EnemyController.State.ACTIVE and cur_atk != null and enemy.attack_timer == cur_atk.active_ticks:
			if enemy.global_position.distance_to(player.global_position) <= 80.0:
				var dmg_calc = DamageResolver.compute_damage(
					enemy.enemy_data.atk_base,
					enemy.enemy_data.atk_bonus,
					cur_atk.coef,
					0.0,
					false,
					0.5,
					player.stats.defense
				)
				var res = player.receive_hit(dmg_calc.raw, dmg_calc.final, player.current_physics_tick, enemy.stats.max_stamina)
				if res.type == DamageResolver.BlockResultType.PERFECT_PARRY:
					enemy.apply_parry_stun(res.stamina_damage, res.stun_ticks)
		
		# Ghi nhận trạng thái tại tick
		log_result.append({
			"tick": current_tick,
			"p_hp": player.stats.current_hp,
			"p_state": player.current_state,
			"e_hp": enemy.stats.current_hp,
			"e_stamina": enemy.stats.current_stamina,
			"e_state": enemy.current_state
		})
		
	player.free()
	enemy.free()
	return log_result
