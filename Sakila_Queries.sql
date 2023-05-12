/* These are queries I learned to use by studing Alan Beaulieu's Learning SQL Third Edition.
All queries are run using the Sakila Database */
/* Derrived Subquery Example:*/ 
USE sakila; -- Specify a database

SELECT 
	CONCAT(cust.last_name, ", ", cust.first_name) AS full_name
FROM 
	(SELECT 
		first_name, last_name, email
	FROM 
		customer 
	WHERE 
		first_name = "JESSIE"
	) AS cust;

/* Create a Temporary Table, insert data into TT, check result, and delete */
CREATE TEMPORARY TABLE actors_j
	(actor_id smallint(5),
	first_name varchar(45),
	last_name varchar(45)
	);

INSERT INTO actors_j
SELECT 
	actor_id, first_name, last_name
FROM 
	actor 	
WHERE 
	last_name LIKE 'J%';

SELECT *
FROM actors_j;

-- DROP TABLE actors_j; 

/* Create a View, check result, and delete */
CREATE VIEW cust_vw AS
SELECT 
	customer_id, first_name, last_name, active
FROM 
	customer;

SELECT 
	first_name, last_name
FROM 
	cust_vw
WHERE 
	active = 0;

-- DROP VIEW cust_vw;

/* Use AND to filter all conditions to TRUE */
SELECT 
	title
FROM 
	film 
WHERE 
	rating = 'G' AND rental_duration >= 7;
	
/* Use OR to filter one of the conditions to TRUE */
SELECT 
	title
FROM 
	film 
WHERE 
	rating = 'G' OR rental_duration >= 7;

/* Use both AND and OR together filter those films are rated G and are available for 7 or more days, 
or are rated PG-13 and are available for 3 or fewer days */
SELECT 
	title, rating, rental_duration
FROM 
	film 
WHERE 
	(rating = 'G' AND rental_duration >= 7)
	OR (rating = 'PG-13' AND rental_duration < 4);

/* Use the HAVING clause to filter grouped data */
SELECT 
	c.first_name, c.last_name, COUNT(*)
FROM 
	customer AS c
	INNER JOIN rental AS r 
	ON c.customer_id = r.customer_id
GROUP BY 
	c.first_name , c.last_name 
HAVING  
	COUNT(*) >= 40;

/* Use the ORDER BY clause to find all customers who rented a movie on 2005-06-14 
and order the results by last name and first name*/
SELECT 
	c.first_name, c.last_name, TIME(r.rental_date) AS rental_time
FROM 
	customer AS c
	INNER JOIN rental AS r 
	ON c.customer_id = r.customer_id
WHERE 
	DATE(r.rental_date) = '2005-06-14'
ORDER BY 
	c.last_name, c.first_name;

/* Use the ORDER BY clause to find all customers who rented a movie on 2005-06-14 
and order the results by rental time in descending order*/
SELECT 
	c.first_name, c.last_name, TIME(r.rental_date) AS rental_time
FROM 
	customer AS c
	INNER JOIN rental AS r 
	ON c.customer_id = r.customer_id
WHERE 
	DATE(r.rental_date) = '2005-06-14'
ORDER BY 
	TIME(r.rental_date) DESC;

/* Filter data by using an inequality condition*/
SELECT 
	c.email
FROM 
	customer AS c
	INNER JOIN rental AS r 
	ON c.customer_id = r.customer_id
WHERE 
	DATE(r.rental_date) <> '2005-06-14';

/* Filter data by using a range condition condition*/
SELECT 
	customer_id, rental_date
FROM 
	rental
WHERE 
	rental_date >= '2005-06-14' AND rental_date <= '2005-06-16';

/* Filter data by using the BETWEEN operator*/
SELECT 
	customer_id, amount, payment_date
FROM 
	payment
WHERE 
	amount BETWEEN 10.0 AND 11.99;

/* Filter data by using the IN and NOT IN operators*/
SELECT 
	title, rating
FROM 
	film
WHERE 
	rating IN ('G', 'PG');

SELECT 
	title, rating
FROM 
	film 
WHERE 
	rating NOT IN ('PG-13', 'R', 'NC-17');

/* Filter data by using wildcards*/
SELECT 
	last_name, first_name
FROM 
	customer
WHERE 
	last_name LIKE '_A_T%S'; -- a string containing an A in the second position, a T in the fourth position, followed by any number of characters, and ending in S

SELECT 
	last_name, first_name
FROM 
	customer
