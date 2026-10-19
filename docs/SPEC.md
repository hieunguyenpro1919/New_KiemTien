# KIẾM TIÊN — PLAN CHỐT ĐỂ SANG BUILD (v1.0)

**Vai trò tài liệu:** thay thế PLAN Giai đoạn 1, 2, 3 làm nguồn duy nhất cho BUILD. Khi mâu thuẫn, tài liệu này thắng.
**Công nghệ:** Godot 4.7.x, GDScript có kiểu. Antigravity lập trình. Chủ dự án chơi thử và quyết định bản sắc.

**Nhãn (dùng đúng 4 nhãn của GĐ3):**
- **[Ý TƯỞNG CHỦ DỰ ÁN]** do chủ dự án nêu. AI không được đổi ý nghĩa nếu chưa có duyệt mới.
- **[MẶC ĐỊNH PROTOTYPE]** AI/Claude chọn để thử. Đổi được bằng cấu hình, có ghi lý do.
- **[ĐÃ KIỂM CHỨNG]** đã có kết quả chạy thật. Hiện chưa có mục nào.
- **[ĐỂ GIAI ĐOẠN SAU]** không làm trong prototype.

---

## 0. Đánh giá PLAN Giai đoạn 3

**Kết luận: khả thi và đúng hướng chiến lược.** Chuyển từ lập kế hoạch sang một lát cắt chiến đấu chạy được là quyết định đúng. Phạm vi M0–M2b vừa sức. Không nên tiếp tục vòng PLAN mới. Nhưng GĐ3 có lỗi cần sửa trước khi giao BUILD:

| # | Vấn đề trong GĐ3 | Mức | Xử lý trong tài liệu này |
|---|---|---|---|
| 1 | Mục 2.3 đổi ý chủ dự án: phản đòn hoàn hảo **không** gây choáng, choáng chỉ khi cạn thể lực. Chủ dự án đã nói đỡ hoàn hảo gây choáng và bào thể lực. | Nặng | Khôi phục. Phản đòn hoàn hảo = choáng ngắn + trừ 20% thể lực. Cạn thể lực = choáng dài hơn (mục 3.4). |
| 2 | Mục 2.2 thay công thức đỡ của chủ dự án bằng "Phòng thủ + Sức tấn công × hệ số hỗ trợ đỡ" (và cấm cấp công pháp chi phối đỡ). Công thức mới còn mơ hồ thứ tự phép tính. | Nặng | Khôi phục (Phòng thủ + Tấn công) × hệ số cấp công pháp cao nhất đang trang bị (mục 3.3). |
| 3 | Trừ 20% thể lực áp cho cả "đỡ đòn thành công". Chủ dự án chỉ gắn nó với đỡ hoàn hảo/phản đòn. | Vừa | Chỉ áp cho đỡ hoàn hảo. Đỡ sớm không trừ thể lực (cấu hình được). |
| 4 | Mục 2.3 và mục 8 (trường hợp 4) cho phép AI bỏ quy tắc "chỉ vì đã có trong tài liệu". Điều này mở đường cho AI viết lại quy tắc của chủ dự án. | Nặng | Thêm danh sách BẤT BIẾN (mục 1). AI chỉnh số, không chỉnh ý nghĩa. |
| 5 | "Ngưỡng đỡ" so với cái gì chưa nói. So với sát thương sau phòng thủ thì phòng thủ bị tính hai lần. | Nặng | So với sát thương thô trước giảm trừ (mục 3.3). |
| 6 | Thiếu công thức giảm trừ phòng thủ, sát thương khi đỡ hoàn hảo, khi đỡ thất bại. | Vừa | Chốt mặc định (mục 3.2, 3.3). |
| 7 | Cửa sổ "±3 khung hình quanh thời điểm trúng" không triển khai được: sau thời điểm trúng, sát thương đã tính xong. | Vừa | Chuyển thành cửa sổ một phía trước thời điểm trúng, cùng độ rộng 7 tick (mục 3.3). Giá trị này do tôi đề xuất ở GĐ2, đây là sửa của tôi. |
| 8 | Giữ đỡ vô hạn sẽ luôn giảm 50% và làm né thành thừa. | Vừa | Đỡ có thời lượng và hồi (mục 3.3). |
| 9 | Prototype không có tính năng bản sắc: danh hiệu quái, không hiện cấp số, đánh thử để đoán sức mạnh. | Vừa | Thêm vào phạm vi (mục 3.6). |
| 10 | Chưa nói cách kiểm thử khi AI không tự cảm nhận được "cảm giác chơi". Kiểm thử hồi quy viết "khi có thể". | Vừa | Tick cố định, seed, chạy không giao diện, ca kiểm thử vàng (mục 6), cổng chơi thử của chủ dự án (mục 8). |
| 11 | Chưa khóa phiên bản Godot, ngôn ngữ, cách chạy test. | Nhỏ | Mục 2. |

