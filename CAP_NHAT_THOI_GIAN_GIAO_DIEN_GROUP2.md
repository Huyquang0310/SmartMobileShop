# Smart Mobile Shop – Group 2: Order Date & Home UI

## Thời gian đặt hàng

- `Order` ghi thời gian khi đơn được tạo (`@PrePersist`). Trường `order_date` không được cập nhật khi đổi trạng thái đơn.
- `database.sql` và `database_clean.sql` đặt `order_date` là `NOT NULL` và có giá trị mặc định từ SQL Server.
- Nếu dùng database cũ, chạy `migration_order_dates.sql` trong SSMS để bổ sung mặc định cho các đơn mới mà **không xóa hoặc ghi đè dữ liệu**.
- Những đơn cũ đã có `order_date = NULL` không thể khôi phục chính xác thời điểm tạo nếu không có nguồn lịch sử; giao diện hiển thị `Not recorded` thay vì tự tạo ngày sai.
- Trang Orders, Recent Orders, lịch sử và chi tiết đơn đều hiển thị ngày và giờ.

## Giao diện Home

- `All Products` vẫn đặt đầu trang, bộ lọc nằm sát danh sách sản phẩm.
- Bố cục mới có thẻ sản phẩm đồng bộ, thông tin giá và trạng thái rõ ràng, thanh lọc dễ dùng trên máy tính và điện thoại; trên thiết bị nhỏ bộ lọc thu gọn mặc định để ưu tiên kết quả.
- Các nhóm Featured, New Arrivals, Best Sellers nằm bên dưới danh sách chung, chỉ tải khi không áp dụng bộ lọc.
- Không thêm các banner giới thiệu dài hoặc liên kết `Browse all products` dư thừa.
- Dashboard rút gọn các đoạn chú thích dài.

## Kiểm tra

1. Tạo một đơn mới, sau đó mở Admin → Orders: cột Placed At phải có đầy đủ ngày giờ.
2. Đổi Pending → Confirmed → Shipping → Completed: thời gian đặt hàng phải được giữ nguyên.
3. Kiểm tra Order History, Order Detail và Recent Orders.
4. Kiểm tra Home trên màn hình lớn, máy tính bảng và điện thoại; thử tìm kiếm, lọc, phân trang và xóa bộ lọc.
5. Với dữ liệu cũ, chạy `SELECT order_id, order_date FROM dbo.Orders WHERE order_date IS NULL` để kiểm tra các đơn thiếu thời gian. Không gán thời gian hiện tại cho các đơn cũ vì sẽ làm sai lịch sử.