WHERE 
	last_name LIKE 'F%'; -- strings starting with F

SELECT 
	last_name, first_name
FROM 
	customer
WHERE 
	last_name LIKE '%t'; -- strings ending with t

SELECT 
	last_name, first_name
FROM 
	customer
WHERE 
	last_name LIKE '%at%'; -- strings containing 'bas'

/* Join tables using an ANSI Join*/
SELECT 
	c.first_name, c.last_name, a.address
FROM 
	customer AS c, address AS a
WHERE 
	c.address_id = a.address_id;

/* Using a subquery as a table*/
SELECT 
	c.first_name, c.last_name, addr.address, addr.city
FROM 
	customer AS c
	INNER JOIN
	(SELECT 
		a.address_id, a.address, ct.city
	FROM 
		address AS a
	INNER JOIN city ct
	ON a.city_id = ct.city_id
	WHERE a.district = 'California'
	) AS addr
	ON c.address_id = addr.address_id;

/* Find all the films in which two specific actors appeared.  This query will find all rows in the film table that have two rows in the film_actor table,
one of which is associated with Cate McQueen, and the other associated with Cuba Birch.  This is why we will join the film actor and actor tables twice,
using different aliases */
SELECT f.title
FROM film f
INNER JOIN film_actor fa1
ON f.film_id = fa1.film_id
INNER JOIN actor a1
ON fa1.actor_id = a1.actor_id
INNER JOIN film_actor fa2
ON f.film_id = fa2.film_id
INNER JOIN actor a2
ON fa2.actor_id = a2.actor_id
WHERE (a1.first_name = 'CATE' AND a1.last_name = 'MCQUEEN')
	AND (a2.first_name = 'CUBA' AND a2.last_name = 'BIRCH'); 

/* Find all the names of multiple tables and combine them using the UNION ALL operato to keep duplicates*/
SELECT 
	'CUSTOMER' AS type, c.first_name, c.last_name
FROM 
	customer AS c
UNION ALL
SELECT 
	'ACTOR' AS type, a.first_name, a.last_name
FROM
	actor AS a;

/* Find all the names with the initials JD using the UNION operator to remove duplicates*/
SELECT 
	c.first_name, c.last_name
FROM 
	customer AS c
WHERE
	c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
UNION 
SELECT 
	a.first_name, a.last_name
FROM 
	actor AS a
WHERE
	a.first_name LIKE 'J%' AND a.last_name LIKE 'D%'
	
/* Find the names with the initials JD that appear in both sets using the INTERSECT operator.  
In other words, find what names are duplicates on both datasets*/
SELECT 
	c.first_name, c.last_name
FROM 
	customer c
WHERE 
	c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
INTERSECT
SELECT 
	a.first_name, a.last_name
FROM 
	actor a
WHERE 
	a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';

/* Find the names with the initials JD that appear in the first set without appearing on the second set using the INTERSECT operator.  
In other words, find what names are in the first set without any overlap*/
SELECT 
	a.first_name, a.last_name
FROM 
	actor a
WHERE 
	a.first_name LIKE 'J%' AND a.last_name LIKE 'D%'
EXCEPT
SELECT 
	c.first_name, c.last_name
FROM 
	customer c
WHERE 
	c.first_name LIKE 'J%' AND c.last_name LIKE 'D%';

/* Join individual columns using the CONCAT() function.  Note that you need to enable the Pipe Concatenation Operator.  You can do this by either:
SET sql_mode=(SELECT CONCAT(@@sql_mode,',PIPES_AS_CONCAT'));
SET sql_mode='ANSI'; */
SELECT 
	CONCAT(first_name, ' ', last_name, ' has been a customer since ', DATE(create_date))
FROM 
	customer;

SELECT 
	first_name || ' ' || ' has been a customer since ' || DATE(create_date)
FROM 
	customer;

/* Insert text on a string with the INSERT() function */
SELECT INSERT('hello world', 7, 0, 'beautiful ') AS string;

/* Select a piece of text on a string with the SUBSTRING() function */
SELECT SUBSTRING('hello beautiful world', 7, 9) AS substring;

/* Calculate a subtotal and a grand total per group with the WITH ROLLUP option*/
SELECT 
	fa.actor_id, f.rating, COUNT(*)
FROM 
	film_actor AS fa
INNER JOIN film AS f 
ON fa.film_id = f.film_id
GROUP BY 
	fa.actor_id, f.rating WITH ROLLUP
ORDER BY 
	1, 2;