**Điểm GĐ3 làm tốt, giữ nguyên:** phạm vi prototype, danh sách 7 thành phần, M0–M2b, quy tắc xử lý thất bại, tách lỗi với yêu cầu mới, "không tuyên bố đã chạy nếu chưa chạy".

**Sửa lỗi của chính tôi:** ở vòng đánh giá công thức sát thương tôi viết rằng ST cơ bản 1.000, trang bị 5.000, chiêu cấp 18, chiêu +300%, chí mạng +100% "vượt 99.999.999 rất dễ". Tính lại: (1.000 + 5.000) × 18 × 4 × 2 = **864.000**, xa trần. Vấn đề thật là ngược lại: để chạm dải 8 chữ số với chiêu cấp 18, +200%, chí mạng +50%, ST cơ bản phải cỡ 123.000 (không giáp) đến 247.000 (địch có giáp bằng ST). Nghĩa là thang chỉ số của game phải đi từ cỡ trăm lên cỡ trăm nghìn. Việc này để M2b và các mốc sau lo, không chặn prototype.

---

## 1. Quy tắc làm việc và danh sách BẤT BIẾN

### 1.1. BẤT BIẾN: AI không được đổi ý nghĩa nếu chưa có duyệt của chủ dự án

1. Game 2D mới, tu tiên, PC, Godot, điều khiển bằng phím, góc nhìn 8 hướng. Không liên quan game cũ.
2. Ba trụ cột tu luyện, chế tạo, trồng trọt. Không ép làm hết.
3. Công pháp: phẩm Hoàng 9, Huyền 12, Địa 15, Thiên 18 là cấp tối đa. Sáu hệ. Chưa có tương khắc.
4. Dung hợp không mất công pháp gốc, đầu ra chưa tu luyện, tốn nhiều Ngộ Đạo. Cùng hệ giữ hệ với hệ số cao hơn. Khác hệ thành song hệ theo tỉ lệ cấp (ví dụ 10 và 5 cho 2:1).
5. Ngộ Đạo nâng cấp công pháp, bí pháp, tiên pháp. Cơ bản +1 mỗi đòn hoặc mỗi giây.
6. Trần sát thương 99.999.999. Công thức sát thương theo chủ dự án: (ST cơ bản + ST trang bị/đan dược/dược phẩm) × hệ số cấp chiêu × (1 + %ST chiêu) × (1 + %ST chí mạng). Xuyên giáp và giảm kháng chỉ làm địch nhận thêm sát thương.
7. Đỡ: đúng lúc nhận đòn là hoàn hảo (phản đòn, **choáng**, trừ thể lực địch). Đỡ trước là chỉ giảm sát thương. Đỡ sau là thất bại. Đòn vượt chỉ số đỡ thì bỏ qua đỡ, thành thất bại.
8. Giá trị đỡ/phản = (Phòng thủ + Tấn công) × hệ số **cấp** (không phải phẩm) của công pháp cấp cao nhất đang trang bị. Thể lực mặc định bị trừ 20%.
9. Quái và boss không hiện cấp số, dùng danh hiệu do chủ dự án quyết định. Người chơi đánh thử để biết mạnh yếu. Cộng đồng tạo quái là hướng về sau.
10. Bí pháp nhận từ phó bản. Tiên pháp nhận từ chuỗi "Tiên Duyên" (đang bàn riêng với ChatGPT).

### 1.2. AI được tự quyết, không cần hỏi chủ dự án

Mọi giá trị trong bảng cấu hình (mục 5), chi tiết GDScript, cấu trúc thư mục, tên biến, cách bố trí scene, bố cục debug, và mọi chỗ trong tài liệu gắn **[MẶC ĐỊNH PROTOTYPE]**. Đổi một mặc định thì ghi vào `docs/DECISIONS.md`: giá trị cũ, giá trị mới, lý do, kết quả test.

### 1.3. Phải dừng và báo chủ dự án

Khi một thay đổi làm đổi ý nghĩa của mục BẤT BIẾN, hoặc khi prototype cho thấy một mục BẤT BIẾN không thể hoạt động. Báo hệ quả bằng số liệu và đề xuất phương án.

### 1.4. Không tự sáng tác canon

Tên danh hiệu, tên công pháp, tên chiêu, tên vùng đất: dùng chỗ giữ chỗ như `[Danh hiệu thử 1]`. Chủ dự án đặt tên thật.

---

## 2. Quyết định kỹ thuật đã chốt

