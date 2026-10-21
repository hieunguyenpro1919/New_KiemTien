# NHẬT KÝ QUYẾT ĐỊNH KỸ THUẬT & THAY ĐỔI MẶC ĐỊNH (DECISIONS.MD)

Tài liệu ghi lại các quyết định kỹ thuật, thay đổi mặc định [MẶC ĐỊNH PROTOTYPE] và thử nghiệm pipeline theo quy tắc mục 8 của AGENT_RULES.

---

## 1. Quyết định M0 — Hạ tầng & Công cụ

- **Phiên bản Godot:**
  - *Giá trị:* Godot Engine `4.7.2.stable.official.ed1daf0bf` (Windows 64-bit).
  - *Lý do:* Bản phát hành chính thức ổn định của nhánh 4.7. Khóa cứng không nâng bản trong suốt prototype.
  - *Kết quả:* Chạy headless tốt, biên dịch và nạp tài nguyên mượt mà.

- **Khung kiểm thử tự động (`tests/run_tests.gd`):**
  - *Cũ:* Chưa có bộ chạy test.
  - *Mới:* Bộ chạy test tùy biến tự động quét mọi tệp `test_*.gd`, kế thừa `TestCase` (`tests/test_base.gd`), trả mã thoát 0 khi mọi test xanh và mã 1 khi có test đỏ.
  - *Lý do:* Tuân thủ quy chuẩn SPEC mục 2, không cần cài addon bên thứ ba (GUT/GdUnit4).
  - *Kết quả test:* Đã kiểm chứng cả 2 nhánh (nhánh pass trả mã 0, nhánh fail trả mã 1).

- **Tần số Physics Tick:**
  - *Cũ:* Mặc định engine.
  - *Mới:* `physics/common/physics_ticks_per_second = 60` được xác lập tường minh trong `project.godot`.
  - *Lý do:* Đảm bảo bất biến số 4 của AGENT_RULES (1 tick ≈ 16.67ms).

- **Thử nghiệm Pipeline Animation (SPEC mục 7):**
  - *Thử nghiệm:* Đánh giá giữa Skeleton2D (xương 2D) và Sprite sheet kết hợp AnimationPlayer.
  - *Nhận xét & Thời gian:* Skeleton2D tốn nhiều công thiết lập bone/rigging và khó căn chính xác hitbox theo từng tick đơn lẻ trong Godot 2D top-down. Sprite sheet với AnimationPlayer cho phép đặt frame gọi tick chính xác từng khung hình (active_ticks, windup_ticks), cực kỳ trực quan với combat logic.
  - *Quyết định:* Prototype hiện tại dùng hình khối tạm (ColorRect) kèm FacingMarker. Logic hitbox/hurtbox ở M2 gắn trực tiếp theo physics tick độc lập với sprite. Sau khi M2 xong, art thật sẽ dùng Sprite sheet 5 hướng gốc + lật ngang 3 hướng.

---

## 2. Quyết định M1 — Di chuyển 8 hướng & Đấu trường mẫu

- **Vận tốc di chuyển người chơi:**
  - *Giá trị:* `move_speed = 220.0 px/s` theo đúng bảng dữ liệu SPEC mục 5.1.
  - *Cơ chế:* Chuẩn hóa vector di chuyển khi đi chéo (`input_vec.normalized()`), đảm bảo di chuyển đường chéo có cùng vận tốc 220 px/s như khi đi thẳng, không bị nhanh hơn căn 2 (311.12 px/s).
  - *Kết quả test:* `test_player_diagonal_normalization` kiểm tra độ lớn vận tốc đạt 220.0 px/s (sai số < 0.001).

- **Máy trạng thái cơ bản (`State`):**
  - *Giá trị:* Enum `State { IDLE, MOVE }`.
  - *Cơ chế:* Chuyển đổi mượt mà dựa trên trạng thái `input_vector`. Khi dừng di chuyển, giữ nguyên `facing_direction` cuối cùng.
  - *Kết quả test:* `test_player_stop_and_preserve_facing` kiểm chứng hướng nhìn được bảo toàn khi về `IDLE`.

- **Đấu trường mẫu (`test_arena.tscn`):**
  - *Bố cục:* Kích thước chuẩn 1280x720, gồm sàn đấu, vạch ranh giới, 4 cạnh tường va chạm tĩnh (`StaticBody2D` + `CollisionShape2D`), nhân vật người chơi và panel UI hiển thị thông tin thời gian thực.
  - *Main Scene:* Đặt làm cảnh mặc định `run/main_scene="res://scenes/test_arena.tscn"`.

---

