# CẬP NHẬT GIAO DIỆN VÀ HỎI ĐÁP – SMART MOBILE SHOP

## Nội dung cập nhật

1. Footer hiển thị một dòng: **Smart Mobile Shop - Group 2**.
2. Xóa phần giới thiệu "Find your next smartphone" và dòng mô tả bên dưới.
3. Danh sách **All Products** nằm trên các nhóm sản phẩm gợi ý. Featured Phones, New Arrivals và Best Sellers chỉ hiển thị dưới danh sách trong trang chủ mặc định. Khi người dùng tìm kiếm, lọc, sắp xếp hay chuyển sang trang khác, nội dung gợi ý được ẩn để tập trung vào kết quả. Các liên kết "Browse all products" trùng chức năng đã được bỏ.
4. Bộ lọc và phân trang tự chuyển đến khu vực **All Products** bằng liên kết neo `#all-products`; thuận tiện cả trên màn hình điện thoại.
5. Trang chi tiết sản phẩm hiển thị câu hỏi đã duyệt cho mọi người, đồng thời cho người đăng thấy câu hỏi và câu trả lời đang chờ duyệt hoặc bị từ chối của chính họ. Nội dung chưa duyệt của người khác không hiển thị công khai.
6. Thêm trang **My Q&A** tại `/my-qa`, có thể truy cập từ menu tài khoản hoặc trang hồ sơ. Trang hiển thị lịch sử câu hỏi do người dùng đặt và những cuộc thảo luận họ đã tham gia, kèm trạng thái từng câu hỏi/câu trả lời. Có thể tiếp tục trả lời những cuộc thảo luận đã được duyệt.
7. Trang quản trị `/admin/qa` chuyển thành danh sách các cuộc trao đổi, tập hợp từng câu hỏi và tất cả câu trả lời đúng luồng. Admin xem được cả nội dung chưa duyệt, trả lời trực tiếp, duyệt, từ chối, xóa câu hỏi hoặc câu trả lời. Có chế độ **Needs Review** lọc các luồng còn nội dung chờ duyệt.
8. Thêm lối tắt Q&A ở trang Dashboard quản trị.
9. Khi khách cần đăng nhập để hỏi đáp, trang đăng nhập duy trì đường dẫn trở lại đúng sản phẩm và khu vực Q&A.

## Phân quyền nội dung hỏi đáp

| Người xem | Câu hỏi | Câu trả lời |
|---|---|---|
| Khách chưa đăng nhập | Chỉ Approved | Chỉ Approved của câu hỏi Approved |
| Người dùng đã đăng nhập | Approved và câu hỏi của chính mình | Approved và câu trả lời của chính mình trong các cuộc hội thoại được phép xem |
| Admin | Tất cả trạng thái | Tất cả trạng thái |

Admin trả lời trực tiếp được duyệt ngay; nếu câu hỏi gốc chưa được duyệt, cuộc hội thoại vẫn không công khai cho đến khi câu hỏi được duyệt.

## Cách mở trong NetBeans

1. Giải nén ZIP, chọn **File > Open Project** trong NetBeans và mở thư mục `SmartMobileShop-JPA` có `pom.xml`.
2. Sử dụng JDK 17 và Apache Tomcat 10.1.
3. Chuẩn bị database SQL Server theo `HUONG_DAN_NETBEANS.md`. Nếu đang có dữ liệu, không chạy lại `database.sql` vì tệp này dùng để tạo mới dữ liệu mẫu; thay đổi giao diện/Q&A lần này **không yêu cầu migration mới**.
4. Vào **Clean and Build**, sau đó **Run Project**. Địa chỉ mặc định là `http://localhost:8080/SmartMobileShop/`.
5. Dùng tài khoản Admin và Customer có trong tài liệu hướng dẫn để kiểm tra hai góc nhìn.

## Quy trình kiểm tra đề xuất

1. Vào trang chủ, xác nhận **All Products** ở đầu trang; các nhóm sản phẩm gợi ý nằm dưới.
2. Chọn bộ lọc/sắp xếp, xác nhận kết quả xuất hiện ngay tại **All Products**; đổi trang mà vẫn giữ điều kiện lọc.
3. Đăng nhập Customer, đăng câu hỏi và kiểm tra nội dung Pending tại trang sản phẩm và **My Q&A**.
4. Đăng nhập Admin, mở **Dashboard > Q&A Conversations > Needs Review**, duyệt hoặc trả lời câu hỏi.
5. Quay lại Customer, xem lịch sử và câu trả lời của Admin; phản hồi tiếp, kiểm tra trạng thái Pending.
6. Duyệt câu trả lời của Customer trong Admin; mở sản phẩm ở chế độ khách chưa đăng nhập để xác nhận chỉ có nội dung Approved.
7. Kiểm tra thao tác từ chối/xóa ở Admin; theo dõi thay đổi trong **My Q&A**.
8. Kiểm tra lại giỏ hàng, đặt hàng, CRUD và thống kê của bản trước.

## Kiểm thử được thực hiện

- Biên dịch các lớp Java được bổ sung/sửa đổi với tùy chọn `--release 17` bằng thư viện JPA từ WAR cũ và bộ kiểu Servlet tương thích dùng riêng cho bước kiểm tra biên dịch.
- 31 bài kiểm tra truy vấn và nghiệp vụ hỏi đáp tích hợp JPA với HSQLDB thử nghiệm.
- 11 bài kiểm tra luồng Servlet, chuyển hướng, phân quyền và trạng thái trên giao diện quản trị/khách hàng sử dụng request/response giả lập.
- Kiểm tra sự hiện diện các trang JSP, tuyến Servlet mới và dữ liệu WAR sau đóng gói.

Chưa thể kiểm thử trực tiếp trên SQL Server và Tomcat 10.1 tại môi trường này. Cần chạy lại kiểm tra giao diện trong NetBeans với máy chủ ứng dụng thực tế trước khi nộp.
