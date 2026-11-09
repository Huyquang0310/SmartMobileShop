-- =====================================================
-- Smart Mobile Shop Database Script for SQL Server
-- Version: 2.0 - Complete with Image URLs
-- Description: Full database with realistic sample data
-- Database Name: SmartMobileShop
-- =====================================================

-- Create database if not exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SmartMobileShop')
BEGIN
    CREATE DATABASE SmartMobileShop;
    PRINT 'Database SmartMobileShop created successfully';
END
ELSE
BEGIN
    PRINT 'Database SmartMobileShop already exists';
END
GO

-- Use the database
USE SmartMobileShop;
GO

-- Drop existing tables if they exist
IF OBJECT_ID('Answers', 'U') IS NOT NULL DROP TABLE Answers;
IF OBJECT_ID('Questions', 'U') IS NOT NULL DROP TABLE Questions;
IF OBJECT_ID('OrderDetails', 'U') IS NOT NULL DROP TABLE OrderDetails;
IF OBJECT_ID('Orders', 'U') IS NOT NULL DROP TABLE Orders;
IF OBJECT_ID('Products', 'U') IS NOT NULL DROP TABLE Products;
IF OBJECT_ID('Categories', 'U') IS NOT NULL DROP TABLE Categories;
IF OBJECT_ID('Brands', 'U') IS NOT NULL DROP TABLE Brands;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
IF OBJECT_ID('Roles', 'U') IS NOT NULL DROP TABLE Roles;

-- =====================================================
-- CREATE TABLES
-- =====================================================

-- Create Roles table
CREATE TABLE Roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL UNIQUE
);

-- Create Users table
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    password NVARCHAR(500) NOT NULL,
    phone NVARCHAR(20),
    address NVARCHAR(255),
    role_id INT NOT NULL,
    status BIT DEFAULT 1,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

-- Create Brands table
CREATE TABLE Brands (
    brand_id INT IDENTITY(1,1) PRIMARY KEY,
    brand_name NVARCHAR(100) NOT NULL UNIQUE,
    status BIT DEFAULT 1
);

-- Create Categories table
CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL UNIQUE,
    status BIT DEFAULT 1
);

-- Create Products table
CREATE TABLE Products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_name NVARCHAR(200) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    description NTEXT,
    image_url NVARCHAR(500),  -- Increased for URLs
    ram NVARCHAR(20),
    rom NVARCHAR(20),
    screen NVARCHAR(50),
    battery NVARCHAR(20),
    status BIT DEFAULT 1,
    FOREIGN KEY (brand_id) REFERENCES Brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Create Orders table
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    receiver_name NVARCHAR(100) NOT NULL,
    receiver_phone NVARCHAR(20) NOT NULL,
    receiver_address NVARCHAR(255) NOT NULL,
    note NVARCHAR(500),
    order_date DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    total_amount DECIMAL(10,2) NOT NULL,
    status NVARCHAR(20) DEFAULT 'Pending'
        CHECK (status IN ('Pending', 'Confirmed', 'Shipping', 'Completed', 'Cancelled')),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Create OrderDetails table