/* Use a scalar subquery to find all cities in a country that is not India
Scalar Subqueries are queries that are not correlated to the main query
and that return ONE row and ONE column.  Scalar Subqueries use the
(=, <>, <, >, <=, >=) operators */
SELECT 
	city_id, city
FROM 
	city
WHERE 
	country_id <>
		(SELECT 
			country_id
		FROM 
			country 
		WHERE 
			country = 'India');

/* Use a subquery to find all the cities in both Canada and Mexico.
If the subquery returns MANY rows, you can't use an equality operator.
However, you can use four operators to build additional conditions.
The (IN, NOT IN, ALL, ANY) operators can achieve this. The IN and NOT IN
operators check whether an expression can be found within a set of expressions */
SELECT 
	city_id, city
FROM 
	city
WHERE 
	country_id IN
		(SELECT 
			country_id
		FROM 
			country 
		WHERE 
			country IN ('Canada', 'Mexico'));
		
-- Opposite query
SELECT 
	city_id, city
FROM 
	city
WHERE 
	country_id NOT IN
		(SELECT 
			country_id
		FROM 
			country 
		WHERE 
			country IN ('Canada', 'Mexico')); 

/* Use a subquery to find all customers who have never gotten a free film rental
The ALL operator allows you to make a comparison between a single value and every
value in a set.  You can use one of the comparison operators (=, <>, <, >, <=, >=)
together with ALL */
SELECT 
	customer_id, first_name, last_name
FROM 
	customer
WHERE 
	customer_id <> ALL
		(SELECT 
			customer_id 
		FROM 
			payment
		WHERE 
			amount = 0);

/* Use a subquery to find all the customers whose total film rental payments exceed
the total payments for all customers in Bolivia, Paraguay, or Chile
The ANY operator allows a value to be compared to the members of a set of values.
It evaluates to TRUE as soon as a single comparison is favorable */
SELECT 
	customer_id, SUM(amount)
FROM 
	payment
GROUP BY 
	customer_id
HAVING sum(amount) > ANY
		(SELECT 
			SUM(p.amount)
		FROM 
			payment AS p
		INNER JOIN customer c
     	ON p.customer_id = c.customer_id
	    INNER JOIN address a
     	ON c.address_id = a.address_id
	    INNER JOIN city ct
    	ON a.city_id = ct.city_id
	    INNER JOIN country co
    	ON ct.country_id = co.country_id
		WHERE 
			co.country IN ('Bolivia', 'Paraguay', 'Chile')
		GROUP BY
			co.country);

/* Use a subquery to find all actors with the last name Monroe
and all the films rated PG.  We can use a query that returns multiple columns */
SELECT 
	fa.actor_id, fa.film_id
FROM 
	film_actor fa
WHERE 
	fa.actor_id IN
		(SELECT 
			actor_id 
		FROM 
			actor
		WHERE 
			last_name = 'MONROE')
AND 
	fa.film_id IN
		(SELECT 
			film_id 
		FROM 
			film
		WHERE 
			rating = 'PG');

/* Use a correlated subquery to find the customers who have rented exactly 20 films.
Correlated subqueries are queries that can't be run independently. */
SELECT 
	c.first_name, c.last_name
FROM 
	customer AS c
WHERE 
	20 = 
		(SELECT 
			COUNT(*) 
		FROM 
			rental AS r
		WHERE 
			r. customer_id = c.customer_id);

/* Use a correlated subquery to find all customers whose payments for all rentals are between $180 and $240. */
SELECT 
	c.first_name, c.last_name
FROM 
	customer AS c
WHERE 
	(SELECT 
		SUM(p.amount) 
	FROM 
		payment AS p
	WHERE 
		p.customer_id = c.customer_id)
BETWEEN 
	180 AND 240;

/* Use a EXISTS operator and a correlated subquery to find all customers who rented at least one film before May 25, 2005.
The EXISTS operator identifies whether a relationship exists without regarding quantities */
SELECT 
	c.first_name, c.last_name
FROM 
	customer AS c
WHERE 
	EXISTS
		(SELECT
			1 
		FROM 
			rental AS r
		WHERE 
			r.customer_id = c.customer_id AND date(r.rental_date) < '2005-05-25');

/* Use a correlated subquery and the NOT EXISTS operators to find all actors who have never appeared in an R-rated film */
SELECT 
	a.first_name, a.last_name
FROM 
	actor AS a
