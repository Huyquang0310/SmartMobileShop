# Smart Mobile Shop – Group 2: Cập nhật quản trị và tồn kho

## 1. Phạm vi

Bản này giữ nguyên kiến trúc Java Web Servlet MVC2, EclipseLink/JPA và SQL Server, không bổ sung bảng hoặc thay đổi cấu trúc dữ liệu. Các chức năng bắt buộc của bài PRJ301 vẫn được giữ lại, bao gồm xác thực, CRUD, giỏ hàng, thống kê MAX/MIN/AVG/SUM/COUNT và Q&A.

## 2. Quản lý hiển thị sản phẩm

Một sản phẩm chỉ được hiển thị cho khách hàng khi **cả ba trạng thái** đều Active:

- `Products.status`
- `Brands.status`
- `Categories.status`

Quy tắc áp dụng cho trang Home, tìm kiếm, phân trang, nhóm New Arrivals/Featured/Best Sellers, sản phẩm liên quan, trang chi tiết, Q&A công khai, thêm/cập nhật giỏ hàng và checkout. Khi Brand/Category chuyển sang Inactive, sản phẩm không bị xóa và tồn kho không đổi. Đơn hàng lịch sử vẫn truy cập được.

Khi khách mở giỏ hàng cũ, những sản phẩm vừa trở nên không khả dụng sẽ bị gỡ khỏi giỏ và hiển thị thông báo. Khi thanh toán, quy tắc trên được kiểm tra lại bên trong giao dịch tạo đơn hàng.

## 3. Admin → Products

Bộ lọc gồm từ khóa, Brand, Category, trạng thái thực tế (Visible/Hidden/Product inactive/Brand inactive/Category inactive), tồn kho (hết hàng 0, ít hàng 1–5, trên 5) và sắp xếp theo giá/tồn kho/tên. Các bộ lọc giữ nguyên khi chuyển trang.

Trong cột trạng thái, quản trị viên thấy rõ lý do sản phẩm bị ẩn. Bảng sản phẩm có nút **Adjust** gồm `+ Add` và `− Remove` theo số lượng. Điều chỉnh được thực hiện bằng câu lệnh cập nhật có điều kiện trong một transaction để ngăn số lượng âm hoặc hai thao tác làm mất cập nhật.

Khi chỉnh sửa thông tin sản phẩm, tồn kho là trường chỉ đọc: lưu giá, tên, mô tả, hình ảnh, Brand hay Category không ghi đè số lượng vừa được bán. Chỉ thao tác Adjust mới thay đổi lượng tồn quản trị. Xóa sản phẩm dùng POST, không dùng GET; không cho xóa sản phẩm đã có lịch sử đơn hàng.

## 4. Admin → Dashboard

Dashboard hiển thị:

- Doanh thu đơn Completed và số lượng sản phẩm đã bán; không tính đơn đang Pending, Confirmed, Shipping hoặc Cancelled.
- Tổng số lượng tồn thực tế của tất cả sản phẩm; lượng còn bán được của những sản phẩm được hiển thị; giá trị hàng tồn theo giá bán hiện tại (không phải giá vốn).
- Số sản phẩm đang bán, đang ẩn, hết hàng, sắp hết hàng, cảnh báo tối đa 8 sản phẩm.
- Luồng đơn Pending → Confirmed → Shipping → Completed và số lượng Cancelled; từng nhóm có liên kết lọc danh sách đơn.
- Bảng MAX/MIN/AVG/SUM/COUNT qua JPA; giá sản phẩm chỉ thống kê trên nhóm hiển thị. Có giá trị trung bình mỗi đơn đã hoàn tất.
- Doanh thu Completed theo sáu tháng gần nhất và năm đơn gần đây.

## 5. Luồng kho và đơn hàng

- Khách thêm giỏ: chưa giảm tồn kho.
- Checkout thành công: trừ hàng một lần trong cùng giao dịch tạo đơn; trạng thái Pending.
- Pending → Confirmed → Shipping → Completed: không trừ thêm hàng; Completed mới ghi nhận doanh thu bán hàng.
- Hủy ở Pending hoặc Confirmed: cộng lại đúng số lượng một lần.
- Shipping không được chuyển trực tiếp sang Cancelled để tránh hoàn kho khi hàng còn đang vận chuyển. Completed và Cancelled là trạng thái cuối. Trường hợp trả hàng sau vận chuyển cần nhân viên xác nhận đã nhận lại hàng và dùng Adjust Stock; không tự động ghi nhận hàng hoàn là đã về kho.

## 6. Admin → Users và chức năng Forgot Password

Đã bỏ nút Recovery Code trên danh sách Users và endpoint cấp lại mã thủ công của admin. Khách sử dụng Forgot Password với username và email đúng trong database local để đặt mật khẩu mới. Không dùng SMTP hoặc mã khôi phục.

## 7. Kiểm tra

Đã biên dịch các lớp Java liên quan với Java 17. Kiểm thử tích hợp trên HSQLDB gồm:

- 49 kiểm tra về trạng thái Brand/Category, truy vấn công khai, thống kê, điều chỉnh kho và chuyển trạng thái đơn.
- 18 kiểm tra điều hướng và thao tác Admin Products, Dashboard, Orders và Users.
- 31 kiểm tra nội dung và phân quyền Q&A.
- 11 kiểm tra luồng Servlet Q&A.

**Tổng cộng: 109/109 kiểm tra đạt.** Đây là kiểm thử trên cơ sở dữ liệu thử nghiệm và các Servlet giả lập, không thay thế chạy giao diện JSP trên Tomcat 10.1 kết nối SQL Server thật. Cần kiểm tra trực tiếp trong NetBeans theo hướng dẫn dưới đây.

## 8. Kiểm tra nhanh sau khi mở NetBeans

1. Mở project có `pom.xml`, dùng JDK 17 và Tomcat 10.1, kết nối SQL Server theo `HUONG_DAN_NETBEANS.md`.
2. Trong Admin → Brands, chuyển Apple sang Inactive. Trên trang khách tìm `iPhone`, thử URL sản phẩm cũ, kiểm tra các nhóm gợi ý và giỏ hàng: sản phẩm Apple không được bán hoặc hiển thị. Bật Apple Active và kiểm tra sản phẩm xuất hiện lại.
3. Tương tự cho một Category; kiểm tra Admin → Products → Visibility → Brand inactive/Category inactive.
4. Chọn một sản phẩm có số lượng 10. Đặt mua 1, kiểm tra còn 9 trong Admin → Products. Chuyển trạng thái tới Completed: số lượng vẫn 9. Kiểm tra doanh thu Completed và Units Sold trên Dashboard.
5. Đặt đơn khác và hủy ở Pending: số lượng được hoàn lại. Thử hủy khi Shipping phải bị từ chối.
6. Mở Edit Product từ trước khi khách đặt hàng, cập nhật tên/giá sau khi có đơn. Stock không bị ghi đè. Dùng Adjust +/− để điều chỉnh tồn kho.
7. Kiểm tra MAX, MIN, AVG, SUM, COUNT; lọc danh sách Admin Products theo từ khóa, Brand, Category, Visibility, Stock; chuyển trang rồi kiểm tra bộ lọc vẫn còn.
8. Trong Admin → Users, xác nhận không còn nút Recovery Code; ở trang khách vẫn có Forgot Password. Kiểm thử Q&A và quyền admin/customer.

Không cần chạy `database.sql` lại trên database cũ khi chỉ nâng cấp từ phiên bản Group 2 UX-QA sang bản này.
