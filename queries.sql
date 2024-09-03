CREATE VIEW "late_deliveries" AS 
SELECT "order_id",
24*(julianday("order_approved_at") - julianday("order_purchase_timestamp")) AS "purchase_to_approval_time",
24*(julianday("order_delivered_carrier_date") - julianday("order_approved_at")) AS "approval_to_carrier_time",
24*(julianday("order_delivered_customer_date") - julianday("order_delivered_carrier_date")) AS "carrier_to_delivery_time",
24*(julianday("order_delivered_customer_date") - julianday("order_purchase_timestamp")) AS "purchase_to_delivery_time"
FROM "orders" 
WHERE "order_delivered_customer_date" > "order_estimated_delivery_date";

SELECT "review_score", COUNT("review_score") AS "all_deliveries"
FROM "reviews"
GROUP BY "review_score";

SELECT 
    COUNT("review_score") AS "all_deliveries",
    CAST(COUNT("review_score") * 100 / (SELECT COUNT(*) FROM reviews) AS 
INTEGER) AS "percentage"
FROM "reviews"
GROUP BY "review_score";

CREATE VIEW "all_deliveries_rating" AS
SELECT 
    "review_score",
    COUNT(*) AS "count",
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM reviews) AS INTEGER) AS 
"percentage"
FROM "reviews"
GROUP BY "review_score";

(SELECT "review_score"
FROM "reviews" 
JOIN "late_deliveries" ON "reviews"."order_id" = "late_deliveries"."order_id")

CREATE VIEW "late_deliveries_rating" AS
SELECT 
    "review_score",
    COUNT(*) AS "count",
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM 
    (SELECT "review_score"
FROM "reviews" 
JOIN "late_deliveries" ON "reviews"."order_id" = "late_deliveries"."order_id")
    
    ) AS INTEGER) AS 
"percentage"
FROM (SELECT "review_score"
FROM "reviews" 
JOIN "late_deliveries" ON "reviews"."order_id" = "late_deliveries"."order_id")
GROUP BY "review_score";
CREATE VIEW "ontime_deliveries" AS 
SELECT "order_id",
24*(julianday("order_approved_at") - julianday("order_purchase_timestamp")) AS "purchase_to_approval_time",
24*(julianday("order_delivered_carrier_date") - julianday("order_approved_at")) AS "approval_to_carrier_time",
24*(julianday("order_delivered_customer_date") - julianday("order_delivered_carrier_date")) AS "carrier_to_delivery_time",
24*(julianday("order_delivered_customer_date") - julianday("order_purchase_timestamp")) AS "purchase_to_delivery_time"
FROM "orders" 
WHERE "order_delivered_customer_date" <= "order_estimated_delivery_date";

SELECT AVG("purchase_to_approval_time") ,AVG("approval_to_carrier_time"),AVG("carrier_to_delivery_time"),AVG("purchase_to_delivery_time")
FROM "ontime_deliveries"
UNION
SELECT AVG("purchase_to_approval_time"),AVG("approval_to_carrier_time"),AVG("carrier_to_delivery_time"),AVG("purchase_to_delivery_time")
FROM "late_deliveries";

--finding customer cities and customer city counts.
WITH "table1" AS (
    SELECT "customer_city", COUNT("customer_city") AS "count"
    FROM "customers"
    WHERE "customer_id" IN (
        SELECT "customer_id" 
        FROM "orders"
        WHERE "order_id" IN (SELECT "order_id" FROM "late_deliveries")
    )
    GROUP BY "customer_city"
    HAVING COUNT("customer_city") IS NOT NULL
    ORDER BY COUNT("customer_city") DESC
),
"table2" AS (
    SELECT "customer_city", COUNT("customer_city") AS "count"
    FROM "customers"
    WHERE "customer_id" IN (
        SELECT "customer_id" 
        FROM "orders"
        WHERE "order_id" IN (SELECT "order_id" FROM "ontime_deliveries")
    )
    GROUP BY "customer_city"
    HAVING COUNT("customer_city") IS NOT NULL
    ORDER BY COUNT("customer_city") DESC
)
SELECT "table1"."customer_city", 
       CAST("table1"."count" AS FLOAT) / CAST("table2"."count" AS FLOAT) AS "late_rate"