| Hạng mục | Quyết định |
|---|---|
| Phiên bản Godot | Nhánh **4.7.x**. M0 khóa bản stable mới nhất của nhánh này (theo thông tin tìm được, 4.7.2-stable là bản bảo trì hiện hành; Antigravity xác minh trên trang chính thức khi cài) và ghi vào `docs/PROJECT_VERSION.md`. Không nâng bản trong prototype. [MẶC ĐỊNH PROTOTYPE] |
| Ngôn ngữ | GDScript có khai báo kiểu. Không dùng C#. Không dùng addon bên thứ ba trong prototype. [MẶC ĐỊNH PROTOTYPE] |
| Thời gian chiến đấu | Mọi bộ đếm giờ chiến đấu tính bằng **physics tick**, 60 tick/giây, xử lý trong `_physics_process`. Không dùng `delta` thực cho logic quyết định đỡ, né, choáng. 1 tick ≈ 16,7 ms. [MẶC ĐỊNH PROTOTYPE] |
| Ngẫu nhiên | Một `RandomNumberGenerator` có seed duy nhất cho chí mạng. Seed lấy từ cấu hình, in ra log. Test có thể ép chí mạng bật/tắt. |
| Dữ liệu | Resource `.tres` có script kiểu cho công pháp, quái, đòn đánh của quái, cấu hình chiến đấu. Không JSON trong prototype. |
| Kiểm thử | Bộ chạy test tự viết, chạy không giao diện: `godot --headless --script res://tests/run_tests.gd`. Trả mã thoát khác 0 nếu có test hỏng. Không dùng GUT hay GdUnit4 lúc này. [MẶC ĐỊNH PROTOTYPE] |
| Hàm thuần | `DamageResolver` toàn hàm `static`, không đọc scene, không trạng thái ẩn, không tự gọi RNG (nhận kết quả chí mạng làm tham số). |
| Git | Có. Một commit cho mỗi nhóm thay đổi có test xanh. |
| Điều khiển (phím mặc định) | WASD di chuyển 8 hướng. J đòn cơ bản. K công pháp. L đỡ. C tu luyện. E tương tác (xung tâm niệm). F3 bảng debug. R đặt lại tình huống. U tiêu Ngộ Đạo nâng công pháp mẫu (debug). Qua Input Map, đổi được. |

---

## 3. Đặc tả chiến đấu đã chốt cho prototype

### 3.1. Thuật ngữ

- **Điểm trúng (impact tick):** tick đầu tiên hitbox của một đòn đang hoạt động và chạm hurtbox mục tiêu.
- **Đòn (attack instance):** mỗi lần vung có một `attack_id`. Mỗi mục tiêu chỉ bị trúng một lần cho mỗi `attack_id` (sổ đăng ký trúng). Đây là cách chặn sát thương lặp.
- **Sát thương thô (raw):** kết quả bước 4 của luồng tính, trước giảm trừ phòng thủ.

### 3.2. Luồng tính sát thương [Ý TƯỞNG CHỦ DỰ ÁN cho bước 1–4, 7; MẶC ĐỊNH PROTOTYPE cho bước 5–6]

1. `base = atk_base + atk_bonus` (bonus gồm trang bị, đan dược, dược phẩm).
2. `coef = level_coef(level)`. Mặc định `level_coef(L) = L` (theo ví dụ chủ dự án). Đòn cơ bản dùng `coef = 1`.
3. `skill = base × coef × (1 + skill_bonus_pct)`. Ví dụ chủ dự án: chiêu gây 200% thì `skill_bonus_pct = 2.0`.
4. Chí mạng: nếu trúng chí mạng, `raw = skill × (1 + crit_bonus)`, ngược lại `raw = skill`. Mặc định `crit_rate = 0.10`, `crit_bonus = 0.5` cho người chơi. Quái dùng `crit_rate = 0`.
5. Giảm trừ: `def_eff = max(0, defense × (1 − armor_pen_pct) − armor_pen_flat)`, `mitigation = base / (base + def_eff)`, `dmg = raw × mitigation`. Mặc định `armor_pen_pct = 0`, `armor_pen_flat = 0`. Giảm kháng để sau.
   Lý do chọn: không âm, không về 0, không phụ thuộc thang số. Ai cũng thấy: giáp bằng ST cơ bản thì giảm 50%.
6. Làm tròn một quy tắc duy nhất: làm tròn nửa lên về số nguyên. Nếu `raw > 0` thì `final = clamp(round(dmg), 1, 99.999.999)`. Nếu `raw ≤ 0` hoặc `base ≤ 0` thì `final = 0` và ghi lỗi vào log.
7. Trần 99.999.999 áp ở bước cuối.

### 3.3. Đỡ, đỡ hoàn hảo, phản đòn

**Ngưỡng đỡ [Ý TƯỞNG CHỦ DỰ ÁN]:** `threshold = (Phòng thủ + Tấn công) × level_coef(cấp công pháp cao nhất đang trang bị)`. "Tấn công" là `atk_base + atk_bonus` của người đỡ. Mặc định `parry_coef` dùng cùng hàm `level_coef`, tách thành cấu hình riêng để chỉnh độc lập.

