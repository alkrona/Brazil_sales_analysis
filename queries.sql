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
-- finding customer city late rates
CREATE VIEW "customer_city_late_rates" AS
WITH "table1" AS (
        SELECT "customer_city",COUNT("order_id") AS "count"
        FROM "orders"
        JOIN "customers" ON "orders"."customer_id" = "customers"."customer_id"
        GROUP BY "customer_city"

),
    "table2" AS (
        SELECT "customer_city",COUNT("order_id") AS "count"
        FROM "orders"
        JOIN "customers" ON "orders"."customer_id" = "customers"."customer_id"
        WHERE "order_id" IN (SELECT "order_id" FROM "late_deliveries")
        GROUP BY "customer_city"
        )
SELECT "table1"."customer_city",100*CAST("table2"."count" AS FLOAT)/CAST("table1"."count" AS FLOAT) AS "late_rate",
"table1"."count" AS "num_orders"
FROM "table1"
JOIN "table2" ON "table1"."customer_city" = "table2"."customer_city"
ORDER BY "table1"."count" DESC
LIMIT 10;
-- finding seller city late rates
CREATE VIEW "seller_city_late_rates" AS
WITH "table1" AS (
        SELECT "seller_city",COUNT("order_id") AS "count"
        FROM "order_items"
        JOIN "sellers" ON "order_items"."seller_id" = "sellers"."seller_id"
        GROUP BY "seller_city"

),
    "table2" AS (
        SELECT "seller_city",COUNT("order_id") AS "count"
        FROM "order_items"
        JOIN "sellers" ON "order_items"."seller_id" = "sellers"."seller_id"
        WHERE "order_id" IN (SELECT "order_id" FROM "late_deliveries")
        GROUP BY "seller_city"
        )
SELECT "table1"."seller_city",100*CAST("table2"."count" AS FLOAT)/CAST("table1"."count" AS FLOAT) AS "late_rate",
"table1"."count" AS "num_orders"
FROM "table1"
JOIN "table2" ON "table1"."seller_city" = "table2"."seller_city"
ORDER BY "table1"."count" DESC
LIMIT 10;


--finding customer cities and customer city counts.
CREATE VIEW  "late_customer_city" AS
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
    
),
"table2" AS (
    SELECT "customer_city", COUNT("customer_city") AS "count"
    FROM "customers"
    WHERE "customer_id" IN (
        SELECT "customer_id" 
        FROM "orders"
        WHERE "order_id" IN (SELECT "order_id" FROM "orders")
    )
    GROUP BY "customer_city"
    HAVING COUNT("customer_city") IS NOT NULL
    
)
SELECT "table1"."customer_city",100*CAST("table1"."count" AS FLOAT)/CAST("table2"."count" AS FLOAT) AS "late_rate",
"table2"."count" AS "num_orders"
FROM "table1"
JOIN "table2" ON "table1"."customer_city" = "table2"."customer_city"

ORDER BY "table2"."count" DESC;



-- seller late rate
CREATE VIEW "late_seller_city" AS
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
        
    )
    GROUP BY "seller_city"
    HAVING COUNT("seller_city") IS NOT NULL
    ORDER BY COUNT("seller_city") DESC
)
SELECT "table1"."seller_city", 
       100*CAST("table1"."count" AS FLOAT) / CAST("table2"."count" AS FLOAT) AS "late_rate",
       "table2"."count" AS "num_orders"
FROM "table1"
JOIN "table2" ON "table1"."seller_city" = "table2"."seller_city"
ORDER BY "table2"."count" DESC
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
AND "order_items"."order_id" IN  (SELECT "order_id" FROM "late_deliveries")
AND  julianday("order_delivered_carrier_date")>julianday("shipping_limit_date")

-- late routes
CREATE VIEW  "slow_routes" AS 
WITH "table1" AS (
        SELECT "orders"."order_id" AS "id","seller_id","customer_id"
        FROM "orders"
        JOIN "order_items" ON "orders"."order_id" = "order_items"."order_id"
    ),
    "table2" AS(
        SELECT "table1"."id","customer_city","seller_city"
        FROM "table1"
        JOIN "customers" ON "table1"."customer_id"="customers"."customer_id"
        JOIN "sellers" ON "table1"."seller_id" = "sellers"."seller_id"
    ),
    "table3" AS (
        SELECT "customer_city","seller_city",COUNT("id") AS "count"
        FROM "table2"
        GROUP BY "customer_city","seller_city"
        
    ),
    "table4" AS (
        SELECT "customer_city","seller_city",COUNT("id") AS "count"
        FROM "table2"
        WHERE "id" IN (SELECT "order_id" FROM "late_deliveries")
        GROUP BY "customer_city","seller_city"
        
    )
SELECT "table3"."customer_city","table3"."seller_city",100*CAST("table4"."count" AS FLOAT)/CAST("table3"."count" AS FLOAT) AS "late_rate",
"table3"."count" AS "num_orders"
FROM "table3"
JOIN "table4" ON ("table3"."customer_city" = "table4"."customer_city" AND "table3"."seller_city" = "table4"."seller_city")
WHERE 100*CAST("table4"."count" AS FLOAT)/CAST("table3"."count" AS FLOAT) >10
ORDER BY "table3"."count" DESC 
LIMIT 10;

SELECT "d"."customer_city","d"."seller_city","late_rate","num_orders","g1"."geolocation_lat","g1"."geolocation_lng","g2"."geolocation_lat","g2"."geolocation_lng"
FROM "delayed_routes"  AS "d"
INNER JOIN "geolocations" AS "g1" ON "d"."customer_city" = "g1"."geolocation_city"
INNER JOIN "geolocations" AS "g2" ON "d"."seller_city" = "g2"."geolocation_city"

"geolocation_lat" NUMERIC,
    "geolocation_lng" NUMERIC,
    "geolocation_city"
-- delayed routes with lat and long 
CREATE VIEW "delayed_route" AS 
WITH "distinct_geolocations" AS (
    SELECT 
        "geolocation_city",
        "geolocation_lat",
        "geolocation_lng"
    FROM "geolocations"
    GROUP BY "geolocation_city"
)

SELECT 
    "d"."customer_city",
    "d"."seller_city",
    "d"."late_rate",
    "d"."num_orders",
    "g1"."geolocation_lat" AS "customer_lat",
    "g1"."geolocation_lng" AS "customer_lng",
    "g2"."geolocation_lat" AS "seller_lat",
    "g2"."geolocation_lng" AS "seller_lng"
FROM 
    "delayed_routes" AS "d"
INNER JOIN 
    "distinct_geolocations" AS "g1" ON "d"."customer_city" = "g1"."geolocation_city"
INNER JOIN 
    "distinct_geolocations" AS "g2" ON "d"."seller_city" = "g2"."geolocation_city"