WHERE 
	NOT EXISTS 
		(SELECT 
			1 
		FROM 
			film_actor AS fa
		INNER JOIN film AS f 
		ON fa.film_id = f.film_id
		WHERE 
			fa.actor_id = a.actor_id AND f.rating = 'R');

/* Use a subquery as the data source */
SELECT 
	c. first_name, c.last_name, pay.num_rentals, pay.tot_payments
FROM 
	customer AS C
INNER JOIN
		(SELECT 
			customer_id, COUNT(*) AS num_rentals, SUM(amount) AS tot_payments
		FROM 
			payment
		GROUP BY 
			customer_id
		) AS pay
ON c.customer_id = pay.customer_id;

/* Use a subquery to create categories of customers and group them together */
SELECT 
	pymnt_grps.name, count(*) num_customers
FROM
	(SELECT 	
		customer_id, COUNT(*) AS num_rentals, SUM(amount) AS tot_payments
	 FROM 
	 	payment
  	 GROUP BY
  	 	customer_id
 ) AS pymnt
INNER JOIN
	(SELECT 
		'Small Fry' name, 0 low_limit, 74.99 high_limit
  UNION ALL
  SELECT 
  	'Average Joes' name, 75 low_limit, 149.99 high_limit
  UNION ALL
  SELECT 
  	'Heavy Hitters' name, 150 low_limit, 9999999.99 high_limit
 ) AS pymnt_grps
ON 
	pymnt.tot_payments BETWEEN pymnt_grps.low_limit AND pymnt_grps.high_limit
GROUP BY 
	pymnt_grps.name;

/* Use a subquery to organize the query by making all the groups in the subquery */
SELECT 
	c.first_name, c.last_name, ct.city, pay.tot_rentals, pay.tot_payments
FROM
	(SELECT 	
		customer_id, COUNT(*) AS tot_rentals, SUM(amount) AS tot_payments
	 FROM 
	 	payment
  	 GROUP BY
  	 	customer_id
 ) AS pay
INNER JOIN
	customer AS c 
ON 
	pay.customer_id = c.customer_id
INNER JOIN
	address AS a 
ON 
	c.address_id = a.address_id
INNER JOIN 
	city AS ct
ON
	a.city_id = ct.city_id;

/* Use Common Table Expressions to find the total revenue generated from PG-rated films 
where the cast includes an actor whose name begins with the letter S */
WITH actors_s AS
	(SELECT 
		actor_id, first_name, last_name
	FROM 
		actor
	WHERE 
		last_name LIKE 'S%'
	),
actors_s_pg AS
	(SELECT 
		s.actor_id, s.first_name, s.last_name, f.film_id, f.title
	FROM 
		actors_s AS s
	INNER JOIN 
		film_actor AS fa
	ON 
		s.actor_id = fa.actor_id
	INNER JOIN 
		film AS f
	ON 
		f.film_id = fa.film_id
	WHERE 
		f.rating = 'PG'
	),
actors_s_pg_revenue AS
	(SELECT 
		spg.first_name, spg.last_name, p.amount
	FROM 
		actors_s_pg AS spg
	INNER JOIN 
		inventory AS i
	ON 
		i.film_id = spg.film_id
	INNER JOIN 
		rental AS r
	ON 
		i.inventory_id = r.inventory_id
	INNER JOIN 
		payment AS p
	ON 
		r.rental_id = p.rental_id
	) -- end of With clause
SELECT 
	spg_rev.first_name, spg_rev.last_name, SUM(spg_rev.amount) AS tot_revenue
FROM 
	actors_s_pg_revenue AS spg_rev
GROUP BY 
	spg_rev.first_name, spg_rev.last_name
ORDER BY 
	3 DESC;

/* Use correlated scalar subqueries in the SELECT clause to look up the customer's first name, last name, and city
 by accessing the customer table three times S */
SELECT
	(SELECT 
		c.first_name 
	FROM 
		customer AS c
	WHERE 
		c.customer_id = p.customer_id
	) AS first_name,
	(SELECT 
		c.last_name FROM customer c
	WHERE 
		c.customer_id = p.customer_id
	) AS last_name,
	(SELECT 
		ct.city
		FROM 
			customer c
	INNER JOIN 
		address a
	ON 
		c.address_id = a.address_id
	INNER JOIN 
		city ct
	ON 
		a.city_id = ct.city_id
	WHERE 
		c.customer_id = p.customer_id
	) AS location, SUM(p.amount) AS tot_payments, COUNT(*) AS tot_rentals
FROM 
	payment p
