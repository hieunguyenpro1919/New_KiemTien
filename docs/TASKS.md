# THEO DÕI TIẾN ĐỘ & NHIỆM VỤ (TASKS.MD)

Tài liệu theo dõi trạng thái thực thi của từng Milestone theo quy tắc AGENT_RULES.

---

## Trạng thái tổng thể

- [x] **Milestone M0 — Thiết lập hạ tầng** (Hoàn thành)
- [x] **Milestone M1 — Di chuyển 8 hướng & Đấu trường mẫu** (Hoàn thành)
- [x] **Milestone M2 — Combat vertical slice** (Hoàn thành)
  - [x] **M2.1: Bộ giải quyết sát thương (DamageResolver) & Bộ ca kiểm thử vàng** (Hoàn thành)
  - [x] **M2.2: Hệ thống Đòn đánh của Player và Cơ chế Đỡ/Phản trực quan** (Hoàn thành)
  - [x] **M2.3: Hệ thống AI Quái vật (Quái 1, Quái 2) và Vòng lặp Đối kháng hoàn chỉnh** (Hoàn thành)
  - [x] **M2.4: Bảng debug F3, Số sát thương nổi & Kịch bản kiểm chứng tính xác định** (Hoàn thành)
- [ ] **Milestone M2b — Ngộ Đạo tối thiểu** (Chưa bắt đầu)
- [ ] **Milestone M3 trở đi** (Để sau khi M2 qua cổng chơi thử)

---

## Chi tiết thực thi

### M0 — Thiết lập hạ tầng:
- [x] Ghi nhận phiên bản Godot 4.7.2-stable vào `docs/PROJECT_VERSION.md`.
- [x] Tạo đầy đủ cấu trúc thư mục dự án theo SPEC mục 7:
  - `res://data/` (`techniques/`, `enemies/`, `attacks/`)
  - `res://scripts/` (`core/`, `data/`, `actors/`, `combat/`, `progression/`, `ui/`)
  - `res://scenes/` (`ui/`)
  - `res://tests/` (`replay/`)
- [x] Cấu hình `project.godot`:
  - `physics/common/physics_ticks_per_second = 60`.
  - Input Map đầy đủ: `move_up`, `move_down`, `move_left`, `move_right`, `attack_basic`, `attack_technique`, `block`, `cultivate`, `interact`, `debug_toggle`, `reset_scene`, `debug_spend`.
- [x] Khung test runner tự động `res://tests/run_tests.gd`:
  - Chạy bằng lệnh: `godot --headless --script res://tests/run_tests.gd`.
  - Trả mã thoát 0 khi mọi test pass, trả mã 1 khi có test fail.
  - Tích hợp lớp cơ sở `tests/test_base.gd` và bộ test mẫu `tests/test_sample.gd`.
- [x] Cấu hình `.gitignore` chuẩn cho Godot 4.
- [x] Khởi tạo Git repository và liên kết remote `origin https://github.com/hieunguyenpro1919/New_KiemTien.git`.

### M1 — Di chuyển 8 hướng & Đấu trường mẫu:
- [x] Tạo Scene `res://scenes/test_arena.tscn` với sàn đấu, 4 tường va chạm tĩnh (`StaticBody2D` + `CollisionShape2D`), nhân vật và UI hiển thị trạng thái.
- [x] Tạo Scene `res://scenes/player.tscn` dùng `CharacterBody2D`, hình khối tạm `ColorRect` và `FacingMarker`.
- [x] Viết `res://scripts/actors/player_controller.gd`:
  - Di chuyển 8 hướng qua Input Map.
  - Chuẩn hóa vector di chuyển đường chéo (`normalized()`), tốc độ cố định 220 px/s theo SPEC 5.1.
  - Cập nhật hướng nhìn `facing_direction` và hiển thị marker.
  - Máy trạng thái `State { IDLE, MOVE }`.
- [x] Đặt `res://scenes/test_arena.tscn` làm Main Scene mặc định trong `project.godot`.
- [x] Bộ kiểm thử tự động `res://tests/test_player_controller.gd` gồm 4 ca kiểm thử chuyên sâu về vận tốc, chuẩn hóa đường chéo, chuyển trạng thái và bảo toàn hướng nhìn.
- [x] Đăng ký global class cache cho engine và kiểm tra chạy scene không lỗi (`godot --headless --quit-after 30`).

### M2.1 — Bộ giải quyết sát thương (DamageResolver) & Bộ ca kiểm thử vàng:
- [x] Tạo Resource `res://scripts/data/combat_config.gd` và file dữ liệu `res://data/combat_config.tres` chứa 25 tham số cấu hình chuẩn theo SPEC 5.2.
- [x] Tạo `res://scripts/combat/damage_resolver.gd`:
  - Toàn bộ hàm static thuần, không phụ thuộc Scene/Node, không ẩn RNG.
  - `compute_damage(...)`: Luồng 7 bước chuẩn từ SPEC 3.2, làm tròn nửa lên, trần 99.999.999, giáp & xuyên giáp.
  - `compute_block_threshold(...)`: Theo SPEC 3.3.
  - `evaluate_block(...)`: Phân định đỡ hoàn hảo (delta 0..6), đỡ sớm (delta 7..24), đỡ bị phá (raw > threshold), và không đỡ/đỡ muộn.
