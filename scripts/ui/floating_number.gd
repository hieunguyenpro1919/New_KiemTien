class_name FloatingNumber
extends Node2D

@onready var label: Label = get_node_or_null("Label")

var velocity: Vector2 = Vector2(0, -45.0)
var lifetime_ticks: int = 40
var current_ticks: int = 0
var text_content: String = ""
var text_color: Color = Color.WHITE
var is_critical: bool = false

func setup(p_text: String, p_color: Color = Color.WHITE, p_crit: bool = false) -> void:
	text_content = p_text
	text_color = p_color
	is_critical = p_crit
	if is_critical:
		velocity = Vector2(0, -65.0)
	_apply_visuals()

func _ready() -> void:
	_apply_visuals()

func _apply_visuals() -> void:
	if label != null and text_content != "":
		label.text = text_content
		label.modulate = text_color
		if is_critical:
			label.add_theme_font_size_override("font_size", 16)
		else:
			label.add_theme_font_size_override("font_size", 13)

func _physics_process(_delta: float) -> void:
	current_ticks += 1
	position += velocity * (1.0 / 60.0)
	var progress: float = float(current_ticks) / float(lifetime_ticks)
	modulate.a = maxf(0.0, 1.0 - progress)
	if current_ticks >= lifetime_ticks:
		queue_free()

## Hàm tiện ích sinh số nổi tĩnh
static func spawn(parent: Node, spawn_pos: Vector2, text: String, color: Color = Color.WHITE, is_crit: bool = false) -> FloatingNumber:
	if parent == null:
		return null
	var scene = load("res://scenes/ui/floating_number.tscn")
	if scene == null:
		return null
	var instance: FloatingNumber = scene.instantiate()
	instance.position = spawn_pos
	instance.setup(text, color, is_crit)
	parent.add_child(instance)
	return instance
