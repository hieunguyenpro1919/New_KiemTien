extends "res://tests/test_base.gd"

const DamageResolver = preload("res://scripts/combat/damage_resolver.gd")
const CombatConfig = preload("res://scripts/data/combat_config.gd")

## G1: Ví dụ chủ dự án: base 100 + bonus 700, coef 18, skill_bonus_pct 2.0, chí mạng +0.5, def 0
func test_g1_project_owner_example_crit() -> void:
	var res = DamageResolver.compute_damage(
		100.0,   # atk_base
		700.0,   # atk_bonus
		18.0,    # level_coef
		2.0,     # skill_bonus_pct
		true,    # is_crit
		0.5,     # crit_bonus
		0.0      # defense
	)
	assert_almost_eq(res.raw, 64800.0, 0.001, "G1: raw damage should be 64,800")
	assert_eq(res.final, 64800, "G1: final damage should be 64,800")

## G1b: Như G1, không chí mạng
func test_g1b_project_owner_example_no_crit() -> void:
	var res = DamageResolver.compute_damage(
		100.0,   # atk_base
		700.0,   # atk_bonus
		18.0,    # level_coef
		2.0,     # skill_bonus_pct
		false,   # is_crit
		0.5,     # crit_bonus
		0.0      # defense
	)
	assert_almost_eq(res.raw, 43200.0, 0.001, "G1b: raw damage should be 43,200")
	assert_eq(res.final, 43200, "G1b: final damage should be 43,200")

## G2: Đòn cơ bản người chơi vs quái 1 (atk 100, def 10)
func test_g2_player_basic_vs_enemy1() -> void:
	var res = DamageResolver.compute_damage(
		100.0,   # atk_base
		0.0,     # atk_bonus
		1.0,     # level_coef
		0.0,     # skill_bonus_pct
		false,   # is_crit
		0.5,     # crit_bonus
		10.0     # enemy 1 defense
	)
	assert_almost_eq(res.raw, 100.0, 0.001, "G2: raw damage should be 100")
	assert_eq(res.final, 91, "G2: final damage should be 91")

## G3: Công pháp cấp 3 vs quái 1 (atk 100, coef 3, bonus 1.0, def 10)
func test_g3_technique_lvl3_vs_enemy1() -> void:
	var res = DamageResolver.compute_damage(
		100.0,   # atk_base
		0.0,     # atk_bonus
		3.0,     # level_coef
		1.0,     # skill_bonus_pct
		false,   # is_crit
		0.5,     # crit_bonus
		10.0     # enemy 1 defense
	)
	assert_almost_eq(res.raw, 600.0, 0.001, "G3: raw damage should be 600")
	assert_eq(res.final, 545, "G3: final damage should be 545")

## G4: Công pháp cấp 3 vs quái 2 (atk 100, coef 3, bonus 1.0, def 100)
func test_g4_technique_lvl3_vs_enemy2() -> void:
	var res = DamageResolver.compute_damage(
		100.0,   # atk_base
		0.0,     # atk_bonus
		3.0,     # level_coef
		1.0,     # skill_bonus_pct
		false,   # is_crit
		0.5,     # crit_bonus
		100.0    # enemy 2 defense
	)
	assert_almost_eq(res.raw, 600.0, 0.001, "G4: raw damage should be 600")
	assert_eq(res.final, 300, "G4: final damage should be 300")

## G5: Đòn cơ bản vs quái 2 (atk 100, coef 1, def 100)
func test_g5_player_basic_vs_enemy2() -> void:
	var res = DamageResolver.compute_damage(
		100.0,   # atk_base
		0.0,     # atk_bonus
		1.0,     # level_coef
		0.0,     # skill_bonus_pct
		false,   # is_crit
		0.5,     # crit_bonus
		100.0    # enemy 2 defense
	)
	assert_eq(res.final, 50, "G5: final damage should be 50")

