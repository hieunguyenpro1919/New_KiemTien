# WORKFLOW PHÁT TRIỂN & QUY CHUẨN GIT — KIẾM TIÊN

Tài liệu này quy định chu trình phát triển (Dev Loop) và quy tắc sử dụng Git bắt buộc cho AI Agent (Antigravity).

---

## 1. VÒNG LẶP PHÁT TRIỂN 4 BƯỚC (THE 4-STEP DEV LOOP)

Mọi nhiệm vụ (task/milestone) phải đi qua tuần tự 4 bước sau, tuyệt đối không nhảy cóc:

### Bước 1: Tiếp nhận & Kiểm tra Ngữ cảnh (Context Check)
1. Đọc kỹ yêu cầu và đối chiếu với `docs/SPEC.md` (mục 1 - Danh sách BẤT BIẾN).
2. Kiểm tra trạng thái Git hiện tại:
   `git status`
   Nếu workspace còn file chưa commit từ task trước, phải xử lý dứt điểm trước khi làm task mới.

### Bước 2: Triển khai Code & Kiến trúc (Implementation)
1. Tách biệt rõ ràng giữa **Pure Logic** (các file tính toán thuần, static function trong `scripts/combat/` hoặc `scripts/core/`) và **Node Visuals** (các Scene `.tscn`).
2. Mọi thông số chiến đấu/cân bằng phải lấy từ `CombatConfig` hoặc các Resource `.tres`, không hardcode vào logic.
3. Luôn sử dụng physics ticks (60 tick/giây) cho logic thời gian chiến đấu.

### Bước 3: Kiểm chứng Kép (Dual Verification - Headless + Visual)
1. **Kiểm chứng tự động (Headless Verification):**
   Bắt buộc chạy: `godot --headless --script res://tests/run_tests.gd`
   - Chỉ được coi là đạt khi 100% test suites trả về PASS và exit code = 0.
   - Khi thêm tính năng mới, bắt buộc phải viết kèm test suite tương ứng trong `tests/`.
2. **Kiểm chứng khởi động (Smoke Test):**
   Chạy: `godot --headless --quit-after 30`
   - Đảm bảo scene chính khởi chạy sạch, không có cảnh báo vàng hoặc lỗi đỏ trong 30 tick đầu tiên.
3. **Báo cáo để Chủ Dự Án kiểm chứng thực tế (Visual/GUI Verification):**
   - Nêu rõ các phím bấm và tình huống cụ thể để Chủ Dự Án nhấn F5 test tay trực tiếp trên cửa sổ game.

### Bước 4: Đóng gói, Tài liệu hóa & Git Commit
1. Cập nhật `docs/DECISIONS.md`: Ghi rõ các quyết định kỹ thuật vừa thay đổi (cũ, mới, lý do).
2. Cập nhật `docs/TASKS.md`: Đánh dấu trạng thái hoàn thành.
3. Thực hiện Git commit theo đúng chuẩn ở Mục 2 dưới đây.

---

## 2. QUY CHUẨN QUẢN LÝ GIT (GIT PROTOCOLS)

### 2.1. Quy tắc Vàng: "Chỉ commit khi test đã Xanh"
- Tuyệt đối không commit mã nguồn đang gây lỗi gãy test runner (`run_tests.gd` thất bại).
- Không gom nhiều Milestone hoặc các tính năng không liên quan vào một commit khổng lồ.

### 2.2. Kiểm tra trước khi Add (Pre-commit Sanitation)
Trước khi `git add`, luôn kiểm tra danh sách file bị thay đổi:
`git status -s`
- **Các file TUYỆT ĐỐI KHÔNG commit:**
  - Thư mục `.godot/` (cache của engine).
  - Các file tạm: `*.tmp`, `*.uid` (nếu không bắt buộc), file log cá nhân.
  - File editor: `.antigravity/` (trừ khi có file cấu hình luật chung).
- Nếu phát hiện file rác xuất hiện trong `git status`, phải bổ sung ngay vào `.gitignore`.

### 2.3. Quy chuẩn Đặt tên Commit (Conventional Commits)
Sử dụng định dạng chuẩn ngành:
`<loại>(<phạm vi>): <mô tả ngắn bằng tiếng Anh hoặc tiếng Việt không dấu>`

Các tiền tố bắt buộc:
- `feat`: Thêm tính năng mới (ví dụ: `feat(player): implement basic attack and block`)
- `fix`: Sửa lỗi logic hoặc va chạm (ví dụ: `fix(collision): standardize hitbox layers`)
- `test`: Thêm hoặc sửa test suites (ví dụ: `test(combat): add golden tests G1-G12`)
- `refactor`: Tái cấu trúc mã nguồn mà không đổi hành vi
- `docs`: Cập nhật tài liệu (SPEC, DECISIONS, TASKS)
- `chore`: Cấu hình engine, project settings, gitignore

### 2.4. Quy trình Đẩy lên Remote (Push for Review)
Khi hoàn tất một Milestone và Chủ Dự Án nghiệm thu:
1. Kiểm tra lại log commit gần nhất:
   `git log -n 5 --oneline`
2. Đẩy nhánh làm việc lên remote GitHub:
   `git push origin <branch_name>`
3. Báo cáo hash commit và đường dẫn repo để gửi Claude review.

---

## 3. MẪU BÁO CÁO KẾT THÚC NHIỆM VỤ CỦA AGENT

Sau mỗi lần thực thi xong, Agent bắt buộc phải xuất báo cáo theo đúng khung sau:

```markdown
### Báo cáo thực thi: [Tên Nhiệm vụ / Milestone]

1. Các file đã tạo / chỉnh sửa:
   - [Đường dẫn file] - Tóm tắt thay đổi

2. Kết quả kiểm thử tự động (Headless):
   - Lệnh: `godot --headless --script res://tests/run_tests.gd`
   - Số test: [X] passed, [Y] failed (Mã thoát: [0 / 1])

3. Kết quả Smoke Test:
   - Lệnh: `godot --headless --quit-after 30` (Mã thoát: [0 / 1])

4. Tình trạng Git:
   - Commit: `[Commit Hash] [Commit Message]`
   - Branch: `[Tên Branch]`

5. Hướng dẫn Chủ Dự Án test thực tế (GUI Test):
   - Bấm F5, nhấn phím [X] để kiểm tra tính năng [Y].
   - Kết quả mong đợi: [...]
```