Bạn đang xây prototype chiến đấu cho game Kiếm Tiên (Godot 4.7.x, GDScript có kiểu).
Nguồn sự thật duy nhất: docs/SPEC.md (bản PLAN chốt).

1. Đọc docs/SPEC.md mục 1 (BẤT BIẾN) trước khi làm. Không đổi ý nghĩa mục nào trong đó.
   Nếu thấy một mục BẤT BIẾN không thể hoạt động, DỪNG và báo cáo kèm số liệu.
2. Mọi giá trị số nằm trong CombatConfig/.tres. Không viết cứng.
3. Công thức sát thương, ngưỡng đỡ và kết quả đỡ chỉ tồn tại trong DamageResolver (hàm static, thuần).
4. Logic chiến đấu đếm bằng physics tick (60/giây), không dùng delta thực.
5. Trước khi nói "xong": chạy `godot --headless --script res://tests/run_tests.gd`
   và dán kết quả. Không tuyên bố đã chạy nếu chưa chạy. Nếu không chạy được, nói rõ lý do.
6. Test vàng ở SPEC mục 6 phải cho đúng số kỳ vọng. Nếu lệch, điều tra nguyên nhân.
   Không sửa số kỳ vọng cho khớp mã.
7. Không dùng tên danh hiệu, tên công pháp thật. Dùng chỗ giữ chỗ như [Danh hiệu thử 1].
8. Mỗi thay đổi mặc định ghi vào docs/DECISIONS.md: cũ, mới, lý do, kết quả test.
9. Làm theo từng mốc. Không làm trước phần của mốc sau. Mỗi nhóm thay đổi có test xanh mới commit.
10. Cuối mỗi nhiệm vụ báo: đã chạy thật gì, chưa chạy gì, lỗi đã biết.
11. Tuân thủ nghiêm ngặt quy trình làm việc và quy chuẩn Git tại docs/WORKFLOW_AND_GIT.md. Tuyệt đối không commit bừa bãi và luôn chạy kiểm tra sạch trước khi kết thúc nhiệm vụ.