## G6: Quái 2 đòn thường vs người chơi (atk 400, coef 1, def 50)
func test_g6_enemy2_normal_vs_player() -> void:
	var res = DamageResolver.compute_damage(
		400.0,   # atk_base
		0.0,     # atk_bonus
		1.0,     # level_coef
		0.0,     # skill_bonus_pct
		false,   # is_crit
		0.5,     # crit_bonus
		50.0     # player defense
	)
	assert_almost_eq(res.raw, 400.0, 0.001, "G6: raw damage should be 400")
	assert_eq(res.final, 356, "G6: final damage should be 356")

## G7: Quái 2 đòn nặng vs người chơi (atk 400, coef 2.5, def 50)
func test_g7_enemy2_heavy_vs_player() -> void:
	var res = DamageResolver.compute_damage(
		400.0,   # atk_base
		0.0,     # atk_bonus
		2.5,     # level_coef
		0.0,     # skill_bonus_pct
		false,   # is_crit
		0.5,     # crit_bonus
		50.0     # player defense
	)
	assert_almost_eq(res.raw, 1000.0, 0.001, "G7: raw damage should be 1000")
	assert_eq(res.final, 889, "G7: final damage should be 889")

## G8: Quái 1 vs người chơi (atk 40, coef 1, def 50)
func test_g8_enemy1_normal_vs_player() -> void:
	var res = DamageResolver.compute_damage(
		40.0,    # atk_base
		0.0,     # atk_bonus
		1.0,     # level_coef
		0.0,     # skill_bonus_pct
		false,   # is_crit
		0.5,     # crit_bonus
		50.0     # player defense
	)
	assert_almost_eq(res.raw, 40.0, 0.001, "G8: raw damage should be 40")
	assert_eq(res.final, 18, "G8: final damage should be 18")

## G9: Công pháp cấp 3 chí mạng vs quái 2 (atk 100, coef 3, bonus 1.0, crit +0.5, def 100)
func test_g9_technique_lvl3_crit_vs_enemy2() -> void:
	var res = DamageResolver.compute_damage(
		100.0,   # atk_base
		0.0,     # atk_bonus
		3.0,     # level_coef
		1.0,     # skill_bonus_pct
		true,    # is_crit
		0.5,     # crit_bonus
		100.0    # enemy 2 defense
	)
	assert_almost_eq(res.raw, 900.0, 0.001, "G9: raw damage should be 900")
	assert_eq(res.final, 450, "G9: final damage should be 450")

## G10: Trần: base 2.000.000, coef 18, bonus 2.0, chí mạng +0.5, def 0
func test_g10_damage_cap() -> void:
	var res = DamageResolver.compute_damage(
		2000000.0, # atk_base
		0.0,       # atk_bonus
		18.0,      # level_coef
		2.0,       # skill_bonus_pct
		true,      # is_crit
		0.5,       # crit_bonus
		0.0        # defense
	)
	assert_almost_eq(res.raw, 162000000.0, 0.001, "G10: raw damage should be 162,000,000")
	assert_eq(res.final, 99999999, "G10: final damage should be capped at 99,999,999")

## G11: atk_base = 0 hoặc giá trị âm
func test_g11_invalid_attack_values() -> void:
	var res_zero = DamageResolver.compute_damage(0.0, 0.0, 1.0, 0.0, false, 0.5, 50.0)
	assert_eq(res_zero.final, 0, "G11: atk_base = 0 must result in final 0")
	
	var res_neg = DamageResolver.compute_damage(-50.0, 0.0, 1.0, 0.0, false, 0.5, 50.0)
	assert_eq(res_neg.final, 0, "G11: negative attack must result in final 0")

## G12: Xuyên giáp 50%, công pháp cấp 3 vs quái 2
func test_g12_armor_penetration_50_pct() -> void:
	var res = DamageResolver.compute_damage(
		100.0,   # atk_base
		0.0,     # atk_bonus
		3.0,     # level_coef
		1.0,     # skill_bonus_pct
		false,   # is_crit
		0.5,     # crit_bonus
		100.0,   # enemy 2 defense
		0.5,     # armor_pen_pct = 50%
		0.0      # armor_pen_flat = 0
	)
	assert_eq(res.final, 400, "G12: 50% armor pen should result in final 400")