GROUP BY 
	p.customer_id;
		
/* Use a CROSS JOIN to quickly build a table of 399 numbers */
SELECT 
	ones.num + tens.num + hundreds.num
FROM
	(SELECT 0 num UNION ALL
	SELECT 1 num UNION ALL
	SELECT 2 num UNION ALL
	SELECT 3 num UNION ALL
	SELECT 4 num UNION ALL
	SELECT 5 num UNION ALL
	SELECT 6 num UNION ALL
	SELECT 7 num UNION ALL
	SELECT 8 num UNION ALL
	SELECT 9 num) AS ones
CROSS JOIN
	(SELECT 0 num UNION ALL
	SELECT 10 num UNION ALL
	SELECT 20 num UNION ALL
	SELECT 30 num UNION ALL
	SELECT 40 num UNION ALL
	SELECT 50 num UNION ALL
	SELECT 60 num UNION ALL
	SELECT 70 num UNION ALL
	SELECT 80 num UNION ALL
	SELECT 90 num) AS tens
CROSS JOIN
	(SELECT 0 num UNION ALL
	SELECT 100 num UNION ALL
	SELECT 200 num UNION ALL
	SELECT 300 num) AS hundreds
ORDER BY 
	1;
	
/* Change the set of numbers to a set of dates */
SELECT 
	DATE_ADD('2023-01-01', INTERVAL (ones.num + tens.num + hundreds.num) DAY) AS dates
FROM
	(SELECT 0 num UNION ALL
	SELECT 1 num UNION ALL
	SELECT 2 num UNION ALL
	SELECT 3 num UNION ALL
	SELECT 4 num UNION ALL
	SELECT 5 num UNION ALL
	SELECT 6 num UNION ALL
	SELECT 7 num UNION ALL
	SELECT 8 num UNION ALL
	SELECT 9 num) AS ones
CROSS JOIN
	(SELECT 0 num UNION ALL
	SELECT 10 num UNION ALL
	SELECT 20 num UNION ALL
	SELECT 30 num UNION ALL
	SELECT 40 num UNION ALL
	SELECT 50 num UNION ALL
	SELECT 60 num UNION ALL
	SELECT 70 num UNION ALL
	SELECT 80 num UNION ALL
	SELECT 90 num) AS tens
CROSS JOIN
	(SELECT 0 num UNION ALL
	SELECT 100 num UNION ALL
	SELECT 200 num UNION ALL
	SELECT 300 num) AS hundreds
WHERE 
	DATE_ADD('2023-01-01', INTERVAL (ones.num + tens.num + hundreds.num) DAY) < '2024-01-01'
ORDER BY 
	1;
	
/* Use the two query structures above to generate a 2005 daily sales report */
SELECT 
	days.dates, COUNT(r.rental_id) AS num_rentals
FROM 
	rental AS r
RIGHT OUTER JOIN
	(SELECT DATE_ADD('2005-01-01', INTERVAL (ones.num + tens.num + hundreds.num) DAY) AS dates
FROM
	(SELECT 0 num UNION ALL
	SELECT 1 num UNION ALL
	SELECT 2 num UNION ALL
	SELECT 3 num UNION ALL
	SELECT 4 num UNION ALL
	SELECT 5 num UNION ALL
	SELECT 6 num UNION ALL
	SELECT 7 num UNION ALL
	SELECT 8 num UNION ALL
	SELECT 9 num) AS ones
CROSS JOIN
	(SELECT 0 num UNION ALL
	SELECT 10 num UNION ALL
	SELECT 20 num UNION ALL
	SELECT 30 num UNION ALL
	SELECT 40 num UNION ALL
	SELECT 50 num UNION ALL
	SELECT 60 num UNION ALL
	SELECT 70 num UNION ALL
	SELECT 80 num UNION ALL
	SELECT 90 num) AS tens
CROSS JOIN
	(SELECT 0 num UNION ALL
	SELECT 100 num UNION ALL
	SELECT 200 num UNION ALL
	SELECT 300 num) AS hundreds
WHERE 
	DATE_ADD('2005-01-01', INTERVAL (ones.num + tens.num + hundreds.num) DAY) < '2006-01-01'
) AS days
ON 
	days.dates = date(r.rental_date)
GROUP BY 
	days.dates
ORDER BY 
	1;	
	
/* Use conditional logic to create a list of the customer name along with their status */
SELECT 
	first_name, last_name,
	CASE
		WHEN active = 1 THEN 'ACTIVE'
		ELSE 'INACTIVE'
	END AS status
