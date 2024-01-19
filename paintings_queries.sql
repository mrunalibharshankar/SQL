
-- Questions and solutions for painting database --

#How many museums are open on both sunday and monday

SELECT 
    mh.museum_id, m.name, m.city
FROM
    museum_hours mh
        JOIN
    museum m ON m.museum_id = mh.museum_id
WHERE
    mh.day IN ('Sunday' , 'Monday')
GROUP BY m.name , mh.museum_id , m.city
HAVING COUNT(DISTINCT mh.day) = 2;-- count distinct day is both sunday and monday

#How many paintings have an asking price of more than their regular price?
SELECT 
    COUNT(*) AS paintings_count
FROM
    product_size
WHERE
    sale_price > regular_price;

#Identify the paintings whose asking price is less than 50% of its regular price
SELECT * FROM product_size; -- 110345rows

SELECT 
    distinct work_id, sale_price, regular_price
FROM
    product_size
WHERE
    sale_price < 0.50 * regular_price;

#Which canva size costs the most?

SELECT ps.work_id, ps.size_id, ps.regular_price,cs.label
FROM product_size ps join canvas_size cs on cs.size_id = ps.size_id
ORDER BY ps.regular_price DESC
LIMIT 1;

#delete duplicate records from work, product_size, subject and image_link tables
-- Create a new table to store unique records
CREATE TABLE work1 AS
SELECT DISTINCT * FROM work;

CREATE TABLE product_size1 AS
SELECT DISTINCT * FROM product_size;

CREATE TABLE subject1 AS
SELECT DISTINCT * FROM subject;

CREATE TABLE image_link1 AS
SELECT DISTINCT * FROM image_link;

-- Insert unique records from another table
INSERT INTO work1
SELECT DISTINCT * FROM work;

INSERT INTO product_size1
SELECT DISTINCT * FROM product_size;

INSERT INTO subject1
SELECT DISTINCT * FROM subject;

INSERT INTO image_link1
SELECT DISTINCT * FROM image_link;

-- drop the original tables
DROP TABLE work;
DROP TABLE product_size;
DROP TABLE subject;
DROP TABLE image_link;

-- Rename the new table to the original table name
ALTER TABLE work1 RENAME TO work;
ALTER TABLE subject1 RENAME TO subject;
ALTER TABLE product_size1 RENAME TO product_size;
ALTER TABLE image_link1 RENAME TO image_link;

#Identify the museums with invalid city information in the given dataset
select name, city from museum
where not city REGEXP '^[A-Za-zÀ-ÖØ-öø-ÿČčĎďĚěŇňŘřŠšŤťŮůÝýŽž ]+$';

#Museum_Hours table has 1 invalid entry. Identify it and remove it.
SELECT 
    day, COUNT(*)
FROM
    museum_hours
GROUP BY day;

SET SQL_SAFE_UPDATES = 1;

UPDATE museum_hours
SET day = 'Thursday'
WHERE day = 'Thusday';

#Fetch the top 10 most famous painting subject
SELECT 
    COUNT(*) AS no_of_paintings, subject
FROM
    subject
GROUP BY subject
ORDER BY COUNT(*) DESC
LIMIT 10;

#How many museums are open every single day?

SELECT 
    museum_id
FROM
    museum_hours
WHERE
    day IN ('Sunday' , 'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday')
GROUP BY museum_id
HAVING COUNT(DISTINCT day) = 7;

#Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
SELECT 
    m.name, w.museum_id, COUNT(w.work_id) AS no_of_paintings
FROM
    work w
        JOIN
    museum m ON m.museum_id = w.museum_id
GROUP BY w.museum_id , m.name
ORDER BY COUNT(w.work_id) DESC
LIMIT 5;

#Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
SELECT 
    a.full_name, w.artist_id, COUNT(w.work_id) AS no_of_paintings
FROM
    work w
        JOIN
    artist a ON a.artist_id = w.artist_id
GROUP BY w.artist_id , a.full_name
ORDER BY COUNT(w.work_id) DESC
LIMIT 5;


