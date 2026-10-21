class_name CombatConfig
extends Resource

## Tần số tick logic chiến đấu (60 Hz)
@export var tick_rate: int = 60

## Chế độ tính hệ số cấp công pháp (mặc định tuyến tính: L)
@export var level_coef_mode: String = "linear"

## Chế độ tính hệ số cấp đỡ (mặc định cùng level_coef)
@export var parry_coef_mode: String = "linear"

## Cửa sổ đỡ hoàn hảo (delta 0 đến 6 tick, tương đương 7 tick)
@export var perfect_window_ticks: int = 6

## Thời gian duy trì trạng thái đỡ (tick)
@export var block_active_ticks: int = 24

## Thời gian hồi chiêu đỡ (tick)
@export var block_cooldown_ticks: int = 18

## Hệ số sát thương nhận khi đỡ sớm (50%)
@export var early_block_reduction: float = 0.5

## Hệ số giảm sát thương khi đỡ hoàn hảo (100% -> nhận 0)
@export var perfect_parry_damage_reduction: float = 1.0

## Hệ số sát thương khi đỡ thất bại hoặc bị phá
@export var failed_block_damage_pct: float = 1.0

## Tỉ lệ thể lực tối đa của địch bị trừ khi bị phản đòn hoàn hảo (20%)
@export var parry_stamina_drain_pct: float = 0.20

## Thời gian choáng của địch khi bị phản đòn hoàn hảo (tick)
@export var perfect_parry_stun_ticks: int = 60

## Thời gian choáng khi cạn thể lực (tick)
@export var stamina_break_stun_ticks: int = 120

## Thể lực hồi lại sau khi hết choáng cạn thể lực (50%)
@export var stamina_after_break_pct: float = 0.5

## Thời gian miễn nhiễm choáng sau khi hết choáng (tick)
@export var stun_immunity_ticks: int = 60

## Tốc độ hồi thể lực mỗi giây
@export var stamina_regen_per_sec: float = 10.0

## Độ trễ trước khi bắt đầu hồi thể lực sau khi bị trừ (tick)
@export var stamina_regen_delay_ticks: int = 120

## Tỉ lệ chí mạng cơ bản của người chơi
@export var player_crit_rate: float = 0.10

## Thưởng sát thương chí mạng của người chơi (+50%)
@export var player_crit_bonus: float = 0.5

## Trần sát thương tối đa
@export var damage_cap: int = 99999999

## Hạt giống ngẫu nhiên (RNG Seed)
@export var rng_seed: int = 12345

## Ngộ Đạo: điểm nhận khi dùng công pháp trúng đích
@export var combat_gain: int = 1

## Ngộ Đạo: điểm nhận mỗi giây khi tu luyện
@export var cultivate_gain_per_sec: int = 1

## Ngộ Đạo: khoảng cách giữa các xung tâm niệm (giây)
@export var pulse_interval_s: float = 15.0

## Ngộ Đạo: cửa sổ phản hồi xung tâm niệm (giây)
@export var pulse_window_s: float = 3.0

## Ngộ Đạo: trần điểm mỗi phiên tu luyện
@export var session_cap: int = 300

## Ngộ Đạo: cơ số tính chi phí nâng cấp
@export var cost_base: float = 30.0

## Ngộ Đạo: tỉ lệ tăng trưởng chi phí nâng cấp
@export var cost_growth: float = 1.35

## Tỉ lệ vận tốc di chuyển khi người chơi ra đòn (trạng thái ATTACK / CAST)
@export var attack_move_speed_ratio: float = 0.45

## Thời gian đòn cơ bản của người chơi (ticks)
@export var player_basic_windup_ticks: int = 6
@export var player_basic_active_ticks: int = 6
@export var player_basic_recovery_ticks: int = 12

## Thời gian công pháp của người chơi (ticks)
@export var player_cast_windup_ticks: int = 10
@export var player_cast_active_ticks: int = 8
@export var player_cast_recovery_ticks: int = 12
@export var player_cast_cooldown_ticks: int = 120