FROM
	customer;

/* Use conditional logic to transform data from long to wide form */
SELECT 
	SUM(CASE WHEN MONTHNAME(rental_date) = 'May' THEN 1 ELSE 0 END) AS may_rentals,
	SUM(CASE WHEN MONTHNAME(rental_date) = 'June' THEN 1 ELSE 0 END) AS june_rentals,
	SUM(CASE WHEN MONTHNAME(rental_date) = 'July' THEN 1 ELSE 0 END) AS july_rentals
FROM 
	rental
WHERE rental_date BETWEEN '2005-05-01' AND '2005-08-01';
	
/* Use conditional logic to check whether actors whose first or last name begin with S
have participated in G, PG, and NC-17 movies */
SELECT 
	a.first_name, a.last_name,
	CASE
    	WHEN EXISTS (SELECT 1 FROM film_actor fa
                    INNER JOIN film f ON fa.film_id = f.film_id
                  	WHERE fa.actor_id = a.actor_id
                    AND f.rating = 'G') THEN 'Y'
	    ELSE 'N'
	END AS g_movie,
    CASE
    	WHEN EXISTS (SELECT 1 FROM film_actor fa
                    INNER JOIN film f ON fa.film_id = f.film_id
                  	WHERE fa.actor_id = a.actor_id
                    AND f.rating = 'PG') THEN 'Y'
     	ELSE 'N'
   END AS pg_movie,
   CASE
   		WHEN EXISTS (SELECT 1 FROM film_actor fa
                    INNER JOIN film f ON fa.film_id = f.film_id
                  	WHERE fa.actor_id = a.actor_id
                    AND f.rating = 'NC-17') THEN 'Y'
     	ELSE 'N'
   END AS nc17_movie
FROM 
	actor AS a
WHERE 
	a.last_name LIKE 'S%' OR a.first_name LIKE 'S%';
	
/* Use conditional logic to find the status of the inventory in stock */
SELECT 
	f.title,
	CASE (SELECT 
			COUNT(*) 
		  FROM 
		  	inventory AS i
		  WHERE 
		  	i.film_id = f.film_id)
    	WHEN 0 THEN 'Out of Stock'
    	WHEN 1 THEN 'Scarce'
    	WHEN 2 THEN 'Low'
    	WHEN 3 THEN 'Available'
    	WHEN 4 THEN 'High'
    	ELSE 'Common'
    END AS status
FROM 
	film AS f;
	
/* Use conditional logic to prevent division by zero errors */
SELECT 
	c.first_name, c.last_name, SUM(amount) AS tot_payment_amt, COUNT(p.amount) AS num_payments, SUM(p.amount) /
		CASE 
			WHEN COUNT(p.amount) = 0 THEN 1
			ELSE COUNT(p.amount)
		END AS avg_payment
FROM customer AS c
LEFT OUTER JOIN 
	payment AS p 
ON
	c.customer_id = p.customer_id 
GROUP BY
	c.first_name, c.last_name;

/* Use conditional logic to handle NULL values */
SELECT 
	c.first_name, c.last_name,
  	CASE
    	WHEN a.address IS NULL THEN 'Unknown'
    	ELSE a.address
  	END AS address,
  	CASE
    	WHEN ct.city IS NULL THEN 'Unknown'
    	ELSE ct.city
  	END AS city,
  	CASE
    	WHEN cn.country IS NULL THEN 'Unknown'
    	ELSE cn.country
  	END AS country
FROM 
	customer AS c
LEFT OUTER JOIN 
	address AS a
ON 
	c.address_id = a.address_id
LEFT OUTER JOIN 
	city AS ct
ON
	a.city_id = ct.city_id
LEFT OUTER JOIN 
	country AS cn
ON ct.country_id = cn.country_id;

/* Create a View that protects customer information*/
CREATE VIEW customer_vw
	(customer_id, first_name,last_name, email
	)
AS
	SELECT 
		customer_id, first_name, last_name, CONCAT(SUBSTR(email, 1, 2), '*****', SUBSTR(email, -4)) AS email 
	FROM
		customer;

