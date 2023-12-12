use mintclassics;
select * from mintclassics.customers, mintclassics.employees,mintclassics.offices,mintclassics.orderdetails,mintclassics.orders,mintclassics.payments,mintclassics.productlines,mintclassics.products,mintclassics.warehouses Limit 1;



SELECT w.warehouseCode, w.warehouseName, SUM(p.quantityInStock) AS totalQuantityInStock
FROM mintclassics.products p
INNER JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY w.warehouseCode, w.warehouseName;

-- Where are items stored and if they were rearranged, could a warehouse be eliminated?

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
/* 'a','North','25','131688','No'
	'b','East','38','219183','No'
	'c','West','24','124880','No'
	'd','South','23','79380','No'
*/


-- How are inventory numbers related to sales figures?

SELECT
    p.productCode,
    p.productName,
    SUM(od.quantityOrdered) AS totalQuantityOrdered,
    SUM(od.priceEach * od.quantityOrdered) AS totalSales
FROM
    products p
JOIN
    orderdetails od ON p.productCode = od.productCode
GROUP BY
    p.productCode, p.productName;
    /* 'S10_1678','1969 Harley Davidson Ultimate Chopper','1057','90157.77'
		'S10_1949','1952 Alpine Renault 1300','961','190017.96'
		'S10_2016','1996 Moto Guzzi 1100i','999','109998.82'
		'S10_4698','2003 Harley-Davidson Eagle Drag Bike','985','170686.00'
		'S10_4757','1972 Alfa Romeo GTA','1030','127924.32'
    */

-- Are we storing items that are not moving? Are any items candidates for being dropped from the product line?

SELECT
    p.productCode,
    p.productName,
    p.quantityInStock,
    COUNT(od.productCode) AS ordersPlaced
FROM
    products p
LEFT JOIN
    orderdetails od ON p.productCode = od.productCode
GROUP BY
    p.productCode, p.productName, p.quantityInStock;
    /*'S10_1678','1969 Harley Davidson Ultimate Chopper','7933','28'
	'S10_1949','1952 Alpine Renault 1300','7305','28'
	'S10_2016','1996 Moto Guzzi 1100i','6625','28'
	'S10_4698','2003 Harley-Davidson Eagle Drag Bike','5582','28'
	'S10_4757','1972 Alfa Romeo GTA','3252','28'
    */


-- Explore products currently in inventory.

SELECT
    productCode,
    productName,
    quantityInStock,
    buyPrice,
    MSRP
FROM
    products;
    /*'S10_1949','1952 Alpine Renault 1300','7305','98.58','214.30'
	'S12_1108','2001 Ferrari Enzo','3619','95.59','207.80'
	'S12_1099','1968 Ford Mustang','68','95.34','194.57'
	'S10_4698','2003 Harley-Davidson Eagle Drag Bike','5582','91.02','193.66'
	'S12_3891','1969 Ford Falcon','1049','83.05','173.02'
	*/


-- What are the top-selling products?

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
/* 'S24_2000','61.70','245'
	'S700_2834','98.48','237'
	'S24_2360','56.10','203'
	'S24_4258','95.44','203'
	'S12_3148','145.04','200'
*/

-- Which warehouses have the highest and lowest inventory levels?

SELECT
    p.warehouseCode,
    w.warehouseName,
    SUM(quantityInStock) AS totalInventory
FROM
    mintclassics.products p
JOIN
    mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY
    warehouseCode, warehouseName
ORDER BY
    totalInventory DESC;
-- Highest inventory (b/East)(219183)
-- Lowest inventory (d/South)(79380)


-- Are there products with consistently low sales?

SELECT
    od.productCode,
    p.productName,
    AVG(quantityOrdered) AS averageQuantityOrdered
FROM
    mintclassics.orderdetails od
join mintclassics.products p ON od.productCode = p.productCode
GROUP BY
    productCode, productName
order by
	averageQuantityOrdered ASC;
/* 'S18_2795','1928 Mercedes-Benz SSK','31.4286'
	'S24_3420','1937 Horch 930V Limousine','31.5714'
	'S700_1691','American Airlines: B767-300','31.9286'
	'S18_4933','1957 Ford Thunderbird','31.9583'
	'S700_2047','HMS Bounty','32.0357'
*/

-- What is the overall sales trend over time?

SELECT
    YEAR(os.orderDate) AS orderYear,
    MONTH(os.orderDate) AS orderMonth,
    SUM(priceEach * quantityOrdered) AS monthlySales
FROM
    mintclassics.orders os
join mintclassics.orderdetails od on os.orderNumber = od.orderNumber
GROUP BY
    orderYear, orderMonth
ORDER BY
    orderYear, orderMonth;
-- '2003','1','116692.77'
-- '2003','2','128403.64'
-- '2003','3','160517.14'
-- '2003','4','185848.59'


-- How are sales distributed across different product lines?

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
 /* 'Classic Cars','3853922.49'
    'Vintage Cars','1797559.63'
    'Motorcycles','1121426.12'
    'Trucks and Buses','1024113.57' 
  */

-- Which customers have the highest total purchase amounts?

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
	/* '141','Euro+ Shopping Channel','715738.98'
		'124','Mini Gifts Distributors Ltd.','584188.24'
		'114','Australian Collectors, Co.','180585.07'
		'151','Muscle Machine Inc','177913.95'
		'148','Dragon Souveniers, Ltd.','156251.03'
	*/