**So sánh [MẶC ĐỊNH PROTOTYPE]:** so `raw` của đòn địch (trước giảm trừ) với `threshold`. `raw ≤ threshold` thì đỡ giữ được. `raw > threshold` thì đỡ bị phá, coi như thất bại. Lý do: phòng thủ đã nằm trong ngưỡng, so với sát thương sau giảm trừ thì bị tính hai lần.

**Trạng thái đỡ [MẶC ĐỊNH PROTOTYPE]:**
- Bấm L để dựng đỡ. Đỡ hoạt động `block_active_ticks = 24` tick (0,4 giây), sau đó hồi `block_cooldown_ticks = 18` tick (0,3 giây) trong đó bấm L bị bỏ qua. Trong lúc đỡ, nhân vật không di chuyển.
- Gọi `delta = impact_tick − press_tick` khi đòn địch trúng lúc đỡ đang hoạt động:

| delta | Kết quả (khi `raw ≤ threshold`) |
|---|---|
| 0 đến 6 | **Đỡ hoàn hảo**: sát thương nhận 0, địch mất 20% thể lực tối đa, địch bị choáng 60 tick, đòn đang vung của địch bị hủy |
| 7 đến 24 | **Đỡ sớm**: sát thương nhận = kết quả bước 6 nhân 0,5 (làm tròn sau khi nhân), không trừ thể lực địch |
| không có đỡ hoạt động tại điểm trúng (bấm sau điểm trúng, hết giờ, đang hồi) | **Đỡ muộn/không đỡ**: nhận đủ sát thương |
| bất kỳ, nhưng `raw > threshold` | **Đỡ bị phá**: nhận đủ sát thương, không trừ thể lực, không choáng |

Cửa sổ hoàn hảo rộng 7 tick (khoảng 117 ms), cùng độ rộng với mốc "±3 khung hình" của GĐ2, chỉ dịch hết về trước điểm trúng vì sau điểm trúng không thể đảo ngược sát thương. Đây là con số khó nhất để đoán trên giấy. Nếu chủ dự án thấy quá khó, chỉnh `perfect_window_ticks` lên 9 đến 12 mà không đụng mã.

Phản đòn hoàn hảo hiện không gây sát thương riêng (`parry_counter_damage_pct = 0`). Cơ hội phản công chính là thời gian choáng.

### 3.4. Thể lực và choáng [Ý TƯỞNG CHỦ DỰ ÁN cho 20% và choáng; MẶC ĐỊNH PROTOTYPE cho số còn lại]

- Mỗi quái có `stamina_max = 100`. Đỡ hoàn hảo trừ `parry_stamina_drain_pct = 0.20` của thể lực tối đa.
- Thể lực về 0 thì quái choáng `stamina_break_stun_ticks = 120` (2 giây). Nếu đang choáng 60 tick do phản đòn, lấy giá trị lớn hơn, không cộng dồn.
- Sau khi hết choáng do cạn thể lực: thể lực đặt lại 50%. Sau mọi lần hết choáng: miễn choáng mới `stun_immunity_ticks = 60` (1 giây). Hai quy tắc này chặn vòng choáng liên tục.
- Hồi thể lực: `stamina_regen_per_sec = 10`, bắt đầu sau `stamina_regen_delay_ticks = 120` không bị trừ.
- Choáng hủy hành động hiện tại của quái.
- Thể lực người chơi: hiển thị trong Stats nhưng prototype **chưa tiêu hao** (không có chi phí nào do chủ dự án quy định). [ĐỂ GIAI ĐOẠN SAU]

### 3.5. Né bằng di chuyển [MẶC ĐỊNH PROTOTYPE]

- Đòn của quái có ba pha: báo hiệu (`windup_ticks`), gây sát thương (`active_ticks`), hồi (`recovery_ticks`). Vùng đánh xác định lúc bắt đầu pha gây sát thương, không bám theo người chơi.
- Người chơi rời vùng trong pha báo hiệu thì không trúng.
- Không có i-frame, không có lướt trong prototype. Chúng chỉ thêm nếu kiểm thử cho thấy cần. [ĐỂ GIAI ĐOẠN SAU]
- Quái mạnh chạy chậm hơn người chơi một chút để chạy trốn khả thi. Quái bỏ đuổi khi người chơi cách xa hơn `leash_range`.

### 3.6. Quái, danh hiệu, thăm dò [Ý TƯỞNG CHỦ DỰ ÁN cho nguyên tắc; MẶC ĐỊNH PROTOTYPE cho cách thể hiện]

- Quái hiển thị **danh hiệu** phía trên đầu và thanh máu. Không hiện cấp số, không hiện số máu trên thanh. Danh hiệu trong prototype là chỗ giữ chỗ: `[Danh hiệu thử 1]` (quái yếu), `[Danh hiệu thử 2]` (quái mạnh). Hai danh hiệu này **không** được gợi ý rõ ai mạnh hơn, để người chơi phải đánh thử.
- Tín hiệu đánh thử: thanh máu quái tụt bao nhiêu sau một đòn, số sát thương bay lên của người chơi, và phản ứng của quái.
- Bảng debug (F3) được hiện số thật. Bảng này tắt mặc định và ghi rõ "chỉ để phát triển".

