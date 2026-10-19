class_name EnemyData
extends Resource

## Danh hiệu quái (chỗ giữ chỗ, không hiển thị cấp số)
@export var title: String = "[Danh hiệu thử 1]"

## Máu tối đa
@export var max_hp: int = 300

## Sức tấn công cơ bản
@export var atk_base: float = 40.0

## Sức tấn công cộng thêm
@export var atk_bonus: float = 0.0

## Chỉ số phòng thủ
@export var defense: float = 10.0

## Thể lực tối đa (mặc định 100)
@export var max_stamina: float = 100.0

## Tốc độ di chuyển (px/giây)
@export var move_speed: float = 160.0

## Phạm vi phát hiện người chơi (px)
@export var detect_range: float = 300.0

## Phạm vi bỏ đuổi người chơi (px)
@export var leash_range: float = 600.0

## Danh sách chu kỳ các đòn đánh
@export var attack_cycle: Array[AttackData] = []