/* Create a View that optimizes query performance to create future performance reports */
CREATE OR REPLACE VIEW sales_by_film_category_vw
AS
	SELECT
	  c.name AS category, SUM(p.amount) AS total_sales
	FROM 
		payment AS p
	INNER JOIN 
		rental AS r 
	ON p.rental_id = r.rental_id
	INNER JOIN 
		inventory AS i 
	ON 
		r.inventory_id = i.inventory_id
	INNER JOIN 
		film AS f 
	ON 
		i.film_id = f.film_id
	INNER JOIN 
		film_category AS fc 
	ON 
		f.film_id = fc.film_id
	INNER JOIN 
		category AS c 
	ON 
		fc.category_id = c.category_id
	GROUP BY 
		c.name
	ORDER BY 
		total_sales DESC;

/* Create a View to hide query complexity so that management can easily access the information */
CREATE OR REPLACE VIEW film_stats_vw
AS
	SELECT
	  f.film_id, f.title, f.description, f.rating, f.length,
	  	(SELECT 
	  		c.name 
	  	FROM 
	  		category AS c
	  	INNER JOIN 
	  		film_category AS fc 
	  	ON 
	  		c.category_id = fc.category_id
	  	WHERE 
	  		fc.film_id = f.film_id) AS category_name,
	  	(SELECT 
	  		COUNT(*)
	  	FROM 
	  		inventory AS i
	  	WHERE 
	  		f.film_id = i.film_id) AS inventory_cnt,
	  	(SELECT 
	  		COUNT(*)
	  	FROM 
	  		inventory AS i
	  	INNER JOIN 
	  		rental AS r 
	  	ON 
	  		i.inventory_id = r.inventory_id
	  	WHERE 
	  		i.film_id = f.film_id) AS num_rentals
	FROM 
		film AS f;

/* Create a View to build a report that includes the total payments from all customers who live in each country */
CREATE OR REPLACE VIEW country_payments_vw
AS
	SELECT
		c.country,		
			(SELECT 
				SUM(amount)
			FROM 
				payment AS p
			INNER JOIN 
				customer AS c
			ON 
				p.customer_id = c.customer_id 
			INNER JOIN 
				address AS a 
			ON 
				c.address_id = a.address_id 
			INNER JOIN 
				city AS ct 
			ON 
				a.city_id = ct.city_id 
			WHERE 
				ct.country_id = c.country_id
			) AS tot_payments
FROM 
	country AS c;
	
/* Create a monthly sales report to build upon with a Data Window */
SELECT 
	QUARTER(payment_date) AS quarter, MONTHNAME(payment_date) AS month_name, SUM(amount) AS monthly_sales
FROM 
	payment 
WHERE 
	YEAR(payment_date) = 2005
GROUP BY 
	QUARTER(payment_date), MONTHNAME(payment_date);

	
/*Create two additional columns that display the highest amount of monthly sales 
and the highest amount of quarterly sales using a Data Window */
SELECT 
	QUARTER(payment_date) AS quarter, MONTHNAME(payment_date) AS month_name, SUM(amount) AS monthly_sales,
	MAX(SUM(amount)) OVER () AS max_overall_sales,
	MAX(SUM(AMOUNT)) OVER (PARTITION BY QUARTER(payment_date)) AS max_qrtr_sales
FROM 
	payment 
WHERE 
	YEAR(payment_date) = 2005
GROUP BY 
	QUARTER(payment_date), MONTHNAME(payment_date);

/* Add a column to the monthly sales report that ranks the sales by month using the RANK() function */
SELECT 
	QUARTER(payment_date) AS quarter, MONTHNAME(payment_date) AS month_name, SUM(amount) AS monthly_sales,
	RANK () OVER (ORDER BY SUM(amount) DESC) AS sales_rank
FROM 
	payment 
WHERE 
	YEAR(payment_date) = 2005
GROUP BY 
	QUARTER(payment_date), MONTHNAME(payment_date)
ORDER BY 
	1, 2;

/* Add a column to the monthly sales report that ranks the sales by QUARTER using the RANK() function */
SELECT 
	QUARTER(payment_date) AS quarter, MONTHNAME(payment_date) AS month_name, SUM(amount) AS monthly_sales,
	RANK () OVER (PARTITION BY QUARTER(payment_date) ORDER BY SUM(amount) DESC) AS qtr_sales_rank
FROM 
	payment 
WHERE 
	YEAR(payment_date) = 2005
GROUP BY 
	QUARTER(payment_date), MONTHNAME(payment_date)
ORDER BY 
	1, MONTH(payment_date) ;

/* Create a rentals report that ranks customers with the ROW_NMUMBER(), RANK() and DENSE_RANK() functions */
SELECT 
	customer_id, COUNT(*) AS num_rentals,
	ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS row_number_rnk,
	RANK() OVER (ORDER BY COUNT(*) DESC) AS normal_rnk,
	DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS dense_rnk
