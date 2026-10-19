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
