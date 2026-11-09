# Smart Mobile Shop – Java Web + JPA + SQL Server

Dự án website bán điện thoại sử dụng Java Servlet, JSP/JSTL, EclipseLink JPA và Microsoft SQL Server. Mã nguồn tổ chức theo mô hình MVC với Servlet Controller, Entity, DAO, JSP. Hệ thống hỗ trợ giao diện sản phẩm, giỏ hàng, đơn hàng, trang quản trị, thống kê và hỏi đáp sản phẩm có kiểm duyệt.

## Bắt đầu

Xem **`HUONG_DAN_NETBEANS.md`** để cài đặt SQL Server, mở dự án Maven trong NetBeans, cấu hình Tomcat 10.1 và thử nghiệm tất cả module.

## Các file chính

- `pom.xml`: cấu hình Maven WAR, Java 17, EclipseLink.
- `src/java/model`, `src/java/dao`, `src/java/controller`: Entity, logic truy vấn JPA, Servlet.
- `src/conf/META-INF/persistence.xml`: cấu hình đơn vị persistence và SQL Server.
- `web`: JSP, CSS, thư viện giao diện và thư viện JDBC driver được dùng *bên trong JPA*.
- `database.sql`: cài mới database cùng dữ liệu mẫu (xóa dữ liệu cũ).
- `database_clean.sql`: cài mới schema và admin, không có dữ liệu demo sản phẩm.
- `migration_existing.sql`: nâng cấp database cũ, không xóa dữ liệu đang có.
- Quên mật khẩu: xác nhận username và email trong dữ liệu local, sau đó đặt mật khẩu mới.
- `dist/SmartMobileShop.war`: gói triển khai lên Tomcat 10.x.

## Build

Mở thư mục chứa `pom.xml` trong NetBeans hoặc chạy `mvn clean package` trên máy có Maven. Kết quả Maven nằm tại `target/SmartMobileShop.war`.

Mã truy vấn dữ liệu sử dụng Java Persistence API (`EntityManager`, JPQL), không gọi JDBC trực tiếp trong DAO. EclipseLink là một triển khai JPA được phép sử dụng trong đề PRJ301.
