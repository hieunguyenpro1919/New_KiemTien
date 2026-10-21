extends "res://tests/test_base.gd"

const DamageResolver = preload("res://scripts/combat/damage_resolver.gd")
const CombatConfig = preload("res://scripts/data/combat_config.gd")

func test_block_threshold_calculation() -> void:
	# Người chơi: phòng thủ 50, tấn công 100, công pháp cấp 3
	var threshold = DamageResolver.compute_block_threshold(50.0, 100.0, 0.0, 3)
	assert_almost_eq(threshold, 450.0, 0.001, "Threshold with technique lvl 3 should be 450")

## B1: Quái 2 đòn thường (raw 400), delta = 3 -> Đỡ hoàn hảo: nhận 0, quái mất 20 thể lực, choáng 60 tick
func test_b1_perfect_parry() -> void:
	var threshold = 450.0
	var res = DamageResolver.evaluate_block(
		400.0, # raw
		356,   # full_damage
		threshold,
		3,     # delta = 3
		true,  # is_blocking
		100.0  # enemy_max_stamina
	)
	assert_eq(res.type, DamageResolver.BlockResultType.PERFECT_PARRY, "B1: Should be PERFECT_PARRY")
	assert_eq(res.damage_taken, 0, "B1: Sát thương nhận phải bằng 0")
	assert_eq(res.stamina_damage, 20, "B1: Địch mất 20 thể lực")
	assert_eq(res.stun_ticks, 60, "B1: Choáng 60 tick")
	assert_true(res.interrupt_enemy, "B1: Hủy đòn vung của địch")

## B2: Như B1, delta = 12 -> Đỡ sớm: nhận 178, không trừ thể lực
func test_b2_early_block() -> void:
	var threshold = 450.0
	var res = DamageResolver.evaluate_block(
		400.0, # raw
		356,   # full_damage
		threshold,
		12,    # delta = 12
		true,  # is_blocking
		100.0
	)
	assert_eq(res.type, DamageResolver.BlockResultType.EARLY_BLOCK, "B2: Should be EARLY_BLOCK")
	assert_eq(res.damage_taken, 178, "B2: Sát thương nhận phải là 178")
	assert_eq(res.stamina_damage, 0, "B2: Không trừ thể lực")
	assert_eq(res.stun_ticks, 0, "B2: Không choáng")
	assert_false(res.interrupt_enemy, "B2: Không ngắt đòn địch")

## B3: Như B1, không bấm đỡ -> Nhận 356
func test_b3_no_block() -> void:
	var threshold = 450.0
	var res = DamageResolver.evaluate_block(
		400.0,
		356,
		threshold,
		-1,    # Không bấm hoặc ngoài thời gian
		false, # is_blocking = false
		100.0
	)
	assert_eq(res.type, DamageResolver.BlockResultType.NO_BLOCK, "B3: Should be NO_BLOCK")
	assert_eq(res.damage_taken, 356, "B3: Nhận đủ sát thương 356")
	assert_eq(res.stamina_damage, 0, "B3: Không trừ thể lực")
	assert_eq(res.stun_ticks, 0, "B3: Không choáng")

## B4: Quái 2 đòn nặng (raw 1000), delta = 3 -> Đỡ bị phá: nhận 889, không trừ thể lực, không choáng
func test_b4_block_broken() -> void:
	var threshold = 450.0
	var res = DamageResolver.evaluate_block(
		1000.0, # raw vượt quá threshold 450
		889,    # full_damage của đòn nặng
		threshold,
		3,      # delta = 3
		true,
		100.0
	)
	assert_eq(res.type, DamageResolver.BlockResultType.BLOCK_BROKEN, "B4: Should be BLOCK_BROKEN")
	assert_eq(res.damage_taken, 889, "B4: Nhận đủ sát thương 889 khi bị phá đỡ")
	assert_eq(res.stamina_damage, 0, "B4: Không trừ thể lực")
	assert_eq(res.stun_ticks, 0, "B4: Không choáng")
	assert_false(res.interrupt_enemy, "B4: Không ngắt đòn")

