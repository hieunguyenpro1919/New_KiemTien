extends "res://tests/test_base.gd"

const EnemyController = preload("res://scripts/actors/enemy_controller.gd")
const EnemyData = preload("res://scripts/data/enemy_data.gd")
const AttackData = preload("res://scripts/data/attack_data.gd")
const Stats = preload("res://scripts/combat/stats.gd")

func test_detection_and_chase() -> void:
	var enemy = EnemyController.new()
	var data = load("res://data/enemies/enemy_1.tres")
	enemy.enemy_data = data
	enemy._ready()
	
	# Tạo dummy player node
	var dummy_player = Node2D.new()
	enemy.target_player = dummy_player
	
	# 1. Player ở khoảng cách 400px (> detect_range 300px)
	enemy.global_position = Vector2.ZERO
	dummy_player.global_position = Vector2(400, 0)
	enemy.advance_physics_ticks(1)
	assert_eq(enemy.current_state, EnemyController.State.IDLE, "Enemy stays IDLE outside detect range")
	assert_eq(enemy.velocity, Vector2.ZERO, "Velocity is ZERO when IDLE")
	
	# 2. Player tiến vào khoảng cách 200px (<= detect_range 300px)
	dummy_player.global_position = Vector2(200, 0)
	enemy.advance_physics_ticks(1)
	assert_eq(enemy.current_state, EnemyController.State.CHASE, "Enemy enters CHASE when player detected")
	assert_almost_eq(enemy.velocity.x, data.move_speed, 0.001, "Enemy moves towards player at move_speed")
	
	# 3. Player chạy xa hơn 600px (> leash_range 600px)
	dummy_player.global_position = Vector2(700, 0)
	enemy.advance_physics_ticks(1)
	assert_eq(enemy.current_state, EnemyController.State.IDLE, "Enemy drops chase outside leash range")
	assert_eq(enemy.velocity, Vector2.ZERO, "Velocity stops when returning to IDLE")
	
	dummy_player.free()
	enemy.free()

func test_enemy2_attack_cycle() -> void:
	var enemy = EnemyController.new()
	var data: EnemyData = load("res://data/enemies/enemy_2.tres")
	enemy.enemy_data = data
	enemy._ready()
	
	assert_eq(data.attack_cycle.size(), 3, "Enemy 2 must have 3 attacks in cycle")
	
	# Đòn 1: Thường (raw 400, coef 1.0)
	var atk0 = data.attack_cycle[0]
	assert_almost_eq(atk0.coef, 1.0, 0.001, "Attack 0 coef must be 1.0")
	assert_false(atk0.is_heavy, "Attack 0 is normal attack")
	assert_eq(atk0.windup_ticks, 30, "Attack 0 windup is 30 ticks")
	assert_eq(atk0.active_ticks, 6, "Attack 0 active is 6 ticks")
	assert_eq(atk0.recovery_ticks, 30, "Attack 0 recovery is 30 ticks")
	
	# Đòn 2: Thường (raw 400, coef 1.0)
	var atk1 = data.attack_cycle[1]
	assert_almost_eq(atk1.coef, 1.0, 0.001, "Attack 1 coef must be 1.0")
	assert_false(atk1.is_heavy, "Attack 1 is normal attack")
	
	# Đòn 3: Nặng (raw 1000, coef 2.5)
	var atk2 = data.attack_cycle[2]
	assert_almost_eq(atk2.coef, 2.5, 0.001, "Attack 2 coef must be 2.5")
	assert_true(atk2.is_heavy, "Attack 2 is heavy attack")
	assert_eq(atk2.windup_ticks, 48, "Attack 2 windup is 48 ticks")
	assert_eq(atk2.active_ticks, 6, "Attack 2 active is 6 ticks")
	assert_eq(atk2.recovery_ticks, 45, "Attack 2 recovery is 45 ticks")
	
	# Kiểm tra chuyển chu kỳ đòn
	assert_eq(enemy.current_attack_index, 0, "Starts at attack index 0")
	enemy._start_windup(atk0)
	enemy.advance_physics_ticks(30 + 6 + 30) # windup + active + recovery
	assert_eq(enemy.current_attack_index, 1, "Advances to attack index 1")
	
	enemy._start_windup(atk1)
	enemy.advance_physics_ticks(30 + 6 + 30)
	assert_eq(enemy.current_attack_index, 2, "Advances to attack index 2 (Heavy)")
	
	enemy._start_windup(atk2)
	enemy.advance_physics_ticks(48 + 6 + 45)
	assert_eq(enemy.current_attack_index, 0, "Loops back to attack index 0")
	
	enemy.free()