#Display the 3 least popular canva sizes
WITH RankedSizes AS (
    SELECT
        ps.size_id,
        ps.sale_price,
        ps.regular_price,
        cs.label,
        RANK() OVER (ORDER BY ps.sale_price) AS size_rank
    FROM
        product_size ps
    JOIN
        canvas_size cs ON cs.size_id = ps.size_id
    WHERE
        ps.sale_price < ps.regular_price
)
SELECT distinct
    size_id,
    sale_price,
    regular_price,
	label
FROM
    RankedSizes
WHERE
    size_rank <= 3;


#Which museum is open for the longest during a day. Display museum name, state and hours open and which day?
SELECT x.name as museum_name , x.state, time_difference as hours_open, x.day from(SELECT
    m.name,
    m.state,
    mh.day,
    STR_TO_DATE(open, '%h:%i:%p') as open_time,
    STR_TO_DATE(close, '%h:%i:%p') as close_time,
    TIMEDIFF(STR_TO_DATE(close, '%h:%i:%p'), STR_TO_DATE(open, '%h:%i:%p')) AS time_difference,
    RANK() OVER (ORDER BY TIMEDIFF(STR_TO_DATE(open, '%h:%i:%p'), STR_TO_DATE(close, '%h:%i:%p'))) AS time_rank
FROM
    museum_hours mh
JOIN
    museum m ON m.museum_id = mh.museum_id) x
    where time_rank = 1;

#Which museum has the most no of most popular painting style?

 WITH cte_popular_museum AS (

    SELECT 
        museum_id,
        style,
        COUNT(1) AS no_of_paintings,
        RANK() OVER (PARTITION BY style ORDER BY COUNT(1) DESC) AS rnk
    FROM 
        paintings.work
    GROUP BY 
        museum_id, style
         )
SELECT 
    museum_id,
    style
FROM 
    cte_popular_museum
WHERE 
    rnk = 1
ORDER BY
    no_of_paintings DESC;
    

#Identify the artists whose paintings are displayed in multiple countries

SELECT 
    w.artist_id,
    a.full_name,
    COUNT(DISTINCT m.country) AS countries_count
FROM
    work w
        JOIN
    museum m ON m.museum_id = w.museum_id
        JOIN
    artist a ON a.artist_id = w.artist_id
GROUP BY w.artist_id, a.full_name
HAVING countries_count > 1
ORDER BY countries_count DESC;


#Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.

with 
cte_country as (
	SELECT 
		country, count(1),
        rank() over (order by count(1) desc) as museum_count
	FROM 
		paintings.museum
        group by country),
cte_city as (
	SELECT 
		city, count(1),
        rank() over (order by count(1) desc) as museum_count
	FROM 
		paintings.museum
        group by city)
 select GROUP_CONCAT( distinct country SEPARATOR ', ') as country, GROUP_CONCAT(city SEPARATOR ', ') as cities  from cte_country cross join cte_city
 where cte_country.museum_count = 1 and cte_city.museum_count = 1 ;    
        
#Identify the artist and the museum where the most expensive and least expensive painting is placed. 
-- Display the artist name, sale_price, painting name, museum name, museum city and canvas label
WITH RankedPaintings AS (
    SELECT
        w.artist_id,
        ps.sale_price,
        w.name AS painting_name,
        m.name AS museum_name,
        m.city,
        cs.label,
        RANK() OVER (ORDER BY ps.sale_price DESC) AS expensive_rank,
        RANK() OVER (ORDER BY ps.sale_price ASC) AS cheap_rank
    FROM
        product_size ps
    JOIN
        work w ON w.work_id = ps.work_id
    JOIN
        museum m ON m.museum_id = w.museum_id
    JOIN
        canvas_size cs ON cs.size_id = ps.size_id    
)
SELECT distinct 
    rp.artist_id,
    rp.sale_price,
    rp.painting_name,
    rp.museum_name,
    rp.city,
    rp.label
FROM
    RankedPaintings rp
WHERE
    rp.expensive_rank = 1 OR rp.cheap_rank = 1;