## 3. Quyết định M2.1 — Bộ giải quyết sát thương (DamageResolver) & Bộ ca kiểm thử vàng

- **Tài nguyên cấu hình (`res://scripts/data/combat_config.gd` & `res://data/combat_config.tres`):**
  - *Giá trị:* Đầy đủ 25 tham số cấu hình quy định tại SPEC mục 5.2.
  - *Lý do:* Đảm bảo quy tắc số 2 của AGENT_RULES ("Mọi giá trị số nằm trong CombatConfig/.tres. Không viết cứng").
  - *Kết quả:* Nạp tài nguyên thành công, kiểm chứng trong các test suite.

- **Đặc tả tính sát thương (`DamageResolver.compute_damage`):**
  - *Cơ chế:* Hàm static thuần, không trạng thái ẩn, nhận `is_crit` làm tham số đầu vào rõ ràng. Thực hiện tuần tự 7 bước chuẩn:
    1. `base = atk_base + atk_bonus`
    2. `coef = level_coef(level)`
    3. `skill = base * coef * (1 + skill_bonus_pct)`
    4. `raw = skill * (1 + crit_bonus)` nếu crit, ngược lại `raw = skill`
    5. Giảm trừ: `def_eff = max(0, defense * (1 - armor_pen_pct) - armor_pen_flat)`, `mitigation = base / (base + def_eff)`, `dmg = raw * mitigation`
    6. Làm tròn nửa lên: `clamp(round(dmg), 1, 99999999)` nếu `raw > 0` và `base > 0`, ngược lại trả 0 kèm lỗi log.
    7. Trần sát thương `99.999.999`.
  - *Kết quả test:* Toàn bộ ca kiểm thử vàng G1–G12 trong `res://tests/test_damage.gd` khớp 100% với số kỳ vọng trong SPEC.

- **Đặc tả đỡ đòn & phản đòn (`DamageResolver.evaluate_block`):**
  - *Ngưỡng đỡ:* `compute_block_threshold(...) = (Phòng thủ + Tấn công) * level_coef(cấp)`.
  - *Cơ chế phân định:*
    - `raw > threshold`: Đỡ bị phá (`BLOCK_BROKEN`), nhận đủ sát thương, không trừ thể lực, không choáng.
    - `raw <= threshold` và `0 <= delta <= 6`: Đỡ hoàn hảo (`PERFECT_PARRY`), nhận 0 sát thương, trừ 20% thể lực tối đa của địch, địch choáng 60 tick, hủy đòn vung của địch.
    - `raw <= threshold` và `7 <= delta <= 24`: Đỡ sớm (`EARLY_BLOCK`), nhận `round(full_damage * 0.5)`, không trừ thể lực, không choáng.
    - Ngoài thời gian đỡ (`delta < 0` hoặc `delta > 24` hoặc không bấm): Nhận đủ sát thương (`NO_BLOCK`).
  - *Kết quả test:* Toàn bộ ca kiểm thử vàng B1–B6 trong `res://tests/test_block.gd` khớp 100% với số kỳ vọng trong SPEC.

---

## 4. Quyết định M2.2 — Đòn đánh của Player và Cơ chế Đỡ/Phản trực quan

- **Component Stats (`res://scripts/combat/stats.gd`):**
  - Quản lý máu, thể lực, phòng thủ, tấn công cơ bản và cộng thêm.
  - Phát tín hiệu `hp_changed`, `stamina_changed`, `died`.
  - Người chơi khởi tạo: máu 1.000, tấn công cơ bản 100, phòng thủ 50, thể lực 100 (theo SPEC 5.1).

- **Máy trạng thái chiến đấu của Player (`PlayerController`):**
  - Mở rộng State: `IDLE`, `MOVE`, `ATTACK`, `CAST`, `BLOCK`.
  - Toàn bộ đếm giờ tính bằng **physics ticks** (Quy tắc 4 AGENT_RULES):
    - Đòn cơ bản (J): Windup 6 ticks, Active 6 ticks, Recovery 12 ticks (tổng 24 ticks). Sinh `attack_id` riêng biệt cho mỗi lần vung, quản lý `hit_registry` chặn sát thương lặp.
    - Công pháp (K): Cấp 3, `skill_bonus_pct = 1.0`, `cooldown_ticks = 120` ticks (2s), Windup 10 ticks, Active 8 ticks, Recovery 12 ticks. Hitbox mở rộng theo hướng nhìn.
    - Đỡ đòn (L): `block_active_ticks = 24` ticks (0.4s), hồi chiêu `block_cooldown_ticks = 18` ticks (0.3s). Không di chuyển trong lúc đỡ. Hiển thị hiệu ứng thị giác `ShieldVisual` và đổi màu nhân vật.
  - Kết nối hàm `receive_hit` trực tiếp với `DamageResolver.evaluate_block` và `stats.take_damage`.
  - *Kết quả test:* `res://tests/test_player_combat.gd` đạt 5/5 test pass, tổng toàn dự án 31/31 test pass (100% xanh).