CREATE TABLE OrderDetails (
    detail_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Questions (
    question_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    content NVARCHAR(2000) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Answers (
    answer_id INT IDENTITY(1,1) PRIMARY KEY,
    question_id INT NOT NULL,
    user_id INT NOT NULL,
    content NVARCHAR(2000) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    FOREIGN KEY (question_id) REFERENCES Questions(question_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE INDEX IX_Questions_Product_Status ON Questions(product_id, status);
CREATE INDEX IX_Answers_Question_Status ON Answers(question_id, status);

-- =====================================================
-- INSERT SAMPLE DATA
-- =====================================================

-- Insert Roles
INSERT INTO Roles (role_name) VALUES 
('Admin'), 
('Customer');

-- Insert demo accounts with hashed credentials
INSERT INTO Users (full_name, username, email, password, phone, address, role_id, status) VALUES
('Administrator', 'admin', 'admin@mobileshop.com', 'pbkdf2:180000:fJ+H1e/102//AtjEiuGIgA==:hi9hK1uDGm852u+OBGnhyV15C/qXpHqfW6SLJ4cQhGQ=', '0123456789', 'Admin Office, District 1, Ho Chi Minh City', 1, 1),
('John Doe', 'john', 'john@email.com', 'pbkdf2:180000:kPiwEPh06EWSNTybP6C30w==:r5OKW0IdNfupor0wrhHUIOox1OzLG5M/BSQqUOTYlPI=', '0987654321', '123 Main Street, District 3, Ho Chi Minh City', 2, 1),
('Jane Smith', 'jane', 'jane@email.com', 'pbkdf2:180000:vX9Ew/vizOAPEcd4ntULOQ==:ObuZwYCyJJ4X4cktSbVDZDDWn5AXzEDNSpDkgXYCBlA=', '0912345678', '456 Oak Avenue, District 7, Ho Chi Minh City', 2, 1),
('Mike Johnson', 'mike', 'mike@email.com', 'pbkdf2:180000:sEw5QBRy2I3Syh5Hbpbv8A==:CM9xRld4Bzodk/iXCDQN+R27Pai8Bs6uTg3QT6um/aY=', '0923456789', '789 Pine Road, Binh Thanh District, Ho Chi Minh City', 2, 1);

-- Insert Brands
INSERT INTO Brands (brand_name, status) VALUES
('Apple', 1),
('Samsung', 1),
('Xiaomi', 1),
('Oppo', 1),
('Vivo', 1),
('Realme', 1),
('OnePlus', 1),
('Google', 1),
('Nokia', 1),
('Motorola', 1);

-- Insert Categories
INSERT INTO Categories (category_name, status) VALUES
('Flagship', 1),
('Mid-Range', 1),
('Budget', 1),
('Gaming', 1),
('Camera Phone', 1);

-- Insert Products with Image URLs
-- Using placeholder images from various sources
INSERT INTO Products (product_name, brand_id, category_id, price, quantity, description, image_url, ram, rom, screen, battery, status) VALUES
-- Apple Products
('iPhone 15 Pro Max', 1, 1, 1199.99, 50, 'The ultimate iPhone with titanium design, A17 Pro chip, and advanced camera system. Features ProMotion display and Action button.', 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=500', '8GB', '256GB', '6.7 inch OLED', '4422mAh', 1),
('iPhone 15 Pro', 1, 1, 999.99, 45, 'Pro performance with A17 Pro chip, titanium design, and professional camera system. Perfect for content creators.', 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=500', '8GB', '128GB', '6.1 inch OLED', '3274mAh', 1),
('iPhone 15', 1, 2, 799.99, 60, 'All-new iPhone 15 with Dynamic Island, 48MP main camera, and USB-C. Available in vibrant colors.', 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=500', '6GB', '128GB', '6.1 inch OLED', '3349mAh', 1),
('iPhone 14', 1, 2, 699.99, 40, 'Previous generation iPhone with A15 Bionic chip, great camera, and all-day battery life.', 'https://images.unsplash.com/photo-1678652197831-2d180705cd2c?w=500', '6GB', '128GB', '6.1 inch OLED', '3279mAh', 1),
('iPhone SE (2023)', 1, 3, 429.99, 55, 'Affordable iPhone with A15 Bionic chip, Touch ID, and compact design. Perfect for first-time iPhone users.', 'https://images.unsplash.com/photo-1678652197831-2d180705cd2c?w=500', '4GB', '64GB', '4.7 inch LCD', '2018mAh', 1),

-- Samsung Products
('Samsung Galaxy S24 Ultra', 2, 1, 1299.99, 35, 'Ultimate Samsung flagship with S Pen, 200MP camera, and AI features. Titanium frame and stunning display.', 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500', '12GB', '256GB', '6.8 inch AMOLED', '5000mAh', 1),
('Samsung Galaxy S24+', 2, 1, 999.99, 40, 'Premium Samsung phone with excellent camera, long battery life, and beautiful design.', 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500', '12GB', '256GB', '6.7 inch AMOLED', '4900mAh', 1),
('Samsung Galaxy S24', 2, 2, 799.99, 50, 'Compact flagship with powerful performance, AI camera features, and all-day battery.', 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500', '8GB', '128GB', '6.2 inch AMOLED', '4000mAh', 1),
('Samsung Galaxy A54 5G', 2, 2, 449.99, 70, 'Mid-range champion with excellent camera, 120Hz display, and 5G connectivity.', 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500', '8GB', '128GB', '6.4 inch AMOLED', '5000mAh', 1),
('Samsung Galaxy A34 5G', 2, 3, 349.99, 80, 'Affordable 5G phone with great display, decent camera, and long battery life.', 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500', '6GB', '128GB', '6.6 inch AMOLED', '5000mAh', 1),
('Samsung Galaxy Z Fold 5', 2, 1, 1799.99, 20, 'Revolutionary foldable phone with tablet-sized display, S Pen support, and multitasking features.', 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500', '12GB', '256GB', '7.6 inch Foldable', '4400mAh', 1),
('Samsung Galaxy Z Flip 5', 2, 1, 999.99, 25, 'Stylish flip phone with large cover screen, compact design, and flagship performance.', 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500', '8GB', '256GB', '6.7 inch Foldable', '3700mAh', 1),

-- Xiaomi Products
('Xiaomi 14 Pro', 3, 1, 899.99, 30, 'Flagship Xiaomi with Leica camera, Snapdragon 8 Gen 3, and stunning display.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '12GB', '256GB', '6.73 inch AMOLED', '4880mAh', 1),
('Xiaomi 14', 3, 1, 699.99, 40, 'Compact flagship with excellent performance, Leica camera, and premium build quality.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '8GB', '256GB', '6.36 inch AMOLED', '4610mAh', 1),
('Xiaomi 13T Pro', 3, 2, 599.99, 45, 'Mid-range flagship with MediaTek Dimensity 9200+, 144Hz display, and fast charging.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '12GB', '256GB', '6.67 inch AMOLED', '5000mAh', 1),
('Xiaomi Redmi Note 13 Pro+', 3, 2, 399.99, 60, 'Best mid-range phone with 200MP camera, 120W charging, and beautiful design.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '8GB', '256GB', '6.67 inch AMOLED', '5000mAh', 1),
('Xiaomi Redmi Note 13', 3, 3, 249.99, 90, 'Budget champion with AMOLED display, good camera, and excellent battery life.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '6GB', '128GB', '6.67 inch AMOLED', '5000mAh', 1),
('Xiaomi Poco F5 Pro', 3, 4, 449.99, 50, 'Gaming phone with Snapdragon 8+ Gen 1, 120Hz display, and liquid cooling.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '12GB', '256GB', '6.67 inch AMOLED', '5160mAh', 1),

-- Oppo Products
('Oppo Find X6 Pro', 4, 1, 899.99, 25, 'Flagship with Hasselblad camera, Snapdragon 8 Gen 2, and stunning curved display.', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500', '12GB', '256GB', '6.82 inch AMOLED', '5000mAh', 1),
('Oppo Reno 11 Pro', 4, 2, 549.99, 40, 'Mid-range phone with excellent portrait camera, fast charging, and sleek design.', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500', '12GB', '256GB', '6.7 inch AMOLED', '4600mAh', 1),
('Oppo Reno 11', 4, 2, 449.99, 50, 'Stylish mid-ranger with good camera, 67W charging, and ColorOS features.', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500', '8GB', '256GB', '6.7 inch AMOLED', '5000mAh', 1),
('Oppo A79 5G', 4, 3, 299.99, 70, 'Affordable 5G phone with large display, decent performance, and long battery.', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500', '8GB', '128GB', '6.72 inch LCD', '5000mAh', 1),
('Oppo A58', 4, 3, 199.99, 85, 'Budget phone with good battery, decent camera, and ColorOS experience.', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500', '6GB', '128GB', '6.72 inch LCD', '5000mAh', 1),

-- Vivo Products
('Vivo X100 Pro', 5, 1, 999.99, 20, 'Flagship with Zeiss camera, MediaTek Dimensity 9300, and stunning display.', 'https://images.unsplash.com/photo-1567581935884-3349723552ca?w=500', '12GB', '256GB', '6.78 inch AMOLED', '5400mAh', 1),
('Vivo V29 Pro', 5, 5, 499.99, 45, 'Camera-focused phone with excellent selfie camera, OIS, and Aura Light.', 'https://images.unsplash.com/photo-1567581935884-3349723552ca?w=500', '12GB', '256GB', '6.78 inch AMOLED', '4600mAh', 1),
('Vivo V29', 5, 2, 399.99, 55, 'Mid-range phone with great camera, slim design, and fast charging.', 'https://images.unsplash.com/photo-1567581935884-3349723552ca?w=500', '8GB', '256GB', '6.78 inch AMOLED', '4600mAh', 1),
('Vivo Y36', 5, 3, 249.99, 75, 'Budget phone with large battery, decent camera, and smooth performance.', 'https://images.unsplash.com/photo-1567581935884-3349723552ca?w=500', '8GB', '128GB', '6.64 inch LCD', '5000mAh', 1),

-- Realme Products
('Realme GT 5 Pro', 6, 1, 699.99, 35, 'Flagship killer with Snapdragon 8 Gen 3, 144Hz display, and fast charging.', 'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=500', '12GB', '256GB', '6.78 inch AMOLED', '5400mAh', 1),
('Realme 12 Pro+', 6, 2, 399.99, 60, 'Mid-range phone with periscope camera, premium design, and good performance.', 'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=500', '8GB', '256GB', '6.7 inch AMOLED', '5000mAh', 1),
('Realme 12 Pro', 6, 2, 329.99, 65, 'Affordable mid-ranger with good camera, 120Hz display, and fast charging.', 'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=500', '8GB', '128GB', '6.7 inch AMOLED', '5000mAh', 1),
('Realme C67', 6, 3, 179.99, 95, 'Budget champion with large battery, decent camera, and smooth UI.', 'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=500', '6GB', '128GB', '6.72 inch LCD', '5000mAh', 1),

-- OnePlus Products
('OnePlus 12', 7, 1, 799.99, 30, 'Flagship with Snapdragon 8 Gen 3, Hasselblad camera, and 100W charging.', 'https://images.unsplash.com/photo-1581993192008-63e896f4f744?w=500', '12GB', '256GB', '6.82 inch AMOLED', '5400mAh', 1),
('OnePlus 12R', 7, 2, 599.99, 40, 'Flagship killer with Snapdragon 8 Gen 2, 120Hz display, and OxygenOS.', 'https://images.unsplash.com/photo-1581993192008-63e896f4f744?w=500', '8GB', '128GB', '6.78 inch AMOLED', '5500mAh', 1),
('OnePlus Nord 3', 7, 2, 449.99, 50, 'Mid-range phone with MediaTek Dimensity 9000, 80W charging, and clean UI.', 'https://images.unsplash.com/photo-1581993192008-63e896f4f744?w=500', '8GB', '128GB', '6.74 inch AMOLED', '5000mAh', 1),
('OnePlus Nord CE 3', 7, 3, 329.99, 60, 'Affordable phone with good display, decent camera, and fast charging.', 'https://images.unsplash.com/photo-1581993192008-63e896f4f744?w=500', '8GB', '128GB', '6.7 inch AMOLED', '5000mAh', 1),

-- Google Products
('Google Pixel 8 Pro', 8, 1, 999.99, 25, 'Best Android camera phone with Tensor G3, AI features, and pure Android experience.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '12GB', '128GB', '6.7 inch OLED', '5050mAh', 1),
('Google Pixel 8', 8, 2, 699.99, 35, 'Compact flagship with excellent camera, Tensor G3, and 7 years of updates.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '8GB', '128GB', '6.2 inch OLED', '4575mAh', 1),
('Google Pixel 7a', 8, 3, 449.99, 45, 'Best mid-range camera phone with Tensor G2, wireless charging, and clean Android.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '8GB', '128GB', '6.1 inch OLED', '4385mAh', 1),

-- Nokia Products
('Nokia XR21', 9, 2, 549.99, 30, 'Rugged phone with MIL-STD-810H certification, IP69K rating, and long battery life.', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500', '6GB', '128GB', '6.49 inch LCD', '4800mAh', 1),
('Nokia G60 5G', 9, 3, 349.99, 40, 'Affordable 5G phone with pure Android, good battery, and 3 years of updates.', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500', '6GB', '128GB', '6.58 inch LCD', '4500mAh', 1),

-- Motorola Products
('Motorola Edge 40 Pro', 10, 1, 799.99, 25, 'Flagship with Snapdragon 8 Gen 2, 165Hz display, and 125W charging.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '12GB', '256GB', '6.67 inch OLED', '4600mAh', 1),
('Motorola Edge 40', 10, 2, 549.99, 35, 'Mid-range phone with curved display, wireless charging, and clean Android.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '8GB', '256GB', '6.55 inch OLED', '4400mAh', 1),
('Motorola Moto G84', 10, 3, 299.99, 50, 'Budget phone with OLED display, OIS camera, and good battery life.', 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=500', '8GB', '256GB', '6.5 inch OLED', '5000mAh', 1);

-- Insert Sample Orders
INSERT INTO Orders (user_id, receiver_name, receiver_phone, receiver_address, note, order_date, total_amount, status) VALUES
(2, 'John Doe', '0987654321', '123 Main Street, District 3, Ho Chi Minh City', 'Please call before delivery', DATEADD(day, -5, GETDATE()), 1999.98, 'Completed'),
(2, 'John Doe', '0987654321', '123 Main Street, District 3, Ho Chi Minh City', '', DATEADD(day, -3, GETDATE()), 799.99, 'Shipping'),
(3, 'Jane Smith', '0912345678', '456 Oak Avenue, District 7, Ho Chi Minh City', 'Deliver in the morning', DATEADD(day, -2, GETDATE()), 1749.98, 'Confirmed'),
(3, 'Jane Smith', '0912345678', '456 Oak Avenue, District 7, Ho Chi Minh City', '', DATEADD(day, -1, GETDATE()), 449.99, 'Pending'),
(4, 'Mike Johnson', '0923456789', '789 Pine Road, Binh Thanh District, Ho Chi Minh City', 'Leave at door', DATEADD(day, -7, GETDATE()), 2399.98, 'Completed');

-- Insert Sample Order Details
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price, line_total) VALUES
-- Order 1 (John - Completed)
(1, 1, 1, 999.99, 999.99),
(1, 2, 1, 999.99, 999.99),
-- Order 2 (John - Shipping)
(2, 3, 1, 799.99, 799.99),
-- Order 3 (Jane - Confirmed)
(3, 6, 1, 1299.99, 1299.99),
(3, 9, 1, 449.99, 449.99),
-- Order 4 (Jane - Pending)
(4, 9, 1, 449.99, 449.99),
-- Order 5 (Mike - Completed)
(5, 1, 2, 1199.99, 2399.98);

INSERT INTO Questions (product_id, user_id, content, status) VALUES
(1, 2, 'Does this model support fast charging?', 'Approved'),
(6, 3, 'Does the Galaxy S24 Ultra support the S Pen?', 'Approved'),
(3, 4, 'Can I use two SIM cards with this device?', 'Pending');

INSERT INTO Answers (question_id, user_id, content, status) VALUES
(1, 1, 'Yes, it supports USB-C fast charging with a compatible adapter.', 'Approved'),
(2, 1, 'Yes, the S Pen is built into the Galaxy S24 Ultra.', 'Approved'),
(1, 3, 'I have used a compatible fast charger with this model.', 'Pending');

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

PRINT '=====================================================';
PRINT 'Database created successfully!';
PRINT '=====================================================';
PRINT '';
PRINT 'Summary:';
PRINT '- Roles: 2';
PRINT '- Users: 4 (1 Admin, 3 Customers)';
PRINT '- Brands: 10';
PRINT '- Categories: 5';
DECLARE @ProductCount INT;
SELECT @ProductCount = COUNT(*) FROM Products;
PRINT '- Products: ' + CAST(@ProductCount AS NVARCHAR(10));
PRINT '- Orders: 5';
PRINT '- Order Details: 7';
PRINT '- Questions: 3';
PRINT '- Answers: 3';
PRINT '';
PRINT 'Default Login Credentials:';
PRINT '- Admin: username=admin, password=admin123';
PRINT '- Customer: username=john, password=123456';
PRINT '';
PRINT 'Password hashes are stored securely';
PRINT 'Note: All product images use URLs from Unsplash';
PRINT '=====================================================';
