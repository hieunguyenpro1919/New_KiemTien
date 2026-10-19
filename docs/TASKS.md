# THEO DÕI TIẾN ĐỘ & NHIỆM VỤ (TASKS.MD)

Tài liệu theo dõi trạng thái thực thi của từng Milestone theo quy tắc AGENT_RULES.

---

## Trạng thái tổng thể

- [x] **Milestone M0 — Thiết lập hạ tầng** (Hoàn thành)
- [x] **Milestone M1 — Di chuyển 8 hướng & Đấu trường mẫu** (Hoàn thành)
- [ ] **Milestone M2 — Combat vertical slice** (Chưa bắt đầu)
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