FROM "table1"
JOIN "table2" ON "table1"."customer_city" = "table2"."customer_city"
ORDER BY "late_rate" DESC
LIMIT 10;

-- seller late rate
WITH "table1" AS (
    SELECT "seller_city", COUNT("seller_city") AS "count"
    FROM "sellers"
    WHERE "seller_id" IN (
        SELECT "seller_id" 
        FROM "order_items"
        WHERE "order_id" IN (SELECT "order_id" FROM "late_deliveries")
    )
    GROUP BY "seller_city"
    HAVING COUNT("seller_city") IS NOT NULL
    ORDER BY COUNT("seller_city") DESC
),
"table2" AS (
    SELECT "seller_city", COUNT("seller_city") AS "count"
    FROM "sellers"
    WHERE "seller_id" IN (
        SELECT "seller_id" 
        FROM "order_items"
        WHERE "order_id" IN (SELECT "order_id" FROM "ontime_deliveries")
    )
    GROUP BY "seller_city"
    HAVING COUNT("seller_city") IS NOT NULL
    ORDER BY COUNT("seller_city") DESC
)
SELECT "table1"."seller_city", 
       CAST("table1"."count" AS FLOAT) / CAST("table2"."count" AS FLOAT) AS "late_rate"
FROM "table1"
JOIN "table2" ON "table1"."seller_city" = "table2"."seller_city"
ORDER BY "late_rate" DESC
LIMIT 10;

-- percentage of late orders

-- average number of order of sellers 31
SELECT MIN("orders") 
FROM (
    SELECT "seller_id",count("seller_id") as "orders" FROM "order_items"
    GROUP BY "seller_id")
    HAVING "orders" >=10
    ;

-- find late rate of sellers
WITH "table1" AS (
 SELECT "seller_id",count("seller_id") as "orders" FROM "order_items"
    GROUP BY "seller_id"
    HAVING "orders" >=100
),
"table2" AS(
SELECT "seller_id",COUNT("seller_id") AS "count" FROM 
        (
            SELECT "seller_id" FROM "order_items"
                WHERE "order_id" IN (SELECT "order_id" IN "late_deliveries")
        )
GROUP BY "seller_id"
)
SELECT "table1".seller_id,
    CAST("table2"."count" AS FLOAT)/CAST("table1"."orders" AS FLOAT) AS "late_rate"
FROM "table1"
JOIN "table2" ON "table1"."seller_id"="table2"."seller_id"
ORDER BY "late_rate" DESC
LIMIT 10;
--
CREATE VIEW "late_sellers" AS
WITH "table1" AS (
    SELECT "seller_id", COUNT("seller_id") AS "orders"
    FROM "order_items"
    GROUP BY "seller_id"
    HAVING COUNT("seller_id") >= 10
),
"table2" AS (
    SELECT "seller_id", COUNT("seller_id") AS "count"
    FROM "order_items"
    WHERE "order_id" IN (SELECT "order_id" FROM "late_deliveries")
    GROUP BY "seller_id"
)
SELECT "table1"."seller_id" AS "seller_id",
       CAST("table2"."count" AS FLOAT) / CAST("table1"."orders" AS FLOAT) AS "late_rate"
FROM "table1"
JOIN "table2" ON "table1"."seller_id" = "table2"."seller_id"
WHERE "late_rate" >=0.12
ORDER BY "late_rate" DESC;

-- number of orders from late sellers
SELECT COUNT("order_id") FROM "order_items"
WHERE "seller_id" IN (SELECT "seller_id" FROM "late_sellers");
-- chance of a late seller missing shipping limit date
SELECT COUNT("order_items"."order_id")
FROM "order_items"
JOIN "orders" ON "order_items"."order_id" = "orders"."order_id"
WHERE "seller_id"  IN (SELECT "seller_id" FROM "late_sellers")
AND  julianday("order_delivered_carrier_date")>julianday("shipping_limit_date")