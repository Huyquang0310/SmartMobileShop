# SMART MOBILE SHOP – HƯỚNG DẪN CÀI ĐẶT VÀ CHẠY TRÊN NETBEANS

## 1. Công nghệ và cấu trúc dự án

- JDK: **17** (hoặc bản Java mới hơn tương thích với NetBeans và Tomcat).
- NetBeans: phiên bản có hỗ trợ Maven Web Application, ví dụ Apache NetBeans 20 trở lên.
- Application server: **Apache Tomcat 10.1** (có thể dùng Tomcat 10.0). **Không dùng Tomcat 9** vì dự án sử dụng `jakarta.servlet.*`.
- Cơ sở dữ liệu: Microsoft SQL Server, quản lý bằng SQL Server Management Studio (SSMS) hoặc công cụ SQL tương đương.
- Backend: Java Servlet, EclipseLink 4.0.8, JPA 3.1 (EntityManager/JPQL), Maven WAR.
- Giao diện: JSP, JSTL, Bootstrap 5.
- Tên database: `SmartMobileShop`. Cổng SQL Server mặc định: TCP `1433`.

Thư mục chứa `pom.xml` là thư mục gốc của dự án, cần mở trực tiếp trong NetBeans. Thư mục `legacy-ant-config` chỉ là cấu hình cũ, không mở thư mục đó để chạy.

## 2. Tạo cơ sở dữ liệu bằng SQL Server

### Cài đặt mới có dữ liệu demo

1. Khởi động SQL Server, bật TCP/IP trong SQL Server Configuration Manager nếu cần. Kiểm tra instance lắng nghe cổng 1433; khởi động lại dịch vụ SQL Server sau khi đổi cấu hình mạng.
2. Đăng nhập SQL Server bằng SSMS với tài khoản có quyền tạo database và bảng.
3. Mở file **`database.sql`** từ dự án, nhấn **Execute**. Script tự tạo database `SmartMobileShop`, schema, sản phẩm, tài khoản, đơn hàng và dữ liệu hỏi đáp mẫu.
4. Kiểm tra **Databases → SmartMobileShop → Tables**: phải có `Roles`, `Users`, `Brands`, `Categories`, `Products`, `Orders`, `OrderDetails`, `Questions`, `Answers`.

**Cảnh báo:** `database.sql` có lệnh DROP các bảng cũ để cài đặt lại. Chỉ chạy nếu muốn làm mới toàn bộ dữ liệu; không chạy lại trên database đã nhập đơn hàng thật.

### Giữ dữ liệu của bản dự án cũ

Nếu đã có database từ phiên bản cũ và muốn giữ dữ liệu, sao lưu database trước, sau đó chạy **`migration_existing.sql`**. Script này bổ sung bảng `Questions`, bảng `Answers` và các index cần thiết, không xóa dữ liệu cũ. Mật khẩu cũ sẽ được chuyển sang dạng băm khi đăng nhập lần đầu. Quên mật khẩu được kiểm tra tại local bằng username + email đã đăng ký; không cần SMTP.

File `database_clean.sql` dùng để tạo schema sạch và tài khoản admin, không có danh sách sản phẩm/đơn hàng mẫu. Trong phần trình diễn nên dùng `database.sql`.

## 3. Cấu hình kết nối SQL Server

Mở `src/conf/META-INF/persistence.xml`. Mặc định là:

```text
Database: SmartMobileShop
Server: localhost
Port: 1433
SQL Login: sa
Password: trống, sẽ đọc từ cấu hình runtime nếu được cung cấp
```

Cần cung cấp mật khẩu của SQL Login. Có hai cách:

**Cách đơn giản khi chạy trên máy học tập:** Sửa thuộc tính này trong `persistence.xml` thành mật khẩu SQL Server trên máy của bạn:

```xml
<property name="jakarta.persistence.jdbc.password" value="MAT_KHAU_SQL_SERVER_CUA_BAN"/>
```

Sửa `jakarta.persistence.jdbc.user` nếu không dùng `sa`. Sửa URL nếu SQL Server không chạy ở `localhost:1433` hoặc database có tên khác. Sau khi sửa, chạy **Clean and Build** lại để cấu hình mới được đóng gói. Không chia sẻ file chứa mật khẩu thật.

**Cách không ghi mật khẩu vào project:** Giữ trường password là chuỗi rỗng và truyền JVM option vào Tomcat:

```text
-Dsmartshop.db.password=MAT_KHAU_SQL_SERVER_CUA_BAN
```

