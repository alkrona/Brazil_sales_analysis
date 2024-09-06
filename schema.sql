CREATE TABLE "payments"(
"id" INT PRIMARY KEY,
"order_id" TEXT ,
"payment_sequential" INT,
"payment_type" TEXT,
"payment_installments" INT,
"payment_value" NUMERIC
);
CREATE TABLE "temp"(
"order_id" TEXT ,
"payment_sequential" INT,
"payment_type" TEXT,
"payment_installments" INT,
"payment_value" NUMERIC
);
CREATE TABLE "reviews"(
"id" INT PRIMARY KEY,
"review_id" TEXT ,
"order_id" TEXT ,
"review_score" INT,
"review_comment_title" TEXT,
"review_comment_message" TEXT,
"review_creation_date" NUMERIC,
"review_answer_timestamp" NUMERIC
);

CREATE TABLE "temp"(
"review_id" TEXT,
"order_id" TEXT,
"review_score" INT ,
"review_comment_title" TEXT,
"review_comment_message" TEXT,
"review_creation_date" NUMERIC,
"review_answer_timestamp" NUMERIC
);
.import --csv --skip 1   data/olist_order_reviews_dataset.csv temp;
INSERT INTO "reviews"("review_id","order_id","review_score",
"review_comment_message","review_creation_date","review_answer_timestamp")
SELECT "review_id","order_id","review_score","review_comment_message",
"review_creation_date","review_answer_timestamp" FROM "temp";
DROP TABLE "temp";
DROP TABLE "temp2";

CREATE TABLE "temp"(
"customer_id" TEXT,
"customer_unique_id" TEXT ,
"customer_zip_code_prefix" TEXT,
"customer_city" TEXT,
"customer_state" TEXT
);
CREATE TABLE "customers"(
"id" INT PRIMARY KEY,
"customer_id" TEXT,
"customer_unique_id" TEXT ,
"customer_zip_code_prefix" TEXT,
"customer_city" TEXT,
"customer_state" TEXT
);
CREATE TABLE "temp"(
"seller_id" TEXT ,
"seller_zip_code_prefix" TEXT,
"seller_city" TEXT,
"seller_state" TEXT);

CREATE TABLE "sellers"(
"seller_id" TEXT PRIMARY KEY ,
"seller_zip_code_prefix" TEXT,
"seller_city" TEXT,
"seller_state" TEXT);

INSERT INTO "sellers"("seller_id","seller_zip_code_prefix","seller_city","seller_state")
SELECT "seller_id","seller_zip_code_prefix","seller_city","seller_state" FROM "temp";

DROP TABLE "temp";

CREATE TABLE "temp"(
"geolocation_zip_code_prefix" TEXT,
"geolocation_lat" NUMERIC,
"geolocation_lng" NUMERIC,
"geolocation_city" TEXT,
"geolocation_state" TEXT
);

CREATE TABLE "geolocations" (
    "id" INT PRIMARY KEY,
    "geolocation_zip_code_prefix" TEXT,
    "geolocation_lat" NUMERIC,
    "geolocation_lng" NUMERIC,
    "geolocation_city" TEXT,
    "geolocation_state" TEXT,
    FOREIGN KEY ("geolocation_zip_code_prefix") REFERENCES "customers" ("customer_zip_code_prefix"),
    FOREIGN KEY ("geolocation_zip_code_prefix") REFERENCES "sellers" ("seller_zip_code_prefix")
);
CREATE TABLE "temp"(
"product_id" TEXT ,
"product_category_name" TEXT,
"product_name_length" INT,
"product_description_length" INT,
"product_photos_qty" INT,
"product_weight_g" INT,
"product_length_cm" INT,
"product_height_cm" INT,
"product_width_cm" INT
);
CREATE TABLE "temp2"(
"product_category_name" TEXT ,
"product_category_name_english" TEXT
);
CREATE TABLE "products"(
"product_id" TEXT PRIMARY KEY ,
"product_category_name_english" TEXT,
"product_name_length" INT,
"product_description_length" INT,
"product_photos_qty" INT,
"product_weight_g" INT,
"product_length_cm" INT,
"product_height_cm" INT,
"product_width_cm" INT
);
INSERT INTO "products"("product_id","product_category_name_english","product_name_length","product_description_length","product_photos_qty","product_weight_g","product_length_cm","product_height_cm","product_width_cm")
 SELECT "product_id","product_category_name_english","product_name_length","product_description_length","product_photos_qty","product_weight_g","product_length_cm","product_height_cm","product_width_cm" FROM "temp"
JOIN "temp2" ON "temp"."product_category_name" = "temp2"."product_category_name";

DROP TABLE "temp";
DROP TABLE "temp2";

CREATE TABLE "temp"(
"order_id" TEXT ,
"order_item_id" INT,
"product_id" TEXT,
"seller_id" TEXT,
"shipping_limit_date" NUMERIC,
"price" NUMERIC,
"freight_value" NUMERIC
);
delete from "temp" where rowid not in
    (select min(rowid) from "temp"
        group by "order_id"
            
    );
CREATE TABLE "orders"(
"order_id" TEXT PRIMARY KEY ,
"order_item_id" INT,
"product_id" TEXT,
"seller_id" TEXT,
"shipping_limit_date" NUMERIC,
"price" NUMERIC,
"freight_value" NUMERIC,
FOREIGN KEY ("product_id") REFERENCES "products"("product_id"),
FOREIGN KEY ("seller_id") REFERENCES "sellers"("seller_id")
);
DROP TABLE "temp";

CREATE TABLE "temp"(
"order_id" TEXT,
"customer_id" TEXT,
"order_status" TEXT,
"order_purchase_timestamp" NUMERIC,
"order_approved_at" NUMERIC,
"order_delivered_carrier_date" NUMERIC,
"order_delivered_customer_date" NUMERIC,
"order_estimated_delivery_date" NUMERIC
);
CREATE TABLE "orders"(
"order_id" TEXT PRIMARY KEY,
"customer_id" TEXT,
"order_status" TEXT,
"order_purchase_timestamp" NUMERIC,
"order_approved_at" NUMERIC,
"order_delivered_carrier_date" NUMERIC,
"order_delivered_customer_date" NUMERIC,
"order_estimated_delivery_date" NUMERIC,
FOREIGN KEY("customer_id") REFERENCES "customers"("customer_id"),
FOREIGN KEY("order_id") REFERENCES "reviews"("order_id"),
FOREIGN KEY("order_id") REFERENCES "payments"("order_id"),
FOREIGN KEY("order_id") REFERENCES "order_items"("order_id")
);
DROP TABLE "reviews;";
DROP TABLE "temp2;";
DROP TABLE "temp";

CREATE TABLE "delayed_routes"(
"customer_city" TEXT,
"seller_city" TEXT,
"late_rate" NUMERIC,
"num_orders" INT
)