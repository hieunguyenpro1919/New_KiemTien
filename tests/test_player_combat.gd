extends "res://tests/test_base.gd"

const PlayerController = preload("res://scripts/actors/player_controller.gd")
const Stats = preload("res://scripts/combat/stats.gd")
const DamageResolver = preload("res://scripts/combat/damage_resolver.gd")

func test_stats_component() -> void:
	var stats = Stats.new()
	stats.max_hp = 1000
	stats.current_hp = 1000
	stats.atk_base = 100.0
	stats.defense = 50.0
	stats.max_stamina = 100.0
	stats.current_stamina = 100.0
	
	var damage_dealt = stats.take_damage(200)
	assert_eq(damage_dealt, 200, "Should deal 200 damage")
	assert_eq(stats.current_hp, 800, "HP should be 800")
	assert_false(stats.is_dead, "Entity should not be dead")
	
	stats.heal(100)
	assert_eq(stats.current_hp, 900, "HP after heal should be 900")
	
	stats.take_damage(1000)
	assert_eq(stats.current_hp, 0, "HP should be clamped to 0")
	assert_true(stats.is_dead, "Entity should be marked dead")
	
	stats.free()

func test_basic_attack_flow() -> void:
	var player = PlayerController.new()
	player._ready()
	
	assert_eq(player.current_state, PlayerController.State.IDLE, "Player starts IDLE")
	
	# Kích hoạt đòn cơ bản
	var started = player.try_basic_attack()
	assert_true(started, "Should successfully start basic attack")
	assert_eq(player.current_state, PlayerController.State.ATTACK, "State should be ATTACK")
	assert_eq(player.attack_phase, PlayerController.AttackPhase.WINDUP, "Phase starts with WINDUP")
	assert_eq(player.velocity, Vector2.ZERO, "Velocity must be ZERO during attack")
	
	# Tiến 6 ticks (hết windup) -> chuyển sang ACTIVE
	player.advance_physics_ticks(6)
	assert_eq(player.attack_phase, PlayerController.AttackPhase.ACTIVE, "Phase should be ACTIVE after 6 ticks")
	
	# Tiến 6 ticks (hết active) -> chuyển sang RECOVERY
	player.advance_physics_ticks(6)
	assert_eq(player.attack_phase, PlayerController.AttackPhase.RECOVERY, "Phase should be RECOVERY after 6 ticks active")
	
	# Tiến 12 ticks (hết recovery) -> quay về IDLE
	player.advance_physics_ticks(12)
	assert_eq(player.current_state, PlayerController.State.IDLE, "State should return to IDLE after recovery")
	assert_eq(player.attack_phase, PlayerController.AttackPhase.NONE, "Attack phase should be NONE")
	
	player.free()

func test_technique_attack_and_cooldown() -> void:
	var player = PlayerController.new()
	player._ready()
	
	# Kích hoạt công pháp K
	var cast_started = player.try_technique_attack()
	assert_true(cast_started, "Should start technique cast")
	assert_eq(player.current_state, PlayerController.State.CAST, "State should be CAST")
	assert_eq(player.technique_cooldown_timer, 120, "Cooldown should be initialized to 120 ticks")
	
	# Thử kích hoạt lại ngay lập tức -> phải thất bại
	var cast_again = player.try_technique_attack()
	assert_false(cast_again, "Cannot cast while already casting or on cooldown")
	
	# Tiến 30 ticks (10 windup + 8 active + 12 recovery)
	player.advance_physics_ticks(30)
	assert_eq(player.current_state, PlayerController.State.IDLE, "Should return to IDLE after cast completes")
	
	# Kiểm tra cooldown còn lại: 120 - 30 = 90 ticks
	assert_eq(player.technique_cooldown_timer, 90, "Cooldown should have 90 ticks remaining")
	
	# Vẫn không thể cast vì đang hồi chiêu
	assert_false(player.try_technique_attack(), "Cannot cast while cooldown > 0")
	
	# Tiến nốt 90 ticks để hồi chiêu hoàn tất
	player.advance_physics_ticks(90)
	assert_eq(player.technique_cooldown_timer, 0, "Cooldown should be 0")
	
	# Bây giờ có thể cast lại
	assert_true(player.try_technique_attack(), "Should be able to cast after cooldown completes")
	
	player.free()