- [x] Viết `res://tests/test_damage.gd`: Đầy đủ toàn bộ ca kiểm thử vàng G1–G12 từ SPEC 6.1, khớp 100% số kỳ vọng.
- [x] Viết `res://tests/test_block.gd`: Đầy đủ toàn bộ ca kiểm thử vàng B1–B6 từ SPEC 6.2, khớp 100% số kỳ vọng.
- [x] Chạy kiểm thử tự động với `res://tests/run_tests.gd`: Đạt 26/26 tests passed (100% xanh).

### M2.2 — Hệ thống Đòn đánh của Player và Cơ chế Đỡ/Phản trực quan:
- [x] Tạo component `res://scripts/combat/stats.gd` (`Stats`) quản lý HP, stamina, atk_base, atk_bonus, defense, signal `hp_changed`, `stamina_changed`, `died`.
- [x] Tạo component `res://scripts/combat/hitbox.gd` (`Hitbox`) với cơ chế `attack_id` và `hit_registry` chặn sát thương lặp.
- [x] Tạo component `res://scripts/combat/hurtbox.gd` (`Hurtbox`) tiếp nhận va chạm từ Hitbox.
- [x] Cập nhật `PlayerController`:
  - Tích hợp `Stats` (máu 1000, atk 100, def 50 theo SPEC 5.1).
  - Mở rộng State Machine: `IDLE`, `MOVE`, `ATTACK`, `CAST`, `BLOCK`.
  - Đòn cơ bản (J): Coef 1.0, 3 pha (windup 6, active 6, recovery 12 ticks), sinh `attack_id` riêng.
  - Công pháp (K): Cấp 3, `skill_bonus_pct = 1.0`, hồi 120 ticks, mở rộng hitbox về phía trước.
  - Đỡ đòn (L): Đỡ 24 ticks, hồi 18 ticks, ghi lại `press_tick`, hiển thị `ShieldVisual`.
  - Tích hợp hàm `receive_hit` kết nối trực tiếp với `DamageResolver.evaluate_block`.
- [x] Cập nhật scene `res://scenes/player.tscn` và HUD trong `res://scenes/test_arena.tscn`.
- [x] Viết test suite `res://tests/test_player_combat.gd` kiểm tra toàn bộ luồng đòn đánh, hồi chiêu, đỡ đòn và tính toán sát thương.
- [x] Kiểm thử tự động đạt 31/31 tests passed (100% xanh).

### M2.3 — Hệ thống AI Quái vật (Quái 1, Quái 2) và Vòng lặp Đối kháng hoàn chỉnh:
- [x] Tạo resource `res://scripts/data/attack_data.gd` và `res://scripts/data/enemy_data.gd`.
- [x] Tạo các file `.tres`:
  - `data/attacks/normal_attack.tres` (coef 1.0, windup 30, active 6, recovery 30 ticks).
  - `data/attacks/heavy_attack.tres` (coef 2.5, windup 48, active 6, recovery 45 ticks).
  - `data/enemies/enemy_1.tres`: Danh hiệu `[Danh hiệu thử 1]`, Máu 300, Def 10, Speed 160 px/s.
  - `data/enemies/enemy_2.tres`: Danh hiệu `[Danh hiệu thử 2]`, Máu 3000, Def 100, Speed 200 px/s, chu kỳ: thường, thường, nặng.
- [x] Xây dựng `res://scripts/actors/enemy_controller.gd` và `res://scenes/enemy.tscn`:
  - SimpleAI State Machine: `IDLE`, `CHASE` (tầm 300px), `WINDUP`, `ACTIVE`, `RECOVERY`, `STUNNED`.
  - Vùng đánh khóa hướng ở windup, không bám theo player.
  - Cơ chế thể lực & choáng: trừ 20% khi player đỡ hoàn hảo, choáng 60 ticks. Cạn thể lực choáng 120 ticks, hồi 50% và miễn choáng 60 ticks.
  - UI lơ lửng: Danh hiệu (không hiện cấp/số máu), thanh ProgressBar máu và thể lực.
- [x] Cập nhật `res://scenes/test_arena.tscn`: đặt Quái 1 và Quái 2 ở hai góc đối diện, phím R reload lại toàn bộ scene.
- [x] Viết test suite `res://tests/test_enemy_ai.gd`:
  - Kiểm tra phát hiện (300px) và bỏ đuổi (600px).
  - Kiểm tra chu kỳ đòn của Quái 2 (thường, thường, nặng).
  - Kiểm tra ca kiểm thử vàng B7 (5 lần đỡ hoàn hảo liên tiếp cạn thể lực, choáng 120 tick, hồi 50% thể lực và miễn choáng 60 tick).
- [x] Toàn bộ test runner đạt 34/34 tests passed (100% xanh).

