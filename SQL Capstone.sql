
CREATE DATABASE SuperMartCap_DB;
USE  SuperMartCap_DB;

-- ============================================================
-- Activity 1: Database & Table Creation
-- ============================================================

-- 1.1 Creating the Customer Table
CREATE TABLE Customer (
    CustomerId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(20) NOT NULL,
    LastName VARCHAR(20) NOT NULL,
    City VARCHAR(30) NOT NULL,
    CustPhone VARCHAR(10) NULL,
    CustEmail VARCHAR(50) NOT NULL
);

-- 1.2 Creating the Orders Table
CREATE TABLE Orders (
    OrderId INT IDENTITY(200, 1) PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate DATE NOT NULL,
    StatusCode VARCHAR(1) NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId)
);

-- ============================================================
-- Activity 2: Populating the Database
-- ============================================================

-- 2.1 Inserting Customer Records
INSERT INTO Customer (FirstName, LastName, City, CustPhone, CustEmail) VALUES
('Sindile', 'Mnisi', 'JHB', '09877', 'Hello@gmail.com'),
('Boity', 'Mohate', 'Pretoria', '09899', 'Boity@gmail.com'),
('Vendy', 'Vavenda', 'JHB', '09888', 'Vendy@gmail.com'),
('Sihle', 'Shabs', 'Katlehong', '09866', 'Sihle@gmail.com'),
('Champy', 'Champion', 'Pretoria', '09877', 'Champs01@gmail.com'),
('MIMI', 'Shelly', 'Soweto', NULL, 'MShelly@gmail.com'),
('Martin', 'Daeg', 'JHB', NULL, 'TheeDang@gmail.com');

-- 2.2 Inserting Order Records[cite: 1]
INSERT INTO Orders (CustomerId, OrderDate, StatusCode, TotalAmount) VALUES
(1, '2026-09-12', 'P', 300.00),
(2, '2026-01-12', 'D', 200.00),
(1, '2026-02-13', 'C', 1500.00),
(2, '2026-03-13', 'P', 1000.00),
(5, '2026-06-16', 'P', 600.00),
(5, '2026-07-16', 'D', 400.00),
(7, '2026-08-19', 'C', 100.00),
(6, '2026-09-19', 'C', 3000.00),
(7, '2026-09-16', 'P', 300.00);

-- ============================================================
-- Activity 3: Basic Data Retrieval
-- ============================================================

-- Retrieves customer records while substituting missing phone values with default text[cite: 1]
SELECT
    CustomerId,
    FirstName + ' ' + LastName AS [Customer Name],
    City,
    COALESCE(CustPhone, 'No Phone Number') AS CustPhone
FROM Customer;

-- ============================================================
-- Activity 4: Filtering Data
-- ============================================================

-- A. Filter Customers by City
SELECT
    FirstName + ' ' + LastName AS [Full Name],
    CustEmail,
    CustPhone
FROM Customer
WHERE City IN ('JHB', 'Soweto');

-- B. Filter Orders by Date Range[cite: 1]
SELECT OrderId, CustomerId, OrderDate, StatusCode, TotalAmount
FROM Orders
WHERE OrderDate BETWEEN '2026-01-01' AND '2026-03-01';

-- ============================================================
-- Activity 5: Combining Data Using Joins
-- ============================================================

-- 5.1 Inner Join
SELECT c.FirstName + ' ' + c.LastName AS [Customer Name], o.OrderId, o.OrderDate, o.TotalAmount
FROM Customer c
INNER JOIN Orders o ON c.CustomerId = o.CustomerId;

-- 5.2 Left Join
SELECT c.FirstName + ' ' + c.LastName AS [Customer Name], o.OrderId, o.OrderDate, o.TotalAmount
FROM Customer c
LEFT JOIN Orders o ON c.CustomerId = o.CustomerId;

-- 5.3 Right Join
SELECT c.FirstName + ' ' + c.LastName AS [Customer Name], o.OrderId, o.OrderDate, o.TotalAmount
FROM Customer c
RIGHT JOIN Orders o ON c.CustomerId = o.CustomerId;

-- 5.4 Full Outer Join[cite: 1]
SELECT c.FirstName + ' ' + c.LastName AS [Customer Name], o.OrderId, o.OrderDate, o.TotalAmount
FROM Customer c
FULL OUTER JOIN Orders o ON c.CustomerId = o.CustomerId;

-- ============================================================
-- Activity 6: Advanced Queries & Window Functions
-- ============================================================

-- Task 1: String Operations & Formatting
SELECT
    UPPER(FirstName + ' ' + LastName) AS [Customer Name],
    City,
    LEN(FirstName) AS [First Name Length]
FROM Customer
ORDER BY FirstName ASC;

-- Task 2: Aggregation by City
SELECT City, COUNT(*) AS [Total Customer per City]
FROM Customer
GROUP BY City
ORDER BY COUNT(*) DESC;

-- Task 3: Order Statistics Aggregation
SELECT
    COUNT(*) AS [Total Orders],
    AVG(TotalAmount) AS [Order Average],
    MAX(TotalAmount) AS [Order Max Amount],
    MIN(TotalAmount) AS [Order Min Amount]
FROM Orders;

-- Task 4: Window Functions & Order Gaps Analysis
WITH OrderGaps AS (
    SELECT
        OrderId, CustomerId, OrderDate,
        DATENAME(MONTH, OrderDate) AS [Order Month],
        DATEDIFF(DAY, LAG(OrderDate) OVER (PARTITION BY CustomerId ORDER BY OrderDate), OrderDate) AS [Days Since Last Order]
    FROM Orders
)
SELECT * FROM OrderGaps WHERE [Days Since Last Order] <= 30;

-- ============================================================
-- Activity 7: Subqueries, Views & Procedures
-- ============================================================

-- Section A: Subquery Filtering[cite: 1]
SELECT CustomerId, FirstName + ' ' + LastName AS [Customer Name], City
FROM Customer
WHERE CustomerId IN (SELECT DISTINCT CustomerId FROM Orders)
ORDER BY FirstName;

-- Section B: Database View Creation[cite: 1]
GO
CREATE VIEW CustomerOrders AS
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS [Customer Name],
    o.OrderDate,
    o.TotalAmount AS [Order Amount]
FROM Customer c
JOIN Orders o ON c.CustomerId = o.CustomerId;

-- Querying the View
SELECT * FROM CustomerOrders;

-- Section C: Stored Procedure Creation
GO
CREATE PROCEDURE usp_GetCustomerOrders
    @CustomerId INT
AS
BEGIN
    SELECT OrderId, OrderDate, TotalAmount, StatusCode
    FROM Orders
    WHERE CustomerId = @CustomerId;
END;
GO

-- Transaction Handling with TRY...CATCH
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Orders
    SET TotalAmount = 1900.00
    WHERE OrderId = 202;

    COMMIT TRANSACTION;
    PRINT 'Transaction completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Transaction failed';
    PRINT ERROR_MESSAGE();
END CATCH;