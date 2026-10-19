class_name PlayerController
extends CharacterBody2D

enum State {
	IDLE,
	MOVE,
	ATTACK,
	CAST,
	BLOCK
}

enum AttackPhase {
	NONE,
	WINDUP,
	ACTIVE,
	RECOVERY
}

## Tốc độ di chuyển cơ bản (px/s) theo SPEC mục 5.1
@export var move_speed: float = 220.0

## Cấp công pháp mẫu (mặc định 3 theo SPEC 5.1)
@export var technique_level: int = 3
@export var technique_bonus_pct: float = 1.0

## Thời gian đòn cơ bản (ticks)
@export var basic_windup_ticks: int = 6
@export var basic_active_ticks: int = 6
@export var basic_recovery_ticks: int = 12

## Thời gian công pháp (ticks)
@export var cast_windup_ticks: int = 10
@export var cast_active_ticks: int = 8
@export var cast_recovery_ticks: int = 12
@export var cast_cooldown_ticks: int = 120

## Thời gian đỡ đòn (ticks) theo SPEC 3.3
@export var block_active_ticks: int = 24
@export var block_cooldown_ticks: int = 18

var current_state: State = State.IDLE
var facing_direction: Vector2 = Vector2.DOWN

var current_physics_tick: int = 0
var block_press_tick: int = -1
var block_active_timer: int = 0
var block_cooldown_timer: int = 0
var technique_cooldown_timer: int = 0

var attack_phase: AttackPhase = AttackPhase.NONE
var attack_phase_timer: int = 0
var attack_id_counter: int = 0
var current_attack_id: int = 0

@onready var stats: Stats = get_node_or_null("Stats")
@onready var facing_marker: Node2D = get_node_or_null("FacingMarker")
@onready var body_visual: ColorRect = get_node_or_null("BodyVisual")
@onready var shield_visual: Node2D = get_node_or_null("ShieldVisual")
@onready var hitbox_pivot: Node2D = get_node_or_null("HitboxPivot")
@onready var basic_hitbox: Hitbox = get_node_or_null("HitboxPivot/BasicHitbox")
@onready var technique_hitbox: Hitbox = get_node_or_null("HitboxPivot/TechniqueHitbox")

func _ready() -> void:
	if stats == null:
		stats = Stats.new()
		stats.name = "Stats"
		stats.max_hp = 1000
		stats.atk_base = 100.0
		stats.defense = 50.0
		add_child(stats)
	_disable_all_hitboxes()
	if shield_visual != null:
		shield_visual.visible = false

func _physics_process(_delta: float) -> void:
	current_physics_tick += 1
	tick_cooldowns()
	
	match current_state:
		State.IDLE, State.MOVE:
			handle_idle_move_state()
		State.BLOCK:
			handle_block_state()
		State.ATTACK:
			handle_attack_state()
		State.CAST:
			handle_cast_state()
			
	if is_inside_tree():
		move_and_slide()

## Giảm bộ đếm hồi chiêu theo physics ticks
func tick_cooldowns() -> void:
	if block_cooldown_timer > 0:
		block_cooldown_timer -= 1
	if technique_cooldown_timer > 0:
		technique_cooldown_timer -= 1

## Xử lý khi ở trạng thái tự do (IDLE hoặc MOVE)
func handle_idle_move_state() -> void:
	# Kiểm tra Input đỡ đòn
	if Input.is_action_just_pressed("block"):
		if try_block():
			return
			
	# Kiểm tra Input đòn cơ bản
	if Input.is_action_just_pressed("attack_basic"):
		if try_basic_attack():
			return
			
	# Kiểm tra Input công pháp
	if Input.is_action_just_pressed("attack_technique"):
		if try_technique_attack():
			return
			
	# Di chuyển 8 hướng
	var input_vec: Vector2 = get_movement_input()
	update_movement_and_state(input_vec)

## Đọc vector di chuyển từ Input Map
func get_movement_input() -> Vector2:
	var input_vec := Vector2.ZERO
	input_vec.x = Input.get_axis("move_left", "move_right")
	input_vec.y = Input.get_axis("move_up", "move_down")
	
	if input_vec.length_squared() > 0.0:
		input_vec = input_vec.normalized()
	return input_vec

## Cập nhật trạng thái và vận tốc di chuyển
func update_movement_and_state(input_vec: Vector2) -> void:
	if input_vec != Vector2.ZERO:
		current_state = State.MOVE
		velocity = input_vec * move_speed
		facing_direction = input_vec
		_update_facing_nodes()
	else:
		current_state = State.IDLE
		velocity = Vector2.ZERO

func _update_facing_nodes() -> void:
	if facing_marker != null:
		facing_marker.position = facing_direction * 24.0
	if hitbox_pivot != null:
		hitbox_pivot.rotation = facing_direction.angle()

## Kích hoạt đỡ đòn
func try_block() -> bool:
	if current_state != State.IDLE and current_state != State.MOVE:
		return false
	if block_cooldown_timer > 0:
		return false
		
	current_state = State.BLOCK
	velocity = Vector2.ZERO
	block_active_timer = block_active_ticks
	block_press_tick = current_physics_tick
	
	if shield_visual != null:
		shield_visual.visible = true
	if body_visual != null:
		body_visual.color = Color(0.3, 0.8, 1.0, 1.0) # Màu phát sáng phòng thủ
	return true

