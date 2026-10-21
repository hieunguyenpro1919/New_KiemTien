class_name EnemyController
extends CharacterBody2D

enum State {
	IDLE,
	CHASE,
	WINDUP,
	ACTIVE,
	RECOVERY,
	STUNNED
}

@export var enemy_data: EnemyData
@export var combat_config: CombatConfig

var current_state: State = State.IDLE
var target_player: Node2D = null

var current_attack_index: int = 0
var attack_timer: int = 0
var attack_direction: Vector2 = Vector2.DOWN
var attack_id_counter: int = 0

var stun_timer: int = 0
var stun_immunity_timer: int = 0
var is_stamina_broken: bool = false
var stamina_regen_delay_timer: int = 0

# Tham số mặc định từ SPEC 5.2
var perfect_parry_stun_ticks: int = 60
var stamina_break_stun_ticks: int = 120
var stamina_after_break_pct: float = 0.5
var stun_immunity_ticks: int = 60
var stamina_regen_per_sec: float = 10.0
var stamina_regen_delay_ticks: int = 120

@onready var stats: Stats = get_node_or_null("Stats")
@onready var hurtbox: Hurtbox = get_node_or_null("Hurtbox")
@onready var hitbox_pivot: Node2D = get_node_or_null("HitboxPivot")
@onready var attack_hitbox: Hitbox = get_node_or_null("HitboxPivot/AttackHitbox")
@onready var attack_visual: ColorRect = get_node_or_null("HitboxPivot/AttackHitbox/AttackVisual")
@onready var body_visual: ColorRect = get_node_or_null("BodyVisual")
@onready var title_label: Label = get_node_or_null("UI/TitleLabel")
@onready var hp_bar: ProgressBar = get_node_or_null("UI/HPBar")
@onready var stamina_bar: ProgressBar = get_node_or_null("UI/StaminaBar")

func _ready() -> void:
	add_to_group("enemies")
	if hurtbox == null:
		hurtbox = get_node_or_null("Hurtbox")
	if hitbox_pivot == null:
		hitbox_pivot = get_node_or_null("HitboxPivot")
	if attack_hitbox == null:
		attack_hitbox = get_node_or_null("HitboxPivot/AttackHitbox")
	if attack_visual == null:
		attack_visual = get_node_or_null("HitboxPivot/AttackHitbox/AttackVisual")
	if body_visual == null:
		body_visual = get_node_or_null("BodyVisual")
	if title_label == null:
		title_label = get_node_or_null("UI/TitleLabel")
	if hp_bar == null:
		hp_bar = get_node_or_null("UI/HPBar")
	if stamina_bar == null:
		stamina_bar = get_node_or_null("UI/StaminaBar")
		
	if stats == null:
		stats = get_node_or_null("Stats")
	if stats == null:
		stats = Stats.new()
		stats.name = "Stats"
		add_child(stats)
		
	if combat_config != null:
		perfect_parry_stun_ticks = combat_config.perfect_parry_stun_ticks
		stamina_break_stun_ticks = combat_config.stamina_break_stun_ticks
		stamina_after_break_pct = combat_config.stamina_after_break_pct
		stun_immunity_ticks = combat_config.stun_immunity_ticks
		stamina_regen_per_sec = combat_config.stamina_regen_per_sec
		stamina_regen_delay_ticks = combat_config.stamina_regen_delay_ticks

	_apply_enemy_data()
	_disable_hitbox()
	
	if hurtbox != null:
		hurtbox.hit_received.connect(_on_hurtbox_hit_received)

		
	if target_player == null and is_inside_tree() and get_tree() != null:
		target_player = get_tree().get_first_node_in_group("player")

func _apply_enemy_data() -> void:
	if enemy_data == null:
		return
	if stats != null:
		stats.title = enemy_data.title
		stats.max_hp = enemy_data.max_hp
		stats.current_hp = enemy_data.max_hp
		stats.atk_base = enemy_data.atk_base
		stats.atk_bonus = enemy_data.atk_bonus
		stats.defense = enemy_data.defense
		stats.max_stamina = enemy_data.max_stamina
		stats.current_stamina = enemy_data.max_stamina
		stats.is_hostile = true
		
	if title_label != null:
		title_label.text = enemy_data.title
	_update_ui_bars()

