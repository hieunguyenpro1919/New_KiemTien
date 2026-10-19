# THEO DÕI TIẾN ĐỘ & NHIỆM VỤ (TASKS.MD)

Tài liệu theo dõi trạng thái thực thi của từng Milestone theo quy tắc AGENT_RULES.

---

## Trạng thái tổng thể

- [x] **Milestone M0 — Thiết lập hạ tầng** (Hoàn thành)
- [x] **Milestone M1 — Di chuyển 8 hướng & Đấu trường mẫu** (Hoàn thành)
- [ ] **Milestone M2 — Combat vertical slice** (Đang thực hiện)
  - [x] **M2.1: Bộ giải quyết sát thương (DamageResolver) & Bộ ca kiểm thử vàng** (Hoàn thành)
  - [x] **M2.2: Hệ thống Đòn đánh của Player và Cơ chế Đỡ/Phản trực quan** (Hoàn thành)
  - [ ] **M2.3: Quái 1, quái 2 & SimpleAI** (Chưa bắt đầu)
  - [ ] **M2.4: Đỡ, phản đòn, choáng & thể lực** (Chưa bắt đầu)
  - [ ] **M2.5: Bảng debug F3 & UI máu/danh hiệu** (Chưa bắt đầu)
  - [ ] **M2.6: Kịch bản phát lại (replay)** (Chưa bắt đầu)
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
