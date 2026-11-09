USE SmartMobileShop;
GO
IF OBJECT_ID('Questions', 'U') IS NULL
BEGIN
    CREATE TABLE Questions (
        question_id INT IDENTITY(1,1) PRIMARY KEY,
        product_id INT NOT NULL REFERENCES Products(product_id),
        user_id INT NOT NULL REFERENCES Users(user_id),
        content NVARCHAR(2000) NOT NULL,
        status NVARCHAR(20) NOT NULL DEFAULT 'Pending'
            CHECK (status IN ('Pending', 'Approved', 'Rejected')),
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO
IF OBJECT_ID('Answers', 'U') IS NULL
BEGIN
    CREATE TABLE Answers (
        answer_id INT IDENTITY(1,1) PRIMARY KEY,
        question_id INT NOT NULL REFERENCES Questions(question_id),
        user_id INT NOT NULL REFERENCES Users(user_id),
        content NVARCHAR(2000) NOT NULL,
        status NVARCHAR(20) NOT NULL DEFAULT 'Pending'
            CHECK (status IN ('Pending', 'Approved', 'Rejected')),
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Questions_Product_Status' AND object_id = OBJECT_ID('Questions'))
CREATE INDEX IX_Questions_Product_Status ON Questions(product_id, status);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Answers_Question_Status' AND object_id = OBJECT_ID('Answers'))
CREATE INDEX IX_Answers_Question_Status ON Answers(question_id, status);
GO