func _physics_process(_delta: float) -> void:
	_tick_stamina_and_immunity()
	
	match current_state:
		State.IDLE:
			handle_idle_state()
		State.CHASE:
			handle_chase_state()
		State.WINDUP:
			handle_windup_state()
		State.ACTIVE:
			handle_active_state()
		State.RECOVERY:
			handle_recovery_state()
		State.STUNNED:
			handle_stunned_state()
			
	if is_inside_tree():
		move_and_slide()
	_update_ui_bars()

func _tick_stamina_and_immunity() -> void:
	if stun_immunity_timer > 0:
		stun_immunity_timer -= 1
		
	if current_state != State.STUNNED and stats != null:
		if stamina_regen_delay_timer > 0:
			stamina_regen_delay_timer -= 1
		elif stats.current_stamina < stats.max_stamina:
			var regen_amount = (stamina_regen_per_sec / 60.0)
			stats.restore_stamina(regen_amount)

func handle_idle_state() -> void:
	velocity = Vector2.ZERO
	if target_player == null and is_inside_tree() and get_tree() != null:
		target_player = get_tree().get_first_node_in_group("player")
	if target_player == null:
		return
		
	var dist = global_position.distance_to(target_player.global_position)
	if dist <= enemy_data.detect_range:
		current_state = State.CHASE
		handle_chase_state()

func handle_chase_state() -> void:
	if target_player == null:
		current_state = State.IDLE
		return
		
	var dist = global_position.distance_to(target_player.global_position)
	if dist > enemy_data.leash_range:
		current_state = State.IDLE
		velocity = Vector2.ZERO
		return
		
	var current_atk: AttackData = _get_current_attack()
	if current_atk == null:
		return
		
	if dist <= current_atk.attack_range:
		_start_windup(current_atk)
	else:
		var dir = (target_player.global_position - global_position).normalized()
		velocity = dir * enemy_data.move_speed
		_update_facing(dir)

func _start_windup(atk: AttackData) -> void:
	current_state = State.WINDUP
	velocity = Vector2.ZERO
	attack_timer = atk.windup_ticks
	
	if target_player != null:
		attack_direction = (target_player.global_position - global_position).normalized()
	_update_facing(attack_direction)
	
	if body_visual != null:
		body_visual.color = Color(0.9, 0.3, 0.2) if not atk.is_heavy else Color(0.95, 0.1, 0.1)

func handle_windup_state() -> void:
	velocity = Vector2.ZERO
	attack_timer -= 1
	if attack_timer <= 0:
		_start_active()

func _start_active() -> void:
	var atk: AttackData = _get_current_attack()
	if atk == null:
		current_state = State.IDLE
		return
		
	current_state = State.ACTIVE
	velocity = Vector2.ZERO
	attack_timer = atk.active_ticks
	
	attack_id_counter += 1
	var atk_b = enemy_data.atk_base
	var atk_bon = enemy_data.atk_bonus
	var l_coef = atk.coef
	var s_pct = 0.0
	var crit = false
	var dmg_calc = DamageResolver.compute_damage(atk_b, atk_bon, l_coef, s_pct, crit, 0.5)
	
	if attack_hitbox != null:
		attack_hitbox.init_attack(
			attack_id_counter,
			dmg_calc.raw,
			dmg_calc.final,
			self,
			atk_b,
			atk_bon,
			l_coef,
			s_pct,
			crit,
			0.5
		)
		attack_hitbox.visible = true
		attack_hitbox.check_overlapping_hurtboxes()
	if attack_visual != null:
		attack_visual.size = atk.hitbox_size
		attack_visual.position = Vector2(0, -atk.hitbox_size.y * 0.5)

func handle_active_state() -> void:
	velocity = Vector2.ZERO
	if attack_hitbox != null and attack_hitbox.is_active:
		attack_hitbox.check_overlapping_hurtboxes()
	attack_timer -= 1
	if attack_timer <= 0:
		_start_recovery()


func _start_recovery() -> void:
	var atk: AttackData = _get_current_attack()
	_disable_hitbox()
	current_state = State.RECOVERY
	velocity = Vector2.ZERO
	attack_timer = atk.recovery_ticks if atk != null else 30
	
	if body_visual != null:
		body_visual.color = Color(0.7, 0.2, 0.2)

func handle_recovery_state() -> void:
	velocity = Vector2.ZERO
	attack_timer -= 1
	if attack_timer <= 0:
		_advance_attack_cycle()
		current_state = State.IDLE