---

## 4. Ngộ Đạo (prototype) [Ý TƯỞNG CHỦ DỰ ÁN cho nguồn và +1; MẶC ĐỊNH PROTOTYPE cho điều kiện]

**Chiến đấu:** +1 Ngộ Đạo mỗi lần công pháp (phím K) trúng một mục tiêu hợp lệ. Mục tiêu hợp lệ: còn sống và `is_hostile = true`. Đòn hụt, đòn cơ bản, và mục tiêu vô hại không cho Ngộ Đạo.

**Tu luyện:**
- Phím C vào trạng thái tu luyện. +1 mỗi giây (60 tick).
- Mỗi `pulse_interval_s = 15` giây hiện một "xung tâm niệm". Người chơi phải bấm E trong `pulse_window_s = 3` giây. Không bấm thì phiên tạm dừng, không cộng Ngộ Đạo cho đến khi bấm E lại.
- Phiên kết thúc nếu người chơi di chuyển, bị trúng đòn, hoặc đạt `session_cap = 300` Ngộ Đạo.
- Thiết kế này chặn "treo máy": không có tương tác thì không có Ngộ Đạo, và mỗi phiên có trần.

**Tiêu Ngộ Đạo:** nâng công pháp mẫu từ cấp L lên L+1 tốn `cost(L) = round(30 × 1.35^(L−1))`. Công pháp mẫu thuộc phẩm Hoàng, cấp tối đa 9, bắt đầu cấp 3 trong tình huống thử (để ngưỡng đỡ có giá trị 450).

Tổng Ngộ Đạo để đi từ cấp 1 đến cấp tối đa, theo hàm trên (điểm khởi đầu cho mô phỏng M2b, chưa phải cân bằng):

| Phẩm | Cấp tối đa | Tổng Ngộ Đạo | Giờ nếu thu đều 1/giây |
|---|---|---|---|
| Hoàng | 9 | 862 | 0,24 |
| Huyền | 12 | 2.243 | 0,62 |
| Địa | 15 | 5.640 | 1,57 |
| Thiên | 18 | 14.000 | 3,89 |

Nhận xét thẳng: với đường cong này công pháp Hoàng đầy cấp chỉ mất khoảng 14 phút thu liên tục, nhiều khả năng **quá dễ** so với yêu cầu "không quá dễ, không quá khó". Thu thực tế trong chiến đấu thấp hơn 1/giây (mỗi lần dùng chiêu có hồi chiêu), nên thời gian thật dài hơn vài lần. M2b phải mô phỏng và chỉnh `base` và `growth` trước khi khóa.

---

## 5. Dữ liệu mặc định và bảng cấu hình [MẶC ĐỊNH PROTOTYPE]

### 5.1. Nhân vật và quái (tình huống thử)

| | Người chơi | Quái 1 (yếu) | Quái 2 (mạnh) |
|---|---|---|---|
| Máu | 1.000 | 300 | 3.000 |
| ST cơ bản / bonus | 100 / 0 | 40 / 0 | 400 / 0 |
| Phòng thủ | 50 | 10 | 100 |
| Thể lực tối đa | 100 (chưa dùng) | 100 | 100 |
| Tốc độ di chuyển (px/giây) | 220 | 160 | 200 |
| Phạm vi phát hiện / bỏ đuổi (px) | | 300 / 600 | 300 / 600 |
| Đòn | Cơ bản coef 1. Công pháp mẫu cấp 3, `skill_bonus_pct` 1.0, hồi 120 tick | Thường: coef 1, báo hiệu 30, gây 6, hồi 30 tick | Thường: coef 1, báo hiệu 30, gây 6, hồi 30. Nặng: coef 2.5, báo hiệu 48, gây 6, hồi 45. Lặp: thường, thường, nặng |

Quái mạnh có đòn thường `raw = 400` (đỡ được, vì ≤ 450) và đòn nặng `raw = 1000` (vượt 450, **đỡ bị phá**, phải né). Đây là cách prototype chứng minh quy tắc "đòn quá mạnh thì không đỡ được".

### 5.2. Tham số cấu hình (`CombatConfig`)

