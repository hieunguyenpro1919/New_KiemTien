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
