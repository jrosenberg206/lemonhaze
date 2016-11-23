#USE wa_korona;

# min_dt = 2016-09-27 16:24:38 ; max_dt = 2016-11-17 23:29:01
SELECT
  MIN(CAST(REPLACE(LEFT(s.bookingTime,19),'T',' ') AS DATETIME)) AS min_dt
  ,MAX(CAST(REPLACE(LEFT(s.bookingTime,19),'T',' ') AS DATETIME)) AS max_dt
FROM wa_korona.sales s;

SELECT * FROM wa_korona.sales s LIMIT 100;
SELECT * FROM wa_korona.products LIMIT 100;

SELECT
  s.articleEAN
  ,s.articleNr
  ,s.baseItemPrice
  ,CAST(REPLACE(LEFT(s.bookingTime,19),'T',' ') AS DATETIME) AS cnv_bookingtime
  ,CONCAT(c.firstname,' ',c.surname,'.') AS cashier_fullname
  ,cg.name AS commoditygroup_name
  ,s.cost
  ,s.costCenter
  ,s.deleted
  ,s.description
  ,s.discountable
  ,s.grossItemPrice
  ,s.itemNumber
  ,s.itemSequence
  ,s.manualPrice
  ,s.netItemPrice
  ,pos.name AS pos_name
  ,s.purchasePrice
  ,s.quantity
  ,r.grossRevenueAmount AS receipt_grossrevenueamount
  ,r.grossTotalAmount AS receipt_grosstotalamount
  ,r.netRevenueAmount AS receipt_netrevenueamount
  ,r.netTotalAmount AS receipt_nettotalamount
  ,r.number AS receipt_number
  ,r.taxAmount AS receipt_taxamount
  ,r.voided AS receipt_voided
  ,r.zCount AS receipt_zcount
FROM
  wa_korona.sales                       s
  LEFT JOIN wa_korona.cashiers          c     ON s.cashier = c.uuid
  LEFT JOIN wa_korona.commodityGroups   cg    ON s.commodityGroup = cg.uuid
  LEFT JOIN wa_korona.pos               pos   ON s.pos = pos.uuid
  LEFT JOIN wa_korona.receipts          r     ON s.receipt = r.uuid
#ORDER BY
  #s.bookingTime
LIMIT 100;

SELECT
  CAST(REPLACE(LEFT(s.bookingTime,19),'T',' ') AS DATE) AS cnv_bookingTime
  ,SUM(s.grossItemPrice) AS sum_grossRevenueAmount
FROM
  wa_korona.sales s
WHERE 1=1
  AND CAST(REPLACE(LEFT(s.bookingTime,19),'T',' ') AS DATE) = '2016-10-01'
GROUP BY
  CAST(REPLACE(LEFT(s.bookingTime,19),'T',' ') AS DATE);


SELECT
  CAST(REPLACE(LEFT(r.createTime,19),'T',' ') AS DATE) AS cnv_createTime
  ,SUM(r.grossRevenueAmount) AS sum_grossRevenueAmount
FROM
  wa_korona.receipts r
WHERE 1=1
  AND CAST(REPLACE(LEFT(r.createTime,19),'T',' ') AS DATE) = '2016-10-01'
GROUP BY
  CAST(REPLACE(LEFT(r.createTime,19),'T',' ') AS DATE);
#LIMIT 100;