## B5: Biên: delta 0 và 6 hoàn hảo. delta 7 và 24 đỡ sớm. delta 25 nhận đủ
func test_b5_delta_boundaries() -> void:
	var threshold = 450.0
	var raw = 400.0
	var full = 356
	
	# delta = 0 -> Hoàn hảo
	var r0 = DamageResolver.evaluate_block(raw, full, threshold, 0, true)
	assert_eq(r0.type, DamageResolver.BlockResultType.PERFECT_PARRY, "B5: delta 0 phải là PERFECT_PARRY")
	assert_eq(r0.damage_taken, 0, "B5: delta 0 nhận 0")
	
	# delta = 6 -> Hoàn hảo
	var r6 = DamageResolver.evaluate_block(raw, full, threshold, 6, true)
	assert_eq(r6.type, DamageResolver.BlockResultType.PERFECT_PARRY, "B5: delta 6 phải là PERFECT_PARRY")
	assert_eq(r6.damage_taken, 0, "B5: delta 6 nhận 0")
	
	# delta = 7 -> Đỡ sớm
	var r7 = DamageResolver.evaluate_block(raw, full, threshold, 7, true)
	assert_eq(r7.type, DamageResolver.BlockResultType.EARLY_BLOCK, "B5: delta 7 phải là EARLY_BLOCK")
	assert_eq(r7.damage_taken, 178, "B5: delta 7 nhận 178")
	
	# delta = 24 -> Đỡ sớm
	var r24 = DamageResolver.evaluate_block(raw, full, threshold, 24, true)
	assert_eq(r24.type, DamageResolver.BlockResultType.EARLY_BLOCK, "B5: delta 24 phải là EARLY_BLOCK")
	assert_eq(r24.damage_taken, 178, "B5: delta 24 nhận 178")
	
	# delta = 25 -> Nhận đủ (hết hiệu lực đỡ)
	var r25 = DamageResolver.evaluate_block(raw, full, threshold, 25, true)
	assert_eq(r25.type, DamageResolver.BlockResultType.NO_BLOCK, "B5: delta 25 phải là NO_BLOCK")
	assert_eq(r25.damage_taken, 356, "B5: delta 25 nhận đủ 356")

## B6: Biên ngưỡng: raw = 450 (đỡ giữ được). raw = 451 (bị phá)
func test_b6_threshold_boundaries() -> void:
	var threshold = 450.0
	var full = 356
	
	# raw = 450 -> Đỡ giữ được (đúng bằng ngưỡng)
	var r450 = DamageResolver.evaluate_block(450.0, full, threshold, 3, true)
	assert_eq(r450.type, DamageResolver.BlockResultType.PERFECT_PARRY, "B6: raw = 450 phải đỡ giữ được")
	assert_eq(r450.damage_taken, 0, "B6: raw = 450 nhận 0 khi đỡ hoàn hảo")
	
	# raw = 451 -> Đỡ bị phá (vượt ngưỡng)
	var r451 = DamageResolver.evaluate_block(451.0, full, threshold, 3, true)
	assert_eq(r451.type, DamageResolver.BlockResultType.BLOCK_BROKEN, "B6: raw = 451 phải bị phá đỡ")
	assert_eq(r451.damage_taken, 356, "B6: raw = 451 nhận đủ sát thương")

func test_f7_level_coef_mode_and_config_wiring() -> void:
	# 1. Kiểm tra 2 nhánh compute_level_coef
	assert_eq(DamageResolver.compute_level_coef(4, "linear"), 4.0, "Linear level coef for level 4 must be 4.0")
	assert_eq(DamageResolver.compute_level_coef(4, "sqrt"), 2.0, "Sqrt level coef for level 4 must be 2.0")
	assert_eq(DamageResolver.compute_level_coef(4, "unknown_fallback"), 4.0, "Fallback level coef must default to linear")
	
	# 2. Kiểm tra parry_coef_mode trong compute_block_threshold
	var cfg = CombatConfig.new()
	cfg.parry_coef_mode = "sqrt"
	var th_sqrt = DamageResolver.compute_block_threshold(50.0, 100.0, 0.0, 4, cfg)
	assert_eq(th_sqrt, 300.0, "Threshold with sqrt parry_coef_mode must be (50+100)*2 = 300.0")
	
	# 3. Kiểm tra biến cấu hình evaluate_block
	cfg.failed_block_damage_pct = 0.75
	var r_broken = DamageResolver.evaluate_block(500.0, 100, 400.0, 3, true, 100.0, cfg)
	assert_eq(r_broken.damage_taken, 75, "Broken block must scale by failed_block_damage_pct (75)")
	
	cfg.perfect_parry_damage_reduction = 0.90
	var r_parry = DamageResolver.evaluate_block(300.0, 100, 400.0, 3, true, 100.0, cfg)
	assert_eq(r_parry.damage_taken, 10, "Perfect parry must scale by perfect_parry_damage_reduction (10)")
