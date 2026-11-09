# BÁO CÁO ĐỐI CHIẾU VÀ KIỂM THỬ PRJ301

## Đối chiếu tính năng

| Mục | Chức năng đã triển khai | Trạng thái mã nguồn |
|---|---|---|
| 3.1 | Đăng ký, đăng nhập, đăng xuất, đặt lại mật khẩu bằng mã khôi phục, cập nhật profile, thay đổi mật khẩu, role Admin/Customer và lọc quyền truy cập | Đã triển khai |
| 3.2 | Dữ liệu từ DB, nhóm sản phẩm mới/nổi bật/bán chạy, tìm kiếm đa trường, lọc thương hiệu/danh mục/giá, sắp xếp, phân trang, chi tiết và gợi ý sản phẩm | Đã triển khai |
| 3.3 | CRUD sản phẩm, thương hiệu, danh mục, tài khoản, đơn hàng (chỉ xóa đơn đã hủy) | Đã triển khai |
| 3.5 | COUNT, MIN, MAX, AVG, SUM qua JPQL và giao diện Dashboard | Đã triển khai |
| 3.6 | Thêm, sửa số lượng, xóa giỏ hàng, tính tiền, đặt đơn có kiểm tra tồn kho | Đã triển khai |
| 3.7 | Java Servlet + EclipseLink (JPA 3.1), EntityManager/JPQL, SQL Server | Đã triển khai |
| 3.8 | Hỏi/đáp sản phẩm, kiểm duyệt câu hỏi và câu trả lời, duyệt/từ chối/xóa từ Admin | Đã triển khai |

## Kiểm thử tự động

- Biên dịch thành công **40 tệp nguồn Java** với tùy chọn `--release 17`.
- Kiểm tra các cấu hình XML hợp lệ: `pom.xml`, `nb-configuration.xml`, `web.xml`, `context.xml`, `persistence.xml`.
- Kiểm chứng băm mật khẩu và mã khôi phục của các tài khoản SQL mẫu.
- **62/62** trường hợp kiểm thử tích hợp thành công với JPA và HSQLDB thử nghiệm, bao gồm đăng nhập, đổi/reset mật khẩu, CRUD, tìm kiếm, thống kê, Q&A, giỏ hàng và hủy đơn/hoàn kho.
- File `dist/SmartMobileShop.war` đóng gói đúng servlet, JSP, Entity/JPA, các thư viện runtime và cấu hình persistence.

## Phạm vi chưa xác minh trong máy thử nghiệm

- Chưa chạy thực tế với Microsoft SQL Server và Apache Tomcat 10.1; cần kiểm thử tại máy triển khai.
- Khi kiểm thử bằng HSQLDB 1.8, riêng mã nghiệp vụ khóa bi quan `PESSIMISTIC_WRITE` được thay bằng phiên bản không khóa trong bản class tạm để tương thích dialect HSQLDB. **Bản mã nguồn và WAR bàn giao luôn giữ nguyên mã khóa bi quan dành cho SQL Server.**
- JSP được kiểm tra về cấu trúc và các tuyến Servlet liên quan; chưa được JSP compiler của Tomcat biên dịch trong môi trường thử nghiệm.

Xem `HUONG_DAN_NETBEANS.md` để cài đặt môi trường và thực hiện các bước demo trên NetBeans.

## Cập nhật giao diện và lịch sử Q&A (05/11/2026)

Đã cập nhật thứ tự hiển thị sản phẩm, điều hướng bộ lọc, footer, trang lịch sử người dùng và trang hội thoại dành cho Admin. Tham khảo `CAP_NHAT_GIAO_DIEN_QA.md` để xem luồng thao tác.

Trong lần cập nhật này, 31 trường hợp kiểm tra tích hợp Q&A và 11 trường hợp kiểm tra điều hướng Servlet đã chạy thành công trên cơ sở dữ liệu thử nghiệm. Các lớp Java có thay đổi đã được biên dịch với Java 17. Kết quả 62/62 ở phần trên thuộc lần kiểm thử của bản bàn giao trước, không phải kết quả chạy lại toàn bộ trong lần cập nhật này.

Việc triển khai trực tiếp trên SQL Server/Tomcat và quá trình biên dịch JSP bằng Jasper vẫn cần được xác nhận trong môi trường NetBeans của người sử dụng.