Có thể sử dụng biến môi trường `SMARTSHOP_DB_PASSWORD` trong tiến trình khởi động Tomcat. Các biến môi trường khác được hỗ trợ: `SMARTSHOP_DB_USER`, `SMARTSHOP_DB_URL`, `SMARTSHOP_DB_DRIVER`, `SMARTSHOP_DB_PLATFORM`. Nếu dùng tài khoản SQL khác `sa`, thay `SMARTSHOP_DB_USER` cho phù hợp. JVM options có dạng `smartshop.db.user`, `smartshop.db.url`, ...

SQL Server cần cho phép **SQL Server Authentication**, nếu kết nối bằng `sa`. Nếu kết nối thất bại, kiểm tra tên instance, port, SQL Login, mật khẩu, quyền vào database và Windows Firewall.

## 4. Mở dự án trong Apache NetBeans

1. Giải nén file ZIP. Mở thư mục **`SmartMobileShop-JPA`**; bên trong phải có `pom.xml`, `src`, `web`, `database.sql`.
2. Mở **Apache NetBeans** và chọn **File → Open Project**.
3. Chọn **thư mục chứa `pom.xml`**, không chọn riêng thư mục `src`, `web`, `target` hoặc `legacy-ant-config`.
4. Chờ NetBeans nhận diện dự án Maven và giải quyết dependency. Nếu được hỏi có tải dependency hay không, cho phép Maven tải (cần Internet cho lần tải Maven đầu tiên).
5. Chọn JDK 17 trong **Tools → Java Platforms** nếu IDE chưa nhận; bảo đảm NetBeans và Maven chạy bằng JDK tương thích.
6. Đăng ký Tomcat bằng **Tools → Servers → Add Server**, chọn Apache Tomcat, trỏ đến thư mục Tomcat 10.1 và cung cấp thông tin quản trị nếu IDE yêu cầu. Trên một số bản NetBeans, phần đăng ký server nằm trong **Services → Servers**.
7. Bấm chuột phải vào dự án → **Properties → Run**, chọn server **Apache Tomcat 10.1**, context path `/SmartMobileShop`.
8. Bấm chuột phải vào dự án → **Clean and Build**. Khi thông báo `BUILD SUCCESS`, chọn **Run Project** (phím F6) để chạy trên Tomcat.
9. Mở trình duyệt: **http://localhost:8080/SmartMobileShop/** hoặc **http://localhost:8080/SmartMobileShop/home**.

Nếu NetBeans không hiển thị được nút Run, kiểm tra server đã đăng ký trong Properties → Run và project được nhận dạng là Maven WAR (`<packaging>war</packaging>`).

### Dùng file WAR có sẵn

Thư mục `dist/SmartMobileShop.war` chứa bản deploy đã đóng gói. Bạn có thể sao chép file này vào `webapps` của Tomcat 10.1 và khởi động server, sau đó truy cập URL như trên. Nếu chọn cấu hình password bằng cách sửa `persistence.xml` trong source, phải build lại WAR; file WAR đi kèm chỉ sử dụng password runtime.

## 5. Tài khoản mẫu và khôi phục mật khẩu

Khi chạy `database.sql`:

| Vai trò | Tài khoản | Mật khẩu |
|---|---|---|
| Admin | `admin` | `admin123` |
| Customer | `john` | `123456` |
| Customer | `jane` | `123456` |
| Customer | `mike` | `123456` |

Mật khẩu trong database được lưu dưới dạng băm PBKDF2, không lưu trực tiếp các chuỗi trên. Đây là **tài khoản minh họa**, cần đổi mật khẩu nếu sử dụng bên ngoài môi trường học tập.

Để thử chức năng **Forgot password?** trong dự án local: nhập chính xác **username** và **email** đã đăng ký; sau đó nhập mật khẩu mới hai lần. Không cần email thật, SMTP hoặc mã khôi phục. Sau khi đặt lại thành công, đăng nhập bằng mật khẩu mới. Bước xác nhận chỉ có hiệu lực 5 phút trong phiên trình duyệt.

## 6. Hướng dẫn kiểm tra các yêu cầu PRJ301