## Ca kiểm thử vàng B7 (SPEC 6.2):
## 5 lần đỡ hoàn hảo liên tiếp: thể lực 100 -> 80 -> 60 -> 40 -> 20 -> 0
## Lần 5: choáng 120 tick, hết choáng thể lực đặt lại 50, sau đó miễn choáng 60 tick
func test_golden_b7_five_consecutive_parries_and_stamina_break() -> void:
	var enemy = EnemyController.new()
	var data: EnemyData = load("res://data/enemies/enemy_2.tres")
	enemy.enemy_data = data
	enemy._ready()
	
	assert_almost_eq(enemy.stats.current_stamina, 100.0, 0.001, "Initial stamina is 100")
	
	# Lần 1: Thể lực 100 -> 80, choáng 60 tick
	enemy.apply_parry_stun(20.0, 60)
	assert_almost_eq(enemy.stats.current_stamina, 80.0, 0.001, "Parry 1: stamina is 80")
	assert_eq(enemy.current_state, EnemyController.State.STUNNED, "Parry 1: state is STUNNED")
	assert_eq(enemy.stun_timer, 60, "Parry 1: stun is 60 ticks")
	enemy.advance_physics_ticks(60 + 60) # 60 ticks choáng + 60 ticks hết miễn choáng
	assert_eq(enemy.current_state, EnemyController.State.IDLE, "Recovers to IDLE")
	
	# Lần 2: Thể lực 80 -> 60, choáng 60 tick
	enemy.apply_parry_stun(20.0, 60)
	assert_almost_eq(enemy.stats.current_stamina, 60.0, 0.001, "Parry 2: stamina is 60")
	assert_eq(enemy.stun_timer, 60, "Parry 2: stun is 60 ticks")
	enemy.advance_physics_ticks(60 + 60)
	
	# Lần 3: Thể lực 60 -> 40, choáng 60 tick
	enemy.apply_parry_stun(20.0, 60)
	assert_almost_eq(enemy.stats.current_stamina, 40.0, 0.001, "Parry 3: stamina is 40")
	assert_eq(enemy.stun_timer, 60, "Parry 3: stun is 60 ticks")
	enemy.advance_physics_ticks(60 + 60)
	
	# Lần 4: Thể lực 40 -> 20, choáng 60 tick
	enemy.apply_parry_stun(20.0, 60)
	assert_almost_eq(enemy.stats.current_stamina, 20.0, 0.001, "Parry 4: stamina is 20")
	assert_eq(enemy.stun_timer, 60, "Parry 4: stun is 60 ticks")
	enemy.advance_physics_ticks(60 + 60)
	
	# Lần 5: Thể lực 20 -> 0, CẠN THỂ LỰC -> CHOÁNG 120 TICK
	enemy.apply_parry_stun(20.0, 60)
	assert_almost_eq(enemy.stats.current_stamina, 0.0, 0.001, "Parry 5: stamina is 0")
	assert_true(enemy.is_stamina_broken, "Parry 5: stamina broken flag is true")
	assert_eq(enemy.stun_timer, 120, "Parry 5: stamina break causes 120 ticks stun")
	
	# Tiến 120 ticks choáng
	enemy.advance_physics_ticks(120)
	assert_eq(enemy.current_state, EnemyController.State.IDLE, "Stun ends after 120 ticks")
	assert_almost_eq(enemy.stats.current_stamina, 50.0, 0.001, "Stamina resets to 50% (50.0) after stamina break")
	assert_eq(enemy.stun_immunity_timer, 60, "Immune to new stuns for 60 ticks")
	
	# Thử áp dụng choáng trong thời gian miễn nhiễm -> phải bị bỏ qua
	enemy.apply_parry_stun(20.0, 60)
	assert_eq(enemy.current_state, EnemyController.State.IDLE, "Cannot be stunned during stun immunity")
	
	enemy.free()