| Tham số | Mặc định |
|---|---|
| `tick_rate` | 60 |
| `level_coef_mode` | tuyến tính, `L` |
| `parry_coef_mode` | cùng `level_coef` |
| `perfect_window_ticks` | 6 (delta 0 đến 6) |
| `block_active_ticks` | 24 |
| `block_cooldown_ticks` | 18 |
| `early_block_reduction` | 0.5 |
| `perfect_parry_damage_reduction` | 1.0 |
| `failed_block_damage_pct` | 1.0 |
| `parry_stamina_drain_pct` | 0.20 |
| `perfect_parry_stun_ticks` | 60 |
| `stamina_break_stun_ticks` | 120 |
| `stamina_after_break_pct` | 0.5 |
| `stun_immunity_ticks` | 60 |
| `stamina_regen_per_sec` / `delay_ticks` | 10 / 120 |
| `player_crit_rate` / `crit_bonus` | 0.10 / 0.5 |
| `damage_cap` | 99.999.999 |
| `rng_seed` | 12345 |
| Ngộ Đạo: `combat_gain`, `cultivate_gain_per_sec`, `pulse_interval_s`, `pulse_window_s`, `session_cap` | 1, 1, 15, 3, 300 |
| Ngộ Đạo: `cost_base`, `cost_growth` | 30, 1.35 |

---

## 6. Bộ ca kiểm thử vàng

Các giá trị dưới đây đã được tính bằng một đoạn mã độc lập với đúng công thức ở mục 3.2. Test của Godot phải cho **đúng các số này**. Nếu khác, lỗi nằm ở mã hoặc ở công thức, phải điều tra, không được sửa số kỳ vọng cho khớp.

### 6.1. Sát thương (`DamageResolver`)

| Mã | Tình huống | Kết quả |
|---|---|---|
| G1 | Ví dụ chủ dự án: base 100 + bonus 700, coef 18, `skill_bonus_pct` 2.0, chí mạng +0,5, def 0 | raw 64.800, final **64.800** |
| G1b | Như G1, không chí mạng | **43.200** |
| G2 | Đòn cơ bản người chơi vs quái 1 | raw 100, final **91** |
| G3 | Công pháp cấp 3 vs quái 1 | raw 600, final **545** |
| G4 | Công pháp cấp 3 vs quái 2 | raw 600, final **300** |
| G5 | Đòn cơ bản vs quái 2 | final **50** |
| G6 | Quái 2 đòn thường vs người chơi | raw 400, final **356** |
| G7 | Quái 2 đòn nặng vs người chơi | raw 1000, final **889** |
| G8 | Quái 1 vs người chơi | raw 40, final **18** |
| G9 | Công pháp cấp 3 chí mạng vs quái 2 | raw 900, final **450** |
| G10 | Trần: base 2.000.000, coef 18, bonus 2.0, chí mạng +0,5, def 0 | raw 162.000.000, final **99.999.999** |
| G11 | `atk_base = 0` hoặc giá trị âm | final **0**, có dòng lỗi trong log |
| G12 | Xuyên giáp 50%, công pháp cấp 3 vs quái 2 | final **400** |

### 6.2. Đỡ (`threshold = 450` với công pháp cấp 3)

| Mã | Tình huống | Kết quả |
|---|---|---|
| B1 | Quái 2 đòn thường (raw 400), delta = 3 | Đỡ hoàn hảo: nhận **0**, quái mất 20 thể lực, choáng **60** tick |
| B2 | Như B1, delta = 12 | Đỡ sớm: nhận **178** (356 thô là 177,78 trước làm tròn), không trừ thể lực |
| B3 | Như B1, không bấm đỡ | Nhận **356** |
| B4 | Quái 2 đòn nặng (raw 1000), delta = 3 | Đỡ bị phá: nhận **889**, không trừ thể lực, không choáng |
| B5 | Biên: delta 0 và 6 hoàn hảo. delta 7 và 24 đỡ sớm. delta 25 nhận đủ | Đúng theo bảng mục 3.3 |
| B6 | Biên ngưỡng: `raw = 450` (ví dụ G9 chí mạng áp lên đòn có raw đúng 450) | Đỡ giữ được. `raw = 451` thì bị phá |
| B7 | Năm lần đỡ hoàn hảo liên tiếp lên một quái, mỗi lần cách nhau đủ để hết choáng 60 tick | Thể lực 100 → 80 → 60 → 40 → 20 → 0. Lần thứ năm: choáng **120** tick, hết choáng thể lực đặt lại **50**, sau đó miễn choáng 60 tick |
| B8 | Đang bấm đỡ trong thời gian hồi | Bị bỏ qua |

### 6.3. Ngộ Đạo

| Mã | Tình huống | Kết quả |
|---|---|---|
| N1 | Công pháp trúng quái hostile | +1 |
| N2 | Công pháp hụt. Đòn cơ bản trúng. Công pháp trúng mục tiêu `is_hostile = false` | +0 |
| N3 | Tu luyện 10 giây, bấm đủ xung | +10 |
| N4 | Tu luyện, bỏ lỡ xung | Dừng cộng cho đến khi bấm E |
| N5 | Tu luyện đủ để chạm 300 | Dừng ở 300, kết thúc phiên |
| N6 | `cost(1)` đến `cost(8)` | 30, 41, 55, 74, 100, 135, 182, 245 |

### 6.4. Tính xác định