| Mục đề bài | Cách kiểm tra |
|---|---|
| 3.1 Xác thực | Đăng ký; đăng nhập/logout; quên/đổi mật khẩu; cập nhật profile; tạo/sửa vai trò tài khoản; thử truy cập `/admin/dashboard` bằng tài khoản Customer |
| 3.2 Home | Kiểm tra Featured, New Arrivals, Best Sellers; tìm theo tên/hãng/danh mục; lọc hãng/danh mục/giá; sắp xếp tên/giá; chuyển trang; xem chi tiết và sản phẩm liên quan |
| 3.3 CRUD | Admin quản lý Products, Brands, Categories, Users, Orders; thêm/sửa/xóa một sản phẩm mới; cập nhật/hủy hoặc xóa đơn đã hủy |
| 3.5 Thống kê | Admin → Dashboard → Sales & Inventory Report: `COUNT`, `MIN`, `MAX`, `AVG`, `SUM`, dữ liệu lấy bằng JPQL/JPA |
| 3.6 Giỏ hàng | Thêm sản phẩm, thay đổi số lượng, xóa sản phẩm, xem tổng tiền; kiểm tra tồn kho và tạo đơn |
| 3.7 JPA | Kiểm tra `persistence.xml`, các Entity trong `model`, DAO dùng `EntityManager`, không dùng JDBC thủ công trong mã DAO |
| 3.8 Q&A | Customer vào Product Details → đặt câu hỏi; Admin vào Q&A → Approve; Customer khác đăng nhập → trả lời; Admin duyệt câu trả lời; thử Reject/Delete |

### Trình tự demo nên thực hiện

1. Đăng nhập Admin, xem dashboard và quản lý sản phẩm/danh mục.
2. Đăng xuất, đăng nhập `john`, lọc sản phẩm và thêm vào giỏ.
3. Đặt đơn và xem lịch sử; đăng nhập Admin chuyển trạng thái đơn, xem báo cáo thống kê.
4. Đăng nhập Customer đặt câu hỏi sản phẩm; Admin duyệt câu hỏi; đăng nhập Customer khác trả lời; Admin duyệt câu trả lời.
5. Thử quên mật khẩu bằng mã khôi phục, đổi mật khẩu và đăng nhập lại.

## 7. Khắc phục sự cố

- **`ClassNotFoundException: jakarta.servlet...`**: đang dùng Tomcat 9 hoặc server cũ. Cần Tomcat 10.x.
- **`Login failed for user 'sa'`**: sai mật khẩu SQL Login, SQL Server chưa bật chế độ Mixed Mode, hoặc account đang bị vô hiệu hóa.
- **`Connection refused` / `TCP/IP connection ... failed`**: kiểm tra SQL Server TCP/IP, port, Firewall, instance và JDBC URL.
- **`Invalid object name 'Questions'`**: chưa chạy `database.sql` hoặc `migration_existing.sql` trên đúng database.
- **Trang chủ không có dữ liệu**: kiểm tra có chạy file `database.sql` (có seed sản phẩm), và đăng nhập vào đúng database.
- **`Could not find or load persistence unit SmartMobileShopPU`**: kiểm tra `src/conf/META-INF/persistence.xml` được đóng gói vào `WEB-INF/classes/META-INF/persistence.xml`, Clean and Build lại.
- **Lỗi thư viện Maven ở lần đầu**: kiểm tra mạng, mở project Maven tại đúng `pom.xml`, dùng chức năng Reload Project rồi Clean and Build.
- **Port 8080 đang bị sử dụng**: đổi HTTP Connector trong cấu hình Tomcat, sau đó truy cập port mới.
- **404 khi truy cập**: kiểm tra context path hiện tại trong NetBeans (có thể khác `/SmartMobileShop`).

## 8. Trạng thái kiểm thử

- Đã biên dịch toàn bộ 40 tệp Java trên JDK 17 với các thư viện tương thích; không có lỗi biên dịch.
- Đã xác minh cấu trúc XML, thông tin mẫu và mã khôi phục tương ứng hash trong SQL.
- Đã thực hiện 62 bài kiểm thử JPA/nghiệp vụ trên database thử nghiệm HSQLDB; các nhóm xác thực, CRUD, tìm kiếm, giỏ hàng, thống kê, Q&A, hủy đơn/hoàn kho đều thành công.
- **Chưa xác minh chạy trực tiếp trên SQL Server + Tomcat thực tế trong môi trường này.** Phần ghi-lock hàng tồn kho khi đặt/hủy đơn dùng `PESSIMISTIC_WRITE` phải được kiểm tra bổ sung trên SQL Server của máy triển khai. Bài kiểm thử dùng HSQLDB cũ nên thay cơ chế khóa bằng phiên bản không khóa *chỉ trong bộ mã biên dịch thử*, không chỉnh sửa mã dự án bàn giao.

Để xác nhận hoạt động trên máy của bạn, hãy thực hiện đầy đủ các bước cài đặt và kịch bản demo ở mục 6.