### M2.4 — Bảng Debug (F3), Số sát thương nổi & Kịch bản kiểm chứng tính xác định:
- [x] Hệ thống Số sát thương nổi (Floating Combat Text):
  - Tạo `res://scripts/ui/floating_number.gd` và `res://scenes/ui/floating_number.tscn`.
  - Hiệu ứng bay lên 45-65 px/s, mờ dần sau 40 ticks và tự dọn bộ nhớ.
  - Tích hợp vào `PlayerController.gd` và `EnemyController.gd`:
    - Màu trắng cho đòn đánh thường.
    - Màu vàng cam cho đòn chí mạng / đòn nặng / công pháp.
    - Màu xanh lam / xám khi đỡ đòn thành công.
    - Dòng chữ vàng "Đỡ Hoàn Hảo!" khi parry thành công.
- [x] Bảng Debug F3 (`res://scenes/ui/debug_panel.tscn` & `res://scripts/ui/debug_panel.gd`):
  - Mặc định ẩn, bật/tắt bằng phím F3 (`debug_toggle`).
  - Dòng cảnh báo bắt buộc theo SPEC 3.6: `=== CHỈ ĐỂ PHÁT TRIỂN / DEBUG ONLY ===`.
  - Hiển thị theo thời gian thực:
    - Player: Máu thật / Max, Thể lực thật, Trạng thái (State), Tick hồi chiêu công pháp và đỡ đòn, Vị trí.
    - Quái vật: Tọa độ, Thể lực thật, Máu thật, Trạng thái AI (IDLE, CHASE, WINDUP, ACTIVE, RECOVERY, STUNNED), số lần miễn choáng còn lại.
  - Tích hợp trực tiếp vào CanvasLayer UI của `res://scenes/test_arena.tscn`.
- [x] Kịch bản kiểm chứng tính xác định (SPEC 6.4):
  - Tạo kịch bản sự kiện `res://tests/replay/combat_scenario_01.json` gồm 180 ticks mô phỏng đối kháng hoàn chỉnh.
  - Viết `res://tests/test_determinism.gd`:
    - Chạy 2 lượt mô phỏng độc lập với cùng 1 chuỗi hành động và RNG seed (12345).
    - So sánh và kiểm chứng rằng cả 2 lượt chạy cho ra nhật ký sự kiện, máu, thể lực, trạng thái trùng khớp 100% từng con số.
    - Kiểm chứng tính xác định của luồng tung xúc xắc sát thương RNG.
- [x] Toàn bộ 36/36 tests trong test runner đạt 100% xanh.
- [x] Hoàn thành toàn diện Milestone M2 (Combat Vertical Slice).

### M2 Hotfix — Chuẩn hóa Hitbox/Hurtbox & Cơ chế Di chuyển khi Đánh (Attack Movement):
- [x] Chuẩn hóa toàn bộ Collision Layer & Mask:
  - Layer 1: PlayerHitbox (Mask: 8 - Layer 4 EnemyHurtbox).
  - Layer 2: PlayerHurtbox (Mask: 4 - Layer 3 EnemyHitbox).
  - Layer 3: EnemyHitbox (Mask: 2 - Layer 2 PlayerHurtbox).
  - Layer 4: EnemyHurtbox (Mask: 1 - Layer 1 PlayerHitbox).
  - Kích hoạt `monitoring = true` và `monitorable = true` trên toàn bộ Area2D.
- [x] Tăng kích thước vùng đánh Hitbox:
  - `BasicHitbox`: 64x60 px (tâm cách 32 px phía trước mặt).
  - `TechniqueHitbox`: 80x70 px (tâm cách 40 px phía trước mặt).
  - Khắc phục lỗi trượt đòn khi đứng sát: kết hợp `area_entered` và hàm chủ động `check_overlapping_hurtboxes()`.
  - Log Terminal va chạm: `print("[COLLISION] Hitbox trúng Hurtbox:", target.name)`.
- [x] Khắc phục cảm giác điều khiển khi tấn công (Attack Movement):
  - Trong `ATTACK` và `CAST`: Cho phép Player di chuyển mượt ở 45% tốc độ (99 px/s) khi có input và xoay hướng đánh tương ứng, loại bỏ hiện tượng đơ giật.
  - Trạng thái `BLOCK` giữ nguyên đứng yên 100% (`velocity = Vector2.ZERO`).
- [x] Khắc phục luồng Đỡ/Phản đòn:
  - Player nhận hit tính `full_dmg` trừ giáp chuẩn xác theo SPEC 3.2.
  - Phản đòn hoàn hảo trừ 20% thể lực quái, hủy đòn đang vung, gây choáng 60 ticks (hoặc 120 ticks khi cạn thể lực), hiện Floating Text trên cả Player và Quái.
- [x] Bổ sung 2 ca kiểm thử mới trong `res://tests/test_player_combat.gd`:
  - `test_attack_movement_and_stationary_block`: Kiểm tra vận tốc 45% khi đánh và đứng yên khi block.
  - `test_hitbox_hurtbox_collision_integration`: Kiểm tra chuẩn hóa Layer/Mask và luồng va chạm gây sát thương.
- [x] Toàn bộ 38/38 tests trong test runner đạt 100% xanh.


