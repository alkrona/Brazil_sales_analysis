CREATE TABLE "shipped_orders" AS
SELECT "orders"."order_id",
       "seller_id",
       "shipping_limit_date",
       "order_delivered_carrier_date",
       CASE
           WHEN julianday("shipping_limit_date") < julianday("order_delivered_carrier_date") THEN 1
           ELSE 0
       END AS "shipped_late"
FROM "orders"
JOIN "order_items" ON "orders"."order_id" = "order_items"."order_id";

--Late shipping  percentage = 
SELECT SUM("shipped_late"),COUNT("order_id") AS "shipping_delay"
FROM "shipped_orders"