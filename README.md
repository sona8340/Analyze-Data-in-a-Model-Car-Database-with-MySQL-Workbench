# Analyze-Data-in-a-Model-Car-Database-with-MySQL-Workbench

## 1. Warehouse Analysis
- Total Quantity in Stock by Warehouse:
Objective: Determine the total quantity of items in stock for each warehouse.

Query:

    SELECT    
    w.warehouseCode, 
    w.warehouseName,
    SUM(p.quantityInStock) AS totalQuantityInStock
    
    FROM
    mintclassics.products p
    
    INNER JOIN
    mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
    
    GROUP BY
    w.warehouseCode, w.warehouseName;

- Items Storage & Elimination Possibility:
Objective: Identify warehouses with their item count, total quantity in stock, and assess if any warehouse could potentially be eliminated.

Query:
    
    SELECT
    w.warehouseCode,
    w.warehouseName,
    COUNT(p.productCode) AS numberOfItems,
    SUM(p.quantityInStock) AS totalQuantityInStock,
    
    CASE WHEN COUNT(p.productCode) = 0 THEN 'Yes' ELSE 'No' END AS canBeEliminated
    
    FROM
    mintclassics.warehouses w
    
    LEFT JOIN
    mintclassics.products p ON w.warehouseCode = p.warehouseCode
    
    GROUP BY
    w.warehouseCode, w.warehouseName;

Observations:

Warehouse 'b' (East) has the highest inventory (219,183 units).

Warehouse 'd' (South) has the lowest inventory (79,380 units).

All warehouses currently have items and are not candidates for elimination.

## 2. Sales and Inventory Relationship
- Total Quantity Ordered and Sales by Product:
Objective: Examine the total quantity ordered and total sales for each product.

Query:
    
    SELECT
    p.productCode,
    p.productName,
    SUM(od.quantityOrdered) AS totalQuantityOrdered,
    SUM(od.priceEach * od.quantityOrdered) AS totalSales
    
    FROM
    mintclassics.products p
    
    JOIN
    mintclassics.orderdetails od ON p.productCode = od.productCode
    
    GROUP BY
    p.productCode, p.productName;

- Products with Consistently Low Sales:
Objective: Identify products with consistently low sales.

Query:

    SELECT
    od.productCode,
    p.productName,
    AVG(quantityOrdered) AS averageQuantityOrdered
    
    FROM
    mintclassics.orderdetails od
    
    JOIN
    mintclassics.products p ON od.productCode = p.productCode
    
    GROUP BY
    productCode, productName
    
    ORDER BY
    averageQuantityOrdered ASC;

Observations:

Products like 'S18_2795', 'S24_3420', etc., have consistently low sales.

## 3. Inventory Status and Sales Trends
- Overview of Products Currently in Inventory:
Objective: Retrieve an overview of products currently in inventory.

Query:

    SELECT
    productCode,
    productName,
    quantityInStock,
    buyPrice,
    MSRP
    
    FROM
    mintclassics.products;

- Top-Selling Products:
Objective: Identify the top-selling products based on quantity ordered.

Query:
    
    SELECT
    productCode,
    priceEach,
    SUM(quantityOrdered) AS totalQuantityOrdered
    
    FROM
    mintclassics.orderdetails
    
    GROUP BY
    productCode, priceEach
    
    ORDER BY
    totalQuantityOrdered DESC
    
    LIMIT 10;

- Overall Sales Trend Over Time:
Objective: Analyze the overall sales trend over time, grouped by year and month.

Query:

    SELECT
    YEAR(os.orderDate) AS orderYear,
    MONTH(os.orderDate) AS orderMonth,
    SUM(priceEach * quantityOrdered) AS monthlySales
    
    FROM
    mintclassics.orders os
    
    JOIN
    mintclassics.orderdetails od ON os.orderNumber = od.orderNumber
    
    GROUP BY
    orderYear, orderMonth
    
    ORDER BY
    orderYear, orderMonth;

- Sales Distribution Across Product Lines:
Objective: Understand how sales are distributed across different product lines.

Query:

    SELECT
    p.productLine,
    SUM(od.priceEach * od.quantityOrdered) AS totalSales
    
    FROM
    mintclassics.orderdetails od
    
    JOIN
    mintclassics.products p ON od.productCode = p.productCode
    
    GROUP BY
    productLine
    
    ORDER BY
    totalSales DESC;

## 4. Customer Purchase Analysis
- Customers with Highest Total Purchase Amounts:
Objective: Identify customers with the highest total purchase amounts.

Query:

    SELECT
    pp.customerNumber,
    c.customerName,
    SUM(amount) AS totalPurchaseAmount
    
    FROM
    mintclassics.payments pp
    
    JOIN
    mintclassics.customers c ON pp.customerNumber = c.customerNumber
    
    GROUP BY
    customerNumber, customerName
    
    ORDER BY
    totalPurchaseAmount DESC
    
    LIMIT 10;


## Conclusion:

The analysis provides valuable insights into the inventory, sales, and customer purchase patterns. Key findings include warehouse inventory levels, product sales trends, and identification of products with consistently low sales. These insights can inform decisions related to warehouse organization, inventory management, and product line adjustments.