FROM 
	rental 
GROUP BY 
	customer_id
ORDER BY 
	2 DESC;

/* Create table with the top five customers per number of rentals per month */
SELECT
	customer_id, rental_month, num_rentals, rnk AS ranking
FROM
		(SELECT 
			customer_id, MONTHNAME(rental_date) AS rental_month, COUNT(*) AS num_rentals,
			RANK() OVER (PARTITION BY MONTHNAME(rental_date) ORDER BY COUNT(*) DESC) AS rnk
		FROM
			rental
		GROUP BY 
			customer_id, MONTHNAME(rental_date)
		) AS cust_rankings
WHERE 
	rnk <= 5		
ORDER BY 
	2, 3 DESC;

/* Create table with monthly sales and a column that calculates the sales as a percentage of the total sales */
SELECT
	MONTHNAME(payment_date) AS payment_month, 
	SUM(amount) AS month_total,
	ROUND(SUM(amount) / SUM(SUM(amount)) OVER () * 100, 2) AS pct_of_total
FROM
	payment
GROUP BY	
	1;

/* Create table that calculates the total sales by week and a grand total calculating as a rolling sum 
with the ROWS UNBOUNDED PRECEDING subclause */
SELECT
	YEARWEEK(payment_date) AS payment_week, 
	SUM(amount) AS weekly_total,
	SUM(SUM(amount)) OVER (ORDER BY YEARWEEK(payment_date) ROWS UNBOUNDED PRECEDING) AS rolling_total
FROM
	payment
GROUP BY	
	1
ORDER BY 
	1;

/* Create table that calculates the total sales by week and a column that calculates the rolling three week
average with the ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING subclause */
SELECT
	YEARWEEK(payment_date) AS payment_week, 
	SUM(amount) AS weekly_total,
	AVG(SUM(amount)) OVER (ORDER BY YEARWEEK(payment_date) ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS rolling_3wk_avg
FROM
	payment
GROUP BY	
	1
ORDER BY 
	1;

/* Create table that calculates the total sales by week and a column that calculates a date range interval for a seven day
average with the RANGE BETWEEN INTERVAL 3 DAY PRECEDING AND INTERVAL 3 DAY FOLLOWING subclause
This is done because there are weeks without sales */
SELECT
	DATE(payment_date) AS date, 
	SUM(amount) AS daily_sales,
	AVG(SUM(amount)) OVER (ORDER BY DATE(payment_date) RANGE BETWEEN INTERVAL 3 DAY PRECEDING AND INTERVAL 3 DAY FOLLOWING) AS 7_day_avg
FROM
	payment
WHERE 
	payment_date BETWEEN '2005-07-01' AND '2005-09-01'
GROUP BY	
	1
ORDER BY 
	1;

/* Create monthly sales report which shows the percentage difference from the prior month with the LAG() and LEAD() functions */
SELECT
	YEARWEEK(payment_date) AS payment_week,
	SUM(amount) AS weekly_total,
	LAG(SUM(amount), 1) OVER (ORDER BY YEARWEEK(payment_date)) AS prev_wk_total,
	LEAD(SUM(amount), 1) OVER (ORDER BY YEARWEEK(payment_date)) AS next_wk_total
FROM
	payment
GROUP BY	
	1
ORDER BY 
	1;

/* Create a monthly sales report which shows the percentage difference from the prior week with the LAG() function */
SELECT
	YEARWEEK(payment_date) AS payment_week, 
	SUM(amount) AS weekly_total,
	ROUND((SUM(amount) - LAG(SUM(amount), 1) OVER (ORDER BY YEARWEEK(payment_date))) /
	LAG(SUM(amount), 1) OVER (ORDER BY YEARWEEK(payment_date)) * 100, 1) AS pct_diff
FROM
	payment
GROUP BY	
	1
ORDER BY 
	1;
	
/* Create table that shows the film title on one column and the last names of all its actors on another column  
of films with exactly three actors with the GROUP_CONCAT() function */
SELECT
	f.title, GROUP_CONCAT(a.last_name ORDER BY a.last_name SEPARATOR ', ') AS actors
FROM
	actor AS a
INNER JOIN
	film_actor AS fa
ON
	a.actor_id = fa.actor_id
INNER JOIN
	film AS f
ON
	fa.film_id = f.film_id	
GROUP BY	
	1
HAVING 
	COUNT(*) = 3;