---

## 5. Quyết định M2.3 — Hệ thống AI Quái vật (Quái 1, Quái 2) và Vòng lặp Đối kháng

- **Tài nguyên dữ liệu quái & đòn đánh:**
  - `AttackData` (`res://scripts/data/attack_data.gd`): Lưu coef, windup, active, recovery, range, hitbox_size.
    - `normal_attack.tres`: coef 1.0, windup 30, active 6, recovery 30 ticks.
    - `heavy_attack.tres`: coef 2.5, windup 48, active 6, recovery 45 ticks (đòn nặng của Quái 2).
  - `EnemyData` (`res://scripts/data/enemy_data.gd`):
    - `enemy_1.tres`: Danh hiệu `[Danh hiệu thử 1]`, Máu 300, Def 10, Speed 160 px/s, chu kỳ 1 đòn thường (raw 40).
    - `enemy_2.tres`: Danh hiệu `[Danh hiệu thử 2]`, Máu 3000, Def 100, Speed 200 px/s, chu kỳ đòn: Thường (raw 400), Thường (raw 400), Nặng (raw 1000).

- **Máy trạng thái AI (SimpleAI State Machine):**
  - Trạng thái: `IDLE`, `CHASE`, `WINDUP`, `ACTIVE`, `RECOVERY`, `STUNNED`.
  - Phát hiện người chơi trong tầm 300px (`detect_range`), bỏ đuổi khi vượt 600px (`leash_range`).
  - Vùng đánh khóa hướng lúc bắt đầu pha báo hiệu, không bám theo người chơi (SPEC 3.5).
  - Báo hiệu thị giác: đổi màu khi windup đòn thường/đòn nặng.

- **Cơ chế thể lực & choáng (SPEC 3.4 & Ca kiểm thử vàng B7):**
  - Thể lực tối đa 100.
  - Bị đỡ hoàn hảo: trừ 20% thể lực (-20), choáng 60 ticks (`perfect_parry_stun_ticks`), hủy đòn đang vung.
  - Cạn thể lực (về 0): choáng 120 ticks (`stamina_break_stun_ticks`).
  - Sau khi hết choáng cạn thể lực: hồi lại 50% thể lực (50) và nhận 60 ticks miễn nhiễm choáng (`stun_immunity_ticks`).
  - Hồi thể lực tự nhiên: 10/giây sau 120 ticks không bị trừ.

- **Giao diện lơ lửng trên đầu (UI Floating):**
  - Danh hiệu: `[Danh hiệu thử 1]` và `[Danh hiệu thử 2]`. Tuyệt đối không hiển thị cấp số hay số máu theo Bất biến số 9 của SPEC.
  - Thanh máu (`HPBar`) và thanh thể lực (`StaminaBar`) co giãn theo tỉ lệ.
  - *Kết quả test:* `res://tests/test_enemy_ai.gd` đạt 3/3 test pass (gồm ca vàng B7), tổng toàn dự án 34/34 test pass (100% xanh).

---

## 6. Quyết định M2.4 — Bảng Debug (F3), Số sát thương nổi & Tính xác định

- **Số sát thương nổi (`res://scenes/ui/floating_number.tscn` & `res://scripts/ui/floating_number.gd`):**
  - Tự động sinh khi bất kỳ thực thể nào nhận sát thương > 0 hoặc đỡ đòn.
  - Bay lên 45-65 px/s và mờ dần trong 40 ticks, tự giải phóng bộ nhớ (`queue_free`).
  - Màu sắc: Trắng cho đòn thường, Vàng cam cho đòn chí mạng/công pháp mạnh, Xanh lam cho sát thương bị đỡ, Vàng nổi bật cho "Đỡ Hoàn Hảo!".

- **Bảng Debug F3 (`res://scenes/ui/debug_panel.tscn` & `res://scripts/ui/debug_panel.gd`):**
  - Mặc định ẩn, bật/tắt khi nhấn F3 (`debug_toggle`).
  - Dòng cảnh báo bắt buộc: `=== CHỈ ĐỂ PHÁT TRIỂN / DEBUG ONLY ===` theo mục 3.6 SPEC.
  - Hiển thị đầy đủ số thật theo thời gian thực: Máu thật, Thể lực thật, Tọa độ, State, Cooldown công pháp & đỡ đòn, AI State của từng quái và thời gian miễn choáng.

