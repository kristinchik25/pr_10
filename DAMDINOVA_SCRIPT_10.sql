-- Database: postgres

-- DROP DATABASE IF EXISTS postgres;

CREATE DATABASE postgres
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'ru-RU'
    LC_CTYPE = 'ru-RU'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

COMMENT ON DATABASE postgres
    IS 'default administrative connection database';
	
-- Задание 1.
CREATE MATERIALIZED VIEW customer_search AS (
SELECT
customer_json -> 'customer_id' AS customer_id, 
customer_json,to_tsvector('english', customer_json) AS search_vector
FROM customer_sales
);

-- Задание 2.
CREATE INDEX customer_search_gin_idx ON customer_search USING GIN(search_vector);

-- Задание 3.
SELECT
customer_id,
customer_json
FROM customer_search
WHERE search_vector @@ plainto_tsquery('english', 'Danny Bat');

-- Задание 4.
SELECT DISTINCT
p1.model,
p2.model
FROM products p1
LEFT JOIN products p2 ON TRUE
WHERE p1.product_type = 'scooter'
AND p2.product_type = 'automobile'
AND p1.model NOT ILIKE '%Limited
Edition%';

-- Задание 5.
SELECT DISTINCT
plainto_tsquery('english', p1.model) &&
plainto_tsquery('english', p2.model)
FROM products p1
LEFT JOIN products p2 ON TRUE
WHERE p1.product_type = 'scooter'
AND p2.product_type = 'automobile'
AND p1.model NOT ILIKE '%Limited Edition%';

-- Задание 6. 
SELECT
sub.query,
	(
		SELECT COUNT(1)
		FROM customer_search
		WHERE customer_search.search_vector @@ sub.query)
FROM (
	SELECT DISTINCT
		plainto_tsquery('english', p1.model) &&
		plainto_tsquery('english', p2.model) AS query
	FROM products p1
	LEFT JOIN products p2 ON TRUE
	WHERE p1.product_type = 'scooter'
	AND p2.product_type = 'automobile'
	AND p1.model NOT ILIKE '%Limited Edition%'
	) sub
ORDER BY 2 DESC;