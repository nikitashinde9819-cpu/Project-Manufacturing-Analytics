#1.Total Production Quantity by Buyer
SELECT Buyer, SUM(`Produced Qty`) AS Total_Produced 
FROM manufacturing 
GROUP BY Buyer; 

#2.Manufacture Vs Rejected Qty by Department(stored procedure)
DELIMITER $$
CREATE PROCEDURE Get_Depart_Manufacture_vs_Rejected()
BEGIN
    SELECT 
        `Department Name`,
        SUM(`Produced Qty`) AS Manufactured_Qty,
        SUM(`Rejected Qty`) AS Rejected_Qty
    FROM manufacturing
    GROUP BY `Department Name`
    ORDER BY Manufactured_Qty DESC;
END $$
DELIMITER ;

CALL Get_Depart_Manufacture_vs_Rejected();
														
#3.Total Wastage Quantity by Department(window functions)
SELECT DISTINCT
    `Department Name`,
    SUM(`Rejected Qty`) OVER (PARTITION BY `Department Name`) AS Total_Wastage
FROM manufacturing;

#4.total Order Qty vs Produced Qty by Customer(Functions)
DELIMITER $$
CREATE FUNCTION fn_Order_vs_Produced_By_Customer(custName VARCHAR(255))
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE totalOrder DECIMAL(18,2) DEFAULT 0;
    DECLARE totalProduced DECIMAL(18,2) DEFAULT 0;

    SELECT 
        IFNULL(SUM(`Order Qty`), 0),
        IFNULL(SUM(`Produced Qty`), 0)
    INTO totalOrder, totalProduced
    FROM manufacturing
    WHERE `Cust Name` = custName;

    RETURN JSON_OBJECT(
        'Customer', custName,
        'Total_Order', totalOrder,
        'Total_Produced', totalProduced
    );
END $$
DELIMITER ;
SELECT fn_Order_vs_Produced_By_Customer('Sharma Fabrics');

#5.Machine Wise Rejected Qty(limit)
SELECT `Machine Code`, SUM(`Rejected Qty`) AS Total_Rejected
FROM manufacturing
GROUP BY `Machine Code`
ORDER BY Total_Rejected DESC
limit 10;

#6.KPI Cards(Where function)
SELECT  
    SUM(`today manufactured qty`) AS Total_Manufactured_Qty,  
    SUM(`Processed Qty`) AS Total_Processed_Qty,  
    SUM(`Rejected Qty`) AS Total_Rejected_Qty,  
    SUM(`Rejected Qty`) * 100.0 / NULLIF(SUM(`Produced Qty`), 0) AS Wastage_Percent  
FROM manufacturing  
WHERE `Department Name` = 'Printed Fabric';

#7.Top 10 Item wise Total Value
SELECT 
    `Item Code`,
    `Item Name`,
    SUM(`TotalValue`) AS Total_Value_Itemwise
FROM manufacturing
GROUP BY `Item Code`, `Item Name`
ORDER BY Total_Value_Itemwise DESC
LIMIT 10;

#8.Wastage % by Buyer
SELECT Buyer,
SUM(`Rejected Qty`) * 100.0 / NULLIF(SUM(`Produced Qty`), 0) AS Wastage_Percent
FROM manufacturing
GROUP BY Buyer;

#9.Monthly Order Fulfillment
SELECT 
    DATE_FORMAT(`Doc Date`, '%Y-%m') AS Month,
    SUM(`Produced Qty`) AS Produced_Qty
FROM manufacturing
GROUP BY Month
ORDER BY Month;

#10.Employee Wise Rejected Qty
SELECT 
    `Emp Name`,
    SUM(`Rejected Qty`) AS Total_Rejected
FROM manufacturing
GROUP BY `Emp Name`
ORDER BY Total_Rejected DESC;

#11.Monthly Wastage Trend
SELECT 
    DATE_FORMAT(`Doc Date`, '%Y-%m') AS Month,
    SUM(`Rejected Qty`) AS Total_Rejected,
    SUM(`Produced Qty`) AS Total_Produced,
    (SUM(`Rejected Qty`) * 100.0 / SUM(`Produced Qty`)) AS Wastage_Percent
FROM manufacturing
GROUP BY Month
ORDER BY Month;

#12. Designers Based on Produced Quantity
SELECT 
    Designer,
    SUM(`Produced Qty`) AS Total_Produced
FROM manufacturing
GROUP BY Designer
ORDER BY Total_Produced DESC;

#12.Customer Wise Rejection Percentage
SELECT 
    `Cust Name`,
    SUM(`Rejected Qty`) AS Total_Rejected,
    SUM(`Produced Qty`) AS Total_Produced,
    (SUM(`Rejected Qty`) * 100 / SUM(`Produced Qty`)) AS Rejection_Percent
FROM manufacturing
GROUP BY `Cust Name`
ORDER BY Rejection_Percent DESC;

#13.Employee-wise Produced Qty and Rejection Ratio
SELECT 
    `Emp Name`,
    SUM(`Produced Qty`) AS Total_Produced,
    SUM(`Rejected Qty`) AS Total_Rejected,
    (SUM(`Rejected Qty`) / SUM(`Produced Qty`)) * 100 AS RejectionRatio_Percent_Empwise
FROM manufacturing
GROUP BY `Emp Name`
ORDER BY RejectionRatio_Percent_Empwise DESC;

#14.Highset produced qty data
SELECT 
    `Doc Date`,
    SUM(`Produced Qty`) AS Total_produced_perday
FROM manufacturing
GROUP BY `Doc Date`
ORDER BY Total_produced_perday DESC
limit 5;