Một tệp kịch bản đầu vào (`tests/replay/*.json`: danh sách tick, hành động, nhấn/nhả) chạy hai lần với cùng seed phải cho **cùng nhật ký sự kiện** (trúng, đỡ, choáng, Ngộ Đạo, sát thương). Chạy với seed khác chỉ được khác ở các sự kiện chí mạng.

---

## 7. Kiến trúc và cấu trúc dự án

Giữ 7 thành phần của GĐ3, thêm một lớp dữ liệu cho đòn của quái:

| Thành phần | Ghi chú |
|---|---|
| `PlayerController` | Đầu vào, di chuyển 8 hướng, máy trạng thái: idle, move, attack, cast, block, hit, cultivate |
| `CombatResolver` | Điều phối: đăng ký trúng, đồng hồ tick, cửa sổ đỡ, áp kết quả đỡ/phản/choáng. Gọi `DamageResolver`, không tự tính công thức |
| `Stats` | Máu, thể lực, chỉ số, choáng, miễn choáng |
| `DamageResolver` | Hàm thuần: `compute_damage`, `compute_block_threshold`, `evaluate_block`. Toàn bộ test vàng nhắm vào đây |
| `TechniqueData`, `EnemyData`, `AttackData` | Resource có script kiểu |
| `SimpleAI` | Máy trạng thái: idle, chase, windup, active, recovery, stunned |
| `EnlightenmentSystem` | Nhỏ. Thu và tiêu Ngộ Đạo, xung tâm niệm, trần phiên |

```
res://
  project.godot
  docs/        SPEC.md  DECISIONS.md  TASKS.md  AGENT_RULES.md  PROJECT_VERSION.md
  data/        combat_config.tres  techniques/  enemies/  attacks/
  scripts/     core/  data/  actors/  combat/  progression/  ui/
  scenes/      test_arena.tscn  player.tscn  enemy.tscn  ui/debug_panel.tscn
  tests/       run_tests.gd  test_damage.gd  test_block.gd  test_stamina.gd
               test_enlightenment.gd  replay/
```

Tên tệp `snake_case`, tên lớp `PascalCase`. Không sao chép công thức sát thương ra ngoài `DamageResolver`.

**Animation [MẶC ĐỊNH PROTOTYPE]:** prototype dùng hình khối và hoạt ảnh tạm. M0 làm một thử nghiệm nhỏ cho một clip đòn cơ bản bằng Skeleton2D và bằng sprite sheet, ghi thời gian làm và độ khó chỉnh khung gây sát thương vào `DECISIONS.md`. Chọn pipeline cho nhân vật chính sau thử nghiệm đó, không chặn gameplay. Người chơi dùng 5 hướng gốc và lật ngang cho 3 hướng còn lại khi art thật vào. Quái dùng 2 hướng.

---

## 8. Milestone

Mỗi mốc chỉ qua khi: (a) `run_tests.gd` xanh, (b) dự án mở và chạy trong editor không có lỗi đỏ, (c) có ghi chú trong `TASKS.md` về cái đã chạy thật và cái chưa.

**M0 — Thiết lập.** Cài và khóa Godot, tạo project, Git, `AGENT_RULES.md`, scene khởi động, Input Map, bộ chạy test rỗng nhưng chạy được, thử nghiệm animation, `DECISIONS.md`.
Qua mốc khi: dự án chạy, `PROJECT_VERSION.md` có số bản chính xác, lệnh test chạy được và trả mã thoát đúng.

**M1 — Di chuyển.** Di chuyển 8 hướng (đường chéo chuẩn hóa, không nhanh hơn), hướng nhìn, bản đồ nhỏ có va chạm, máy trạng thái cơ bản.
Qua mốc khi: điều khiển ổn định, không kẹt trạng thái.

**M2 — Combat vertical slice (mốc quan trọng nhất).** `DamageResolver` và toàn bộ test vàng mục 6.1 trước. Rồi đòn cơ bản, công pháp, hai quái, AI, đỡ/phản/choáng/thể lực, né bằng di chuyển, danh hiệu và thanh máu, bảng debug, nút đặt lại, nhật ký sự kiện, kịch bản phát lại.
Qua mốc khi: toàn bộ test 6.1, 6.2, 6.4 xanh **và** chủ dự án qua cổng chơi thử dưới đây.

**Cổng chơi thử của chủ dự án (10 phút).** AI không tự đánh giá được cảm giác, nên chủ dự án trả lời có/không cho các câu sau, AI chỉ chỉnh cấu hình để đạt:
1. Cửa sổ đỡ hoàn hảo có nhận ra và làm được không?
2. Đỡ có mạnh đến mức né thành thừa không?
3. Né bằng di chuyển có đủ hữu ích không?
4. Nhìn hai quái, có thể đoán ai mạnh hơn nhờ đánh thử không?
5. Chạy khỏi quái mạnh có khả thi và có rủi ro không?
6. Choáng sau phản đòn có tạo cơ hội phản công đáng giá không, hay làm quái bất lực quá lâu?
7. Nhịp chiến đấu có "vừa phải" không?

