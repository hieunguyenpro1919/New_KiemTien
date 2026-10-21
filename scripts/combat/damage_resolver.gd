class_name DamageResolver
extends RefCounted

## Phân loại kết quả đỡ đòn
enum BlockResultType {
	PERFECT_PARRY,  ## Đỡ hoàn hảo: delta 0..6 tick, raw <= threshold
	EARLY_BLOCK,    ## Đỡ sớm: delta 7..24 tick, raw <= threshold
	NO_BLOCK,       ## Đỡ muộn hoặc không bấm đỡ: delta < 0 hoặc delta > 24 tick
	BLOCK_BROKEN    ## Đỡ bị phá: raw > threshold
}

## Tính hệ số cấp công pháp theo SPEC mục 3.2 bước 2
static func compute_level_coef(level: int, mode: String = "linear") -> float:
	var lvl: float = float(maxi(1, level))
	match mode:
		"linear":
			return lvl
		"sqrt":
			return sqrt(lvl)
		_:
			return lvl

## Tính ngưỡng đỡ đòn theo SPEC mục 3.3
## threshold = (Phòng thủ + Tấn công) × level_coef(cấp công pháp cao nhất đang trang bị)
static func compute_block_threshold(
	defense: float,
	atk_base: float,
	atk_bonus: float = 0.0,
	technique_level: int = 1,
	config: CombatConfig = null
) -> float:
	var mode: String = "linear"
	if config != null:
		mode = config.parry_coef_mode
	var coef: float = compute_level_coef(technique_level, mode)
	return (defense + atk_base + atk_bonus) * coef

## Luồng tính sát thương từ bước 1 đến bước 7 theo SPEC mục 3.2
## Trả về Dictionary gồm: raw, final, base, skill, def_eff, mitigation
static func compute_damage(
	atk_base: float,
	atk_bonus: float = 0.0,
	level_coef: float = 1.0,
	skill_bonus_pct: float = 0.0,
	is_crit: bool = false,
	crit_bonus: float = 0.5,
	defense: float = 0.0,
	armor_pen_pct: float = 0.0,
	armor_pen_flat: float = 0.0,
	damage_cap: int = 99999999
) -> Dictionary:
	# Bước 1: base = atk_base + atk_bonus
	var base: float = atk_base + atk_bonus
	
	# Bước 2 & 3: skill = base × coef × (1 + skill_bonus_pct)
	var skill: float = base * level_coef * (1.0 + skill_bonus_pct)
	
	# Bước 4: Chí mạng
	var raw: float = skill
	if is_crit:
		raw = skill * (1.0 + crit_bonus)
		
	# Bước 5: Giảm trừ phòng thủ
	# def_eff = max(0, defense × (1 − armor_pen_pct) − armor_pen_flat)
	var def_eff: float = maxf(0.0, defense * (1.0 - armor_pen_pct) - armor_pen_flat)
	
	# mitigation = base / (base + def_eff)
	var mitigation: float = 1.0
	if (base + def_eff) > 0.0:
		mitigation = base / (base + def_eff)
	var dmg: float = raw * mitigation
	
	# Bước 6: Làm tròn nửa lên về số nguyên
	# Nếu raw > 0 và base > 0: final = clamp(round(dmg), 1, damage_cap)
	# Nếu raw <= 0 hoặc base <= 0: final = 0 và ghi log lỗi
	var final_dmg: int = 0
	if raw <= 0.0 or base <= 0.0:
		printerr("DamageResolver: Sát thương không hợp lệ: raw = %f, base = %f" % [raw, base])
		final_dmg = 0
	else:
		var rounded_dmg: int = int(round(dmg))
		# Bước 7: Trần sát thương áp ở bước cuối
		final_dmg = clampi(rounded_dmg, 1, damage_cap)
		
	return {
		"raw": raw,
		"final": final_dmg,
		"base": base,
		"skill": skill,
		"def_eff": def_eff,
		"mitigation": mitigation
	}

## Đánh giá kết quả đỡ đòn theo SPEC mục 3.3
static func evaluate_block(
	raw_damage: float,
	full_damage: int,
	threshold: float,
	delta_ticks: int,
	is_blocking: bool = true,
	enemy_max_stamina: float = 100.0,
	config: CombatConfig = null
) -> Dictionary:
	var perfect_window: int = 6
	var block_active: int = 24
	var early_reduction: float = 0.5
	var perfect_reduction: float = 1.0
	var failed_block_pct: float = 1.0
	var parry_stamina_drain: float = 0.20
	var perfect_stun: int = 60
	
	if config != null:
		perfect_window = config.perfect_window_ticks
		block_active = config.block_active_ticks
		early_reduction = config.early_block_reduction
		perfect_reduction = config.perfect_parry_damage_reduction
		failed_block_pct = config.failed_block_damage_pct
		parry_stamina_drain = config.parry_stamina_drain_pct
		perfect_stun = config.perfect_parry_stun_ticks
		
	# Quy tắc 1: Nếu raw > threshold -> Đỡ bị phá
	if raw_damage > threshold:
		return {
			"type": BlockResultType.BLOCK_BROKEN,
			"damage_taken": int(round(float(full_damage) * failed_block_pct)),
			"stamina_damage": 0,
			"stun_ticks": 0,
			"interrupt_enemy": false
		}
		
	# Quy tắc 2: Nếu không có đỡ hoạt động tại điểm trúng (không bấm, bấm sau, hết giờ)
	if not is_blocking or delta_ticks < 0 or delta_ticks > block_active:
		return {
			"type": BlockResultType.NO_BLOCK,
			"damage_taken": int(round(float(full_damage) * failed_block_pct)),
			"stamina_damage": 0,
			"stun_ticks": 0,
			"interrupt_enemy": false
		}
		
	# Quy tắc 3: delta từ 0 đến perfect_window -> Đỡ hoàn hảo
	if delta_ticks >= 0 and delta_ticks <= perfect_window:
		var stamina_drain_val: int = int(round(enemy_max_stamina * parry_stamina_drain))
		var dmg_taken: int = int(round(float(full_damage) * (1.0 - perfect_reduction)))
		return {
			"type": BlockResultType.PERFECT_PARRY,
			"damage_taken": dmg_taken,
			"stamina_damage": stamina_drain_val,
			"stun_ticks": perfect_stun,
			"interrupt_enemy": true
		}
		
	# Quy tắc 4: delta từ (perfect_window + 1) đến block_active -> Đỡ sớm
	if delta_ticks > perfect_window and delta_ticks <= block_active:
		var reduced_dmg: int = int(round(float(full_damage) * early_reduction))
		return {
			"type": BlockResultType.EARLY_BLOCK,
			"damage_taken": reduced_dmg,
			"stamina_damage": 0,
			"stun_ticks": 0,
			"interrupt_enemy": false
		}
		
	# Mặc định nhận đủ
	return {
		"type": BlockResultType.NO_BLOCK,
		"damage_taken": int(round(float(full_damage) * failed_block_pct)),
		"stamina_damage": 0,
		"stun_ticks": 0,
		"interrupt_enemy": false
	}