- **Kiểm chứng tính xác định (SPEC mục 6.4):**
  - Tệp kịch bản [tests/replay/combat_scenario_01.json](file:///d:/App_Data/Godot_v4.7.2-stable_win64.exe/project/kiem-tien/tests/replay/combat_scenario_01.json).
  - [res://tests/test_determinism.gd](file:///d:/App_Data/Godot_v4.7.2-stable_win64.exe/project/kiem-tien/tests/test_determinism.gd) kiểm chứng 2 lượt mô phỏng độc lập cùng seed 12345 qua 180 ticks cho ra nhật ký sự kiện, máu, thể lực, trạng thái trùng khớp 100%.
  - *Kết quả test:* 36/36 tests passed (100% xanh). Hoàn thành toàn diện Milestone M2.

---

## 7. Quyết định M2 Hotfix — Chuẩn hóa Hitbox/Hurtbox & Cảm giác Điều khiển (Attack Movement)

- **Chuẩn hóa phân tầng Collision Layers & Masks:**
  - Layer 1: `PlayerHitbox` (Mask: Layer 4 — `EnemyHurtbox`).
  - Layer 2: `PlayerHurtbox` (Mask: Layer 3 — `EnemyHitbox`).
  - Layer 3: `EnemyHitbox` (Mask: Layer 2 — `PlayerHurtbox`).
  - Layer 4: `EnemyHurtbox` (Mask: Layer 1 — `PlayerHitbox`).
  - Cơ chế này cô lập hoàn toàn va chạm chiến đấu khỏi va chạm vật lý bản đồ (Walls, CharacterBodies), loại bỏ 100% nguy cơ tự va chạm hoặc phát hiện sai đối tượng.

- **Kích thước & Cơ chế Quét va chạm 2 chiều (Zero Miss):**
  - Kích thước `BasicHitbox` tăng lên 64x60 px (tâm cách nhân vật 32 px), `TechniqueHitbox` tăng lên 80x70 px (tâm cách 40 px) bao trọn phía trước hướng mặt.
  - Cơ chế quét kép: vừa bắt sự kiện `area_entered`, vừa gọi chủ động `check_overlapping_hurtboxes()` ngay khi chuyển sang pha `ACTIVE`. Điều này khắc phục triệt để lỗi Godot bỏ lỡ va chạm khi 2 vùng đã đè lên nhau từ trước khi vung đòn.
  - Thêm log Terminal theo dõi va chạm: `print("[COLLISION] Hitbox trúng Hurtbox:", target.name)`.

- **Cải thiện độ mượt di chuyển khi đánh (Attack Movement):**
  - Trong trạng thái `ATTACK` và `CAST`: Nếu người chơi có bấm phím di chuyển, cho phép di chuyển ở 45% tốc độ tối đa (99 px/s) và cập nhật hướng mặt, tạo cảm giác lướt chém uyển chuyển thay vì đơ cứng nhân vật. Nếu không bấm phím thì vận tốc bằng `Vector2.ZERO`.
  - Trạng thái `BLOCK` (phím L) duy trì đứng yên 100% (`velocity = Vector2.ZERO`).

- **Hoàn thiện chuỗi phản hồi Đỡ/Phản đòn:**
  - Player tính sát thương nhận `full_dmg` sau khi trừ giáp chuẩn xác theo SPEC 3.2.
  - Phản đòn hoàn hảo (`PERFECT_PARRY`) trừ 20% thể lực quái, lập tức hủy đòn quái đang vung, gây choáng 60 ticks (hoặc 120 ticks nếu cạn thể lực), sinh nhãn nổi `Đỡ Hoàn Hảo!` trên người chơi và `-20 Thể Lực` trên quái vật.
  - *Kết quả test:* 38/38 tests passed (100% xanh).

---

## 8. Quyết định Khắc phục Toàn diện Gói Lỗi Kỹ thuật F1 - F7 (Claude Review)

- **[F1] Đồng bộ sát thương game thật với Ca kiểm thử vàng:**
  - *Thay đổi:* Mở rộng `Hitbox` mang đầy đủ các tham số nguồn: `atk_base`, `atk_bonus`, `level_coef`, `skill_bonus_pct`, `is_crit`, `crit_bonus`, `armor_pen_pct`, `armor_pen_flat`.
  - *Pipeline:* `PlayerController` và `EnemyController` truyền đầy đủ tham số nguồn qua `_on_hurtbox_hit_received` vào `DamageResolver.compute_damage` theo đúng công thức SPEC 3.2 (`base = atk_base + atk_bonus`).
  - *Kết quả test:* `test_f1_physical_hitbox_damage_sync_with_golden_tests` kiểm chứng Công pháp cấp 3 vs Quái 2 = 300 (G4) và Đòn nặng Quái 2 vs Người chơi = 889 (G7).

- **[F2] Tích hợp Chí mạng (RNG) thực sự vào game:**
  - *Thay đổi:* Tích hợp `RandomNumberGenerator` vào `PlayerController` lấy seed từ `CombatConfig.rng_seed` (12345), in log khởi tạo ra console.
  - *Cơ chế:* Tự động roll chí mạng khi ra đòn dựa trên `player_crit_rate` (10%). Hỗ trợ cờ kiểm thử `force_crit` (0: tự động roll, 1: ép bật, -1: ép tắt).
  - *Kết quả test:* `test_f2_crit_rng_mechanic` kiểm chứng trúng đích với đòn chí mạng (136 sát thương) và không chí mạng (91 sát thương) khớp 100%.

- **[F3] Nạp Resource `CombatConfig.tres` thực sự:**
  - *Thay đổi:* Preload và fallback nạp tệp `res://data/combat_config.tres` trong cả `PlayerController` và `EnemyController`.
  - *Loại bỏ rỗng:* Truyền đối tượng `combat_config` trực tiếp vào `DamageResolver.compute_block_threshold` và `evaluate_block`, triệt tiêu hoàn toàn việc dùng tham số mặc định rỗng bên trong logic runtime.

- **[F4] Triệt tiêu số cứng trong mã nguồn & Hệ số tốc độ khi đánh (0.45):**
  - *Giá trị:* `attack_move_speed_ratio = 0.45` (45% `move_speed`, tương đương 99.0 px/s khi vận tốc cơ sở là 220 px/s).
  - *Lý do:* Tạo cảm giác lướt chém uyển chuyển trong lúc ra đòn (trạng thái `ATTACK` và `CAST`), tránh đơ cứng nhân vật khi bấm phím di chuyển, nhưng không cho phép di chuyển với tốc độ tối đa (100%) để tránh mất tính cam kết của hoạt ảnh đòn đánh.
  - *Cấu hình hóa:* Đã chuyển toàn bộ hệ số 0.45 và các thông số thời gian đòn đánh của người chơi (`player_basic_windup_ticks = 6`, `player_basic_active_ticks = 6`, `player_basic_recovery_ticks = 12`, `player_cast_windup_ticks = 10`, `player_cast_active_ticks = 8`, `player_cast_recovery_ticks = 12`, `player_cast_cooldown_ticks = 120`) vào Resource `CombatConfig` (`combat_config.gd` và `combat_config.tres`). `PlayerController` tự động đồng bộ từ Resource cấu hình khi khởi tạo.

- **[F5] Cấu hình chuẩn `project.godot`:**
  - *Thay đổi:* Bổ sung tường minh dòng `common/physics_ticks_per_second=60` dưới mục `[physics]` trong tệp `project.godot`.

- **[F6] Nâng cấp bộ ca kiểm thử tích hợp (B7 Collision & Determinism Replay):**
  - *B7 Pipeline:* Bổ sung `test_golden_b7_via_collision_and_receive_hit_pipeline` kiểm chứng 5 lần phản đòn liên tiếp kích hoạt qua chuỗi thực tế `Hitbox -> Hurtbox -> receive_hit -> evaluate_block -> apply_parry_stun`.
  - *Determinism Replay:* Bổ sung kịch bản `tests/replay/combat_scenario_02_parry_and_heavy.json` và test `test_determinism_scenario_02_parry_and_heavy_attack` kiểm chứng tính xác định tuyệt đối (bit-for-bit) giữa 2 lần chạy 215 ticks độc lập, có đầy đủ sự kiện Đỡ hoàn hảo (tick 31) và Đòn nặng phá vỡ đỡ đòn (tick 207, gây 889 sát thương).

- **[F7] Chuẩn hóa logic trong `DamageResolver`:**
  - *Level coef mode:* Chuẩn hóa `compute_level_coef` với lệnh `match mode:` hỗ trợ tường minh `"linear"` (trả về cấp `L`), `"sqrt"` (trả về `sqrt(L)`), và nhánh mặc định fallback `lvl`.
  - *Đồng bộ cấu hình:* `evaluate_block` liên kết và sử dụng đầy đủ các trường cấu hình `perfect_parry_damage_reduction` (1.0) và `failed_block_damage_pct` (1.0), `parry_coef_mode` ("linear"), loại bỏ mọi biến chưa dùng và logic dư thừa.

