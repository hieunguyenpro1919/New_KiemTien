# WORKFLOW PHÁT TRIỂN & QUY CHUẨN KỸ THUẬT — KIẾM TIÊN (v2.0)

**Vị trí lưu:** `docs/WORKFLOW.md`
**Nguyên tắc tối cao:** Nguồn sự thật duy nhất là `docs/SPEC.md`. Khi có mâu thuẫn, SPEC luôn thắng.

---

## 1. PHÂN CHIA VAI TRÒ (SEPARATION OF CONCERNS)

| Vai trò | Thực thể đảm nhiệm | Trách nhiệm chính | Điều CẤM kỵ |
|---|---|---|---|
| **Chủ dự án** | Ngài | Quyết định bản sắc, luật BẤT BIẾN, đặt tên canon, chơi thử thực tế, duyệt quyết định kỹ thuật | Không cần đọc/sửa mã nguồn |
| **Điều phối** | Gemini | Giữ nhịp dự án, soạn prompt chuẩn giao việc, tổng hợp báo cáo, nhắc nhở quy trình | Không tự ý sửa SPEC, không duyệt thay Chủ dự án |
| **Sáng tạo** | ChatGPT | Thảo luận lore, cơ chế gameplay, đề xuất mở rộng cùng Chủ dự án | Ý tưởng mới chỉ vào SPEC sau khi Chủ dự án duyệt |
| **Lập trình viên (Coder)** | Antigravity / OpenCode | Viết mã nguồn GDScript, dựng scene, chạy test, sửa lỗi theo mốc, commit Git | Không đổi BẤT BIẾN, không sửa số kỳ vọng test vàng, không làm trước mốc sau |
| **Giám sát & QA** | Claude | Review mã độc lập, chạy test tích hợp, soát mâu thuẫn SPEC, bóc tách lỗi ngầm | Không tự ý viết mã tính năng, không tự đổi thiết kế |

> **Nguyên tắc vàng:** Bên viết mã (Antigravity) và bên kiểm tra/giám sát (Claude) luôn luôn là hai AI độc lập. Ý tưởng từ ChatGPT không bao giờ đưa thẳng vào Antigravity mà phải qua thẩm định của Claude và Chủ dự án phê duyệt vào `docs/SPEC.md`.

---

## 2. CHU TRÌNH PHÁT TRIỂN 4 BƯỚC (THE 4-STEP DEV LOOP)

Mọi nhiệm vụ (Fix lỗi hoặc làm Milestone) đều phải tuân thủ nghiêm ngặt 4 bước:

### Bước 1: Kiểm tra ngữ cảnh & Vệ sinh Git (Context Check)
1. Đọc kỹ yêu cầu và đối chiếu với `docs/SPEC.md` (mục 1 - Danh sách BẤT BIẾN).
2. Kiểm tra trạng thái Git: `git status -s`. Phải đảm bảo không còn file rác hoặc thay đổi dở dang trước khi làm task mới.

### Bước 2: Triển khai Code & Kiến trúc (Implementation)
1. **Tách biệt Logic và Visual:** Các hàm tính toán thuần túy đặt trong `scripts/combat/` hoặc `scripts/core/` (hàm static, không phụ thuộc scene).
2. **Không dùng số cứng (No Hardcoding):** Mọi thông số chiến đấu, chỉ số quái, thời gian hồi chiêu bắt buộc phải nạp và đọc từ file `data/combat_config.tres` hoặc các resource `.tres` tương ứng.
3. **Đếm giờ chuẩn 60 FPS:** Luôn sử dụng physics ticks (60 tick/giây) cho logic thời gian chiến đấu.

### Bước 3: Kiểm chứng Kép (Dual Verification - Headless + Visual)
1. **Kiểm tra tự động (Headless Verification):**
   Chạy: `godot --headless --script res://tests/run_tests.gd`
   - Chỉ được coi là ĐẠT khi 100% test suites trả về PASS và exit code = 0.
   - **Quy tắc Tích hợp:** Test xanh là chưa đủ; bắt buộc phải có ít nhất một test tích hợp chạy qua đúng đường dẫn vật lý thực tế trong game (Hitbox → Hurtbox → Controller).
   - Tuyệt đối không sửa số kỳ vọng ở test vàng để khớp mã.
2. **Kiểm tra khởi động (Smoke Test):**
   Chạy: `godot --headless --quit-after 30` (đảm bảo scene chính chạy sạch lỗi trong 30 tick đầu).
3. **Hướng dẫn Chủ dự án kiểm chứng thực tế (Visual/GUI Verification):**
   Nêu rõ các phím bấm và tình huống cụ thể để Chủ dự án bấm F5 test tay.

### Bước 4: Đóng gói, Tài liệu hóa & Git Commit
1. Cập nhật `docs/DECISIONS.md`: Ghi rõ thay đổi (giá trị cũ, giá trị mới, lý do).
2. Cập nhật `docs/TASKS.md`: Đánh dấu trạng thái hoàn thành.
3. Thực hiện Git commit theo đúng chuẩn ở Mục 3 dưới đây.

---

## 3. QUY CHUẨN QUẢN LÝ GIT (GIT PROTOCOLS)

1. **Chỉ commit khi test đã Xanh:** Tuyệt đối không commit mã nguồn khi test runner đang báo đỏ.
2. **Tách nhỏ Commit:** Mỗi nhóm sửa lỗi hoặc tính năng phải commit riêng. Không gộp nhiều lỗi vào một commit khổng lồ.
3. **Quy chuẩn đặt tên (Conventional Commits):**
   - `fix(combat): ...` : Sửa lỗi tính toán, va chạm, logic.
   - `feat(progression): ...` : Thêm tính năng mới theo mốc.
   - `test(combat): ...` : Bổ sung hoặc cập nhật ca kiểm thử.
   - `refactor(...)`: Tái cấu trúc mã nguồn.
   - `docs(...)`: Cập nhật tài liệu SPEC, DECISIONS, TASKS.
4. **Quy trình bàn giao lên Remote để Claude Review:**
   - Kiểm tra log: `git log -n 5 --oneline`
   - Đẩy lên remote: `git push origin <branch_name>`
   - Báo cáo hash commit để chuyển sang phiên giám sát của Claude.

---

## 4. MẪU BÁO CÁO KẾT THÚC CỦA AGENT

Sau mỗi lần thực thi xong, Agent bắt buộc phải xuất báo cáo theo đúng cấu trúc:

```markdown
### Báo cáo thực thi: [Tên Nhiệm vụ / Milestone]

1. Các file đã tạo / chỉnh sửa:
   - [Đường dẫn file] - Tóm tắt thay đổi

2. Kết quả kiểm thử tự động (Headless Test):
   - Lệnh: `godot --headless --script res://tests/run_tests.gd`
   - Kết quả: [X] passed, [Y] failed (Mã thoát: [0 / 1])

3. Kết quả Smoke Test:
   - Lệnh: `godot --headless --quit-after 30` (Mã thoát: [0 / 1])

4. Tình trạng Git:
   - Commit: `[Commit Hash] [Commit Message]`
   - Branch: `[Tên Branch]`

5. Hướng dẫn Chủ Dự Án test thực tế (GUI Test):
   - Bấm F5, nhấn phím [X] để kiểm tra tính năng [Y].
   - Kết quả mong đợi: [...]