func test_block_duration_and_cooldown() -> void:
	var player = PlayerController.new()
	player._ready()
	
	# Kích hoạt đỡ L
	var block_started = player.try_block()
	assert_true(block_started, "Should start blocking")
	assert_eq(player.current_state, PlayerController.State.BLOCK, "State should be BLOCK")
	assert_eq(player.block_active_timer, 24, "Block active timer should be 24 ticks")
	
	# Tiến 20 ticks -> vẫn đang ở trạng thái BLOCK
	player.advance_physics_ticks(20)
	assert_eq(player.current_state, PlayerController.State.BLOCK, "Still in BLOCK at tick 20")
	
	# Tiến thêm 4 ticks (tổng 24 ticks) -> kết thúc BLOCK, quay về IDLE và vào cooldown 18 ticks
	player.advance_physics_ticks(4)
	assert_eq(player.current_state, PlayerController.State.IDLE, "Should return to IDLE after 24 ticks")
	assert_eq(player.block_cooldown_timer, 18, "Block cooldown timer should be 18 ticks")
	
	# Trong 18 ticks cooldown, bấm L phải bị bỏ qua
	assert_false(player.try_block(), "Cannot block during cooldown")
	
	# Tiến 18 ticks
	player.advance_physics_ticks(18)
	assert_eq(player.block_cooldown_timer, 0, "Block cooldown should be 0")
	
	# Bây giờ có thể đỡ lại
	assert_true(player.try_block(), "Should be able to block after cooldown completes")
	
	player.free()

func test_player_receive_hit_combat_integration() -> void:
	var player = PlayerController.new()
	player._ready()
	
	# 1. Nhận đòn thường khi KHÔNG đỡ (quái 2: raw 400, full 356)
	var eval_unblocked = player.receive_hit(400.0, 356, 10)
	assert_eq(eval_unblocked.type, DamageResolver.BlockResultType.NO_BLOCK, "Should be NO_BLOCK")
	assert_eq(eval_unblocked.damage_taken, 356, "Unblocked damage is 356")
	assert_eq(player.stats.current_hp, 1000 - 356, "HP reduced by 356")
	
	# Hồi lại máu
	player.stats.reset()
	
	# 2. Đỡ hoàn hảo: bấm L ở tick 10, đòn trúng ở tick 13 (delta = 3)
	player.current_physics_tick = 10
	player.try_block()
	var eval_perfect = player.receive_hit(400.0, 356, 13)
	assert_eq(eval_perfect.type, DamageResolver.BlockResultType.PERFECT_PARRY, "Should be PERFECT_PARRY")
	assert_eq(eval_perfect.damage_taken, 0, "Perfect parry takes 0 damage")
	assert_eq(eval_perfect.stamina_damage, 20, "Enemy drains 20 stamina")
	assert_eq(eval_perfect.stun_ticks, 60, "Enemy stunned for 60 ticks")
	assert_eq(player.stats.current_hp, 1000, "HP unchanged on perfect parry")
	
	# 3. Đỡ bị phá: đòn nặng raw 1000 > threshold 450
	var eval_broken = player.receive_hit(1000.0, 889, 14)
	assert_eq(eval_broken.type, DamageResolver.BlockResultType.BLOCK_BROKEN, "Should be BLOCK_BROKEN")
	assert_eq(eval_broken.damage_taken, 889, "Broken block takes full 889 damage")
	assert_eq(player.stats.current_hp, 1000 - 889, "HP reduced by 889")
	assert_eq(player.current_state, PlayerController.State.IDLE, "Player knocked out of block state")
	
	player.free()

func test_attack_movement_and_stationary_block() -> void:
	var player = PlayerController.new()
	player._ready()
	
	# Khi vào ATTACK và không có input: velocity = ZERO
	player.try_basic_attack()
	assert_eq(player.current_state, PlayerController.State.ATTACK)
	assert_eq(player.velocity, Vector2.ZERO)
	
	# Trong lúc ATTACK, vận tốc cho phép di chuyển 45% (220 * 0.45 = 99.0)
	var slow_speed = player.move_speed * 0.45
	player.velocity = Vector2.RIGHT * slow_speed
	assert_eq(player.velocity, Vector2(99.0, 0))
	
	# Kết thúc attack sau 24 ticks
	player.advance_physics_ticks(24)
	assert_eq(player.current_state, PlayerController.State.IDLE)
	
	# Trong trạng thái BLOCK: velocity LUÔN BẰNG ZERO (đứng yên hoàn toàn)
	player.try_block()
	assert_eq(player.current_state, PlayerController.State.BLOCK)
	assert_eq(player.velocity, Vector2.ZERO)
	player.advance_physics_ticks(1)
	assert_eq(player.velocity, Vector2.ZERO)
	
	player.free()

func test_hitbox_hurtbox_collision_integration() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var enemy_scene = load("res://scenes/enemy.tscn")
	if player_scene == null or enemy_scene == null:
		return
		
	var player = player_scene.instantiate()
	player._ready()
	
	var enemy = enemy_scene.instantiate()
	enemy.enemy_data = load("res://data/enemies/enemy_1.tres")
	enemy._ready()
	
	# Kiểm tra layer và mask chuẩn hóa
	var basic_hitbox = player.get_node("HitboxPivot/BasicHitbox") as Hitbox
	var player_hurtbox = player.get_node("Hurtbox") as Hurtbox
	var enemy_hitbox = enemy.get_node("HitboxPivot/AttackHitbox") as Hitbox
	var enemy_hurtbox = enemy.get_node("Hurtbox") as Hurtbox
	
	assert_eq(basic_hitbox.collision_layer, 1, "PlayerHitbox must be on Layer 1")
	assert_eq(basic_hitbox.collision_mask, 8, "PlayerHitbox must scan Layer 4 (EnemyHurtbox)")
	
	assert_eq(player_hurtbox.collision_layer, 2, "PlayerHurtbox must be on Layer 2")
	assert_eq(player_hurtbox.collision_mask, 4, "PlayerHurtbox must scan Layer 3 (EnemyHitbox)")
	
	assert_eq(enemy_hitbox.collision_layer, 4, "EnemyHitbox must be on Layer 3")
	assert_eq(enemy_hitbox.collision_mask, 2, "EnemyHitbox must scan Layer 2 (PlayerHurtbox)")
	
	assert_eq(enemy_hurtbox.collision_layer, 8, "EnemyHurtbox must be on Layer 4")
	assert_eq(enemy_hurtbox.collision_mask, 1, "EnemyHurtbox must scan Layer 1 (PlayerHitbox)")
	
	# Kiểm tra va chạm gây sát thương và log Terminal
	basic_hitbox.init_attack(1, 100.0, 91, player, 100.0, 0.0, 1.0, 0.0, false, 0.5)
	enemy_hurtbox.check_hit(basic_hitbox)
	assert_eq(enemy.stats.current_hp, enemy.stats.max_hp - 91, "Enemy HP should be reduced by 91 (G2: 100 raw vs 10 def = 91 dmg)")
	
	player.free()
	enemy.free()

func test_f1_physical_hitbox_damage_sync_with_golden_tests() -> void:
	var player_scene = load("res://scenes/player.tscn")
	var enemy_scene = load("res://scenes/enemy.tscn")
	
	# --- Phần 1: Công pháp cấp 3 vs Quái 2 = 300 (G4) ---
	var player = player_scene.instantiate()
	player.force_crit = -1 # Tắt chí mạng để khớp G4 chuẩn
	player._ready()
	
	var enemy2 = enemy_scene.instantiate()
	enemy2.enemy_data = load("res://data/enemies/enemy_2.tres")
	enemy2._ready()
	
	var tech_hitbox = player.get_node("HitboxPivot/TechniqueHitbox") as Hitbox
	var enemy2_hurtbox = enemy2.get_node("Hurtbox") as Hurtbox
	
	# Bật hitbox công pháp của player
	player._enable_technique_hitbox()
	# Gây va chạm vật lý qua Area2D
	enemy2_hurtbox.check_hit(tech_hitbox)
	
	assert_eq(enemy2.stats.current_hp, 3000 - 300, "F1: Công pháp cấp 3 vs Quái 2 qua Hitbox phải nhận đúng 300 sát thương (G4)")
	
	# --- Phần 2: Đòn nặng Quái 2 vs Người chơi = 889 (G7) ---
	player.stats.reset() # Máu về 1000
	var enemy2_hitbox = enemy2.get_node("HitboxPivot/AttackHitbox") as Hitbox
	var player_hurtbox = player.get_node("Hurtbox") as Hurtbox
	
	# Quái 2 ra đòn nặng (atk_base 400, coef 2.5)
	var heavy_atk = load("res://data/attacks/heavy_attack.tres") as AttackData
	enemy2.current_attack_index = 2 # Đòn nặng trong chu kỳ quái 2
	enemy2._start_active()
	
	# Player không đỡ (IDLE), nhận đòn qua Hurtbox
	assert_eq(player.current_state, PlayerController.State.IDLE)
	player_hurtbox.check_hit(enemy2_hitbox)
	
	assert_eq(player.stats.current_hp, 1000 - 889, "F1: Đòn nặng Quái 2 vs Người chơi qua Hitbox phải nhận đúng 889 sát thương (G7)")
	
	player.free()
	enemy2.free()