func _advance_attack_cycle() -> void:
	if enemy_data != null and not enemy_data.attack_cycle.is_empty():
		current_attack_index = (current_attack_index + 1) % enemy_data.attack_cycle.size()

func handle_stunned_state() -> void:
	velocity = Vector2.ZERO
	stun_timer -= 1
	if stun_timer <= 0:
		_end_stun()

func _end_stun() -> void:
	if is_stamina_broken:
		if stats != null:
			stats.current_stamina = stats.max_stamina * stamina_after_break_pct
		is_stamina_broken = false
	stun_immunity_timer = stun_immunity_ticks
	current_state = State.IDLE
	if body_visual != null:
		body_visual.color = Color(0.7, 0.2, 0.2)

## Áp dụng choáng khi bị phản đòn hoàn hảo từ người chơi
func apply_parry_stun(stamina_drain: float, stun_ticks: int) -> void:
	if stats == null:
		return
		
	# Trừ thể lực
	stats.consume_stamina(stamina_drain)
	stamina_regen_delay_timer = stamina_regen_delay_ticks
	
	# Hủy đòn đang vung
	_disable_hitbox()
	
	if is_inside_tree() and get_parent() != null:
		FloatingNumber.spawn(get_parent(), global_position + Vector2(0, -28), "-%d Thể Lực" % int(stamina_drain), Color(0.9, 0.8, 0.2))
	
	if stun_immunity_timer > 0:
		return
		
	if stats.current_stamina <= 0.0:
		is_stamina_broken = true
		stun_timer = maxi(stun_timer, stamina_break_stun_ticks)
		if is_inside_tree() and get_parent() != null:
			FloatingNumber.spawn(get_parent(), global_position + Vector2(0, -44), "CẠN THỂ LỰC (Choáng 2s)", Color(1.0, 0.3, 0.3), true)
	else:
		stun_timer = maxi(stun_timer, stun_ticks)
		
	current_state = State.STUNNED
	velocity = Vector2.ZERO
	if body_visual != null:
		body_visual.color = Color(0.4, 0.4, 0.8) # Màu xám xanh choáng

func _on_hurtbox_hit_received(hitbox: Hitbox) -> void:
	if stats == null or stats.is_dead:
		return
		
	# Tính sát thương nhận theo DamageResolver đúng SPEC 3.2
	var res = DamageResolver.compute_damage(
		hitbox.atk_base,
		hitbox.atk_bonus,
		hitbox.level_coef,
		hitbox.skill_bonus_pct,
		hitbox.is_crit,
		hitbox.crit_bonus,
		stats.defense,
		hitbox.armor_pen_pct,
		hitbox.armor_pen_flat
	)
	var actual_dmg = stats.take_damage(res.final)
	if is_inside_tree() and get_parent() != null and actual_dmg > 0:
		var is_crit = hitbox.is_crit or (hitbox.raw_damage > 500.0)
		var col = Color(1.0, 0.85, 0.2) if is_crit else Color.WHITE
		FloatingNumber.spawn(get_parent(), global_position + Vector2(0, -28), "-%d" % actual_dmg, col, is_crit)
		
	if stats.is_dead:
		_die()


func _die() -> void:
	_disable_hitbox()
	current_state = State.IDLE
	velocity = Vector2.ZERO
	visible = false
	set_physics_process(false)

func _get_current_attack() -> AttackData:
	if enemy_data == null or enemy_data.attack_cycle.is_empty():
		return null
	return enemy_data.attack_cycle[current_attack_index]

func _update_facing(dir: Vector2) -> void:
	if dir != Vector2.ZERO and hitbox_pivot != null:
		hitbox_pivot.rotation = dir.angle()

func _disable_hitbox() -> void:
	if attack_hitbox != null:
		attack_hitbox.deactivate()
		attack_hitbox.visible = false

func _update_ui_bars() -> void:
	if stats == null:
		return
	if hp_bar != null:
		hp_bar.max_value = stats.max_hp
		hp_bar.value = stats.current_hp
	if stamina_bar != null:
		stamina_bar.max_value = stats.max_stamina
		stamina_bar.value = stats.current_stamina

## Mô phỏng tick vật lý phục vụ kiểm thử tự động
func advance_physics_ticks(num_ticks: int) -> void:
	for _i in range(num_ticks):
		_physics_process(1.0 / 60.0)
