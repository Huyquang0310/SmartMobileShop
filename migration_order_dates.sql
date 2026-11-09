USE SmartMobileShop;
GO

IF COL_LENGTH('dbo.Orders', 'order_date') IS NULL
BEGIN
    ALTER TABLE dbo.Orders ADD order_date DATETIME2(0) NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.default_constraints dc
    INNER JOIN sys.columns c ON c.default_object_id = dc.object_id
    WHERE dc.parent_object_id = OBJECT_ID('dbo.Orders')
      AND c.name = 'order_date'
)
BEGIN
    ALTER TABLE dbo.Orders
    ADD CONSTRAINT DF_Orders_OrderDate DEFAULT SYSDATETIME() FOR order_date;
END;
GO

SELECT order_id, order_date
FROM dbo.Orders
ORDER BY order_id DESC;
GO