**M2b — Ngộ Đạo tối thiểu.** `EnlightenmentSystem`, test 6.3, hiển thị số Ngộ Đạo, nút nâng công pháp mẫu. Song song: bảng mô phỏng riêng (bảng tính hoặc script) cho nguồn thu và chi phí theo ba mức giờ chơi, kiểm tra riêng bốn phẩm.
Qua mốc khi: test 6.3 xanh, bảng mô phỏng đưa ra thời gian đạt cấp tối đa cho từng phẩm và chủ dự án xem qua.

**M3 trở đi:** chỉ mở sau khi M2 qua cổng. Thứ tự do kết quả prototype quyết định.

---

## 9. Chưa làm trong prototype

[ĐỂ GIAI ĐOẠN SAU]: dung hợp thật, danh sách công pháp, bí pháp, tiên pháp, chế tạo, trồng trọt, nhiệm vụ, cốt truyện, lưu tiến trình, PvP/co-op, công cụ cộng đồng, lướt và i-frame, tiêu hao thể lực người chơi, giảm kháng, tương khắc hệ, art thật.

**Gợi ý sơ bộ cho dung hợp (chưa phải canon, duyệt trước khi làm M4):**
- Cấp khởi điểm công pháp đầu ra: cấp 1, tiến độ 0.
- Phẩm đầu ra: phẩm cao hơn trong hai đầu vào (cho dung hợp có lợi, vì đã tốn Ngộ Đạo và phải tu luyện lại từ đầu).
- Hệ số cùng hệ: cộng thêm một lượng nhỏ cố định vào `skill_bonus_pct`, có giới hạn số lần.
- Tỉ lệ song hệ lưu thành trọng số riêng, chưa suy ra phần trăm sát thương.
- Chi phí chốt bằng bảng mô phỏng của M2b.

Những câu này không chặn BUILD.

---

## 10. Rủi ro còn lại

| Rủi ro | Kiểm soát |
|---|---|
| Cửa sổ đỡ hoàn hảo 7 tick có thể quá chặt | Tham số cấu hình, câu 1 của cổng chơi thử |
| Đường cong Ngộ Đạo hiện quá dễ cho phẩm Hoàng | M2b mô phỏng và chỉnh trước khi khóa |
| AI báo hoàn thành khi chưa chạy | Test vàng, lệnh test bắt buộc, quy tắc ở `AGENT_RULES.md` |
| Thang chỉ số từ 10² đến 10⁶ khi mở rộng | Hàm giảm trừ theo tỉ lệ nên không phụ thuộc thang. Kiểm tra lại ở M3 |
| Animation 8 hướng chiếm nhiều công | Hình khối tạm trước, lật ngang, quái 2 hướng, thử pipeline ở M0 |
| Mặc định của AI bị coi như quyết định của chủ dự án | Nhãn bắt buộc, `DECISIONS.md` |

---

## 11. Phụ lục: nội dung giao cho Antigravity

### 11.1. `docs/AGENT_RULES.md` (dán nguyên văn vào đầu mỗi nhiệm vụ)

```
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
```

### 11.2. Nhiệm vụ M0 + M1

```
Nhiệm vụ: M0 rồi M1 theo docs/SPEC.md mục 8.

M0:
- Xác minh trên trang chính thức bản stable mới nhất của nhánh Godot 4.7, cài, ghi docs/PROJECT_VERSION.md.
- Tạo project theo cấu trúc ở mục 7. Bật Git, .gitignore chuẩn cho Godot.
- Đặt physics_ticks_per_second = 60.
- Tạo Input Map: move_up/down/left/right (WASD), attack_basic (J), attack_technique (K),
  block (L), cultivate (C), interact (E), debug_toggle (F3), reset_scene (R), debug_spend (U).
- tests/run_tests.gd chạy được bằng `godot --headless --script res://tests/run_tests.gd`,
  trả mã thoát 0 khi xanh và khác 0 khi có test hỏng. Thêm một test mẫu.
- Thử nghiệm animation: một clip "đòn cơ bản" bằng Skeleton2D và bằng sprite sheet với tài nguyên tạm,
  ghi thời gian làm và nhận xét vào DECISIONS.md. Nếu lỗi, dùng hình khối và đi tiếp.

M1:
- scenes/test_arena.tscn có bản đồ nhỏ và va chạm.
- PlayerController: di chuyển 8 hướng, đường chéo chuẩn hóa, hướng nhìn, trạng thái idle/move.
- Dùng hình khối tạm. Chưa làm chiến đấu.

Báo cáo theo mục 10 của AGENT_RULES.
```

---

*Tài liệu này không chứa mã nguồn game và không tạo project Godot.*
