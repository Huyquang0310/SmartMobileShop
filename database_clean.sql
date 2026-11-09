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

INSERT INTO Roles (role_name) VALUES ('Admin'), ('Customer');
INSERT INTO Users (full_name, username, email, password, role_id, status)
VALUES ('Administrator', 'admin', 'admin@mobileshop.com', 'pbkdf2:180000:fJ+H1e/102//AtjEiuGIgA==:hi9hK1uDGm852u+OBGnhyV15C/qXpHqfW6SLJ4cQhGQ=', 1, 1);