## Xử lý logic duy trì đỡ đòn
func handle_block_state() -> void:
	velocity = Vector2.ZERO
	block_active_timer -= 1
	if block_active_timer <= 0:
		_end_block()

func _end_block() -> void:
	current_state = State.IDLE
	block_cooldown_timer = block_cooldown_ticks
	if shield_visual != null:
		shield_visual.visible = false
	if body_visual != null:
		body_visual.color = Color(0.2, 0.7, 0.9, 1.0) # Trả về màu gốc

## Kích hoạt đòn cơ bản (Phím J)
func try_basic_attack() -> bool:
	if current_state != State.IDLE and current_state != State.MOVE:
		return false
		
	current_state = State.ATTACK
	velocity = Vector2.ZERO
	attack_phase = AttackPhase.WINDUP
	attack_phase_timer = basic_windup_ticks
	attack_id_counter += 1
	current_attack_id = attack_id_counter
	_disable_all_hitboxes()
	return true

## Xử lý các pha của đòn cơ bản
func handle_attack_state() -> void:
	velocity = Vector2.ZERO
	attack_phase_timer -= 1
	if attack_phase_timer <= 0:
		match attack_phase:
			AttackPhase.WINDUP:
				attack_phase = AttackPhase.ACTIVE
				attack_phase_timer = basic_active_ticks
				_enable_basic_hitbox()
			AttackPhase.ACTIVE:
				attack_phase = AttackPhase.RECOVERY
				attack_phase_timer = basic_recovery_ticks
				_disable_all_hitboxes()
			AttackPhase.RECOVERY:
				attack_phase = AttackPhase.NONE
				current_state = State.IDLE

## Kích hoạt công pháp mẫu cấp 3 (Phím K)
func try_technique_attack() -> bool:
	if current_state != State.IDLE and current_state != State.MOVE:
		return false
	if technique_cooldown_timer > 0:
		return false
		
	current_state = State.CAST
	velocity = Vector2.ZERO
	technique_cooldown_timer = cast_cooldown_ticks
	attack_phase = AttackPhase.WINDUP
	attack_phase_timer = cast_windup_ticks
	attack_id_counter += 1
	current_attack_id = attack_id_counter
	_disable_all_hitboxes()
	return true

## Xử lý các pha của công pháp
func handle_cast_state() -> void:
	velocity = Vector2.ZERO
	attack_phase_timer -= 1
	if attack_phase_timer <= 0:
		match attack_phase:
			AttackPhase.WINDUP:
				attack_phase = AttackPhase.ACTIVE
				attack_phase_timer = cast_active_ticks
				_enable_technique_hitbox()
			AttackPhase.ACTIVE:
				attack_phase = AttackPhase.RECOVERY
				attack_phase_timer = cast_recovery_ticks
				_disable_all_hitboxes()
			AttackPhase.RECOVERY:
				attack_phase = AttackPhase.NONE
				current_state = State.IDLE

func _enable_basic_hitbox() -> void:
	if basic_hitbox != null:
		var raw = stats.atk_base + stats.atk_bonus # coef = 1.0
		var full = int(raw)
		basic_hitbox.init_attack(current_attack_id, raw, full, self)
		basic_hitbox.monitoring = true
		basic_hitbox.visible = true

func _enable_technique_hitbox() -> void:
	if technique_hitbox != null:
		var base = stats.atk_base + stats.atk_bonus
		var raw = base * float(technique_level) * (1.0 + technique_bonus_pct) # 100 * 3 * 2 = 600
		var full = int(raw)
		technique_hitbox.init_attack(current_attack_id, raw, full, self)
		technique_hitbox.monitoring = true
		technique_hitbox.visible = true

func _disable_all_hitboxes() -> void:
	if basic_hitbox != null:
		basic_hitbox.monitoring = false
		basic_hitbox.visible = false
	if technique_hitbox != null:
		technique_hitbox.monitoring = false
		technique_hitbox.visible = false

## Nhận đòn từ bên ngoài (gọi từ Hurtbox hoặc hệ thống chiến đấu)
func receive_hit(raw_dmg: float, full_dmg: int, impact_tick: int, enemy_max_stamina: float = 100.0) -> Dictionary:
	var threshold: float = DamageResolver.compute_block_threshold(
		stats.defense, stats.atk_base, stats.atk_bonus, technique_level
	)
	var is_blocking: bool = (current_state == State.BLOCK)
	var delta: int = (impact_tick - block_press_tick) if is_blocking else -1
	var eval: Dictionary = DamageResolver.evaluate_block(raw_dmg, full_dmg, threshold, delta, is_blocking, enemy_max_stamina)
	
	stats.take_damage(eval.damage_taken)
	if eval.type == DamageResolver.BlockResultType.BLOCK_BROKEN:
		if current_state == State.BLOCK:
			_end_block()
	return eval

## Hàm hỗ trợ mô phỏng physics tick cho unit test
func advance_physics_ticks(num_ticks: int) -> void:
	for _i in range(num_ticks):
		_physics_process(1.0 / 60.0)
