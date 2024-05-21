USE sakila;

-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT COUNT(film_id) AS "Number of Copies of the movie"
FROM inventory
WHERE film_id = (SELECT film_id
				FROM film
				WHERE title = "Hunchback Impossible");

-- List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT title, length
FROM film
WHERE length > (SELECT AVG(length)
				FROM film);

-- Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT first_name, last_name
FROM actor
WHERE actor_id IN (SELECT actor_id
					FROM film_actor
					WHERE film_id IN (SELECT film_id
					FROM film
					WHERE title = "Alone Trip"));
                    
-- Sales have been lagging among young families, and you want to target family movies 
-- for a promotion. Identify all movies categorized as family films.

SELECT f.title
FROM film f
WHERE f.film_id IN
	(SELECT fc.film_id
	FROM film_category fc
	WHERE fc.category_id IN (SELECT c.category_id 
						FROM category c
						WHERE c.name = "Family"));
                        
-- Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find 
-- the different films that he or she starred in.

SELECT f.title
FROM film f
WHERE f.film_id IN
(SELECT fa.film_id
FROM film_actor fa
WHERE fa.actor_id IN (
    SELECT fa.actor_id
    FROM film_actor fa
    GROUP BY fa.actor_id
    HAVING COUNT(fa.film_id) = (
        SELECT MAX(actor_film_counts.number_of_films)
        FROM (
            SELECT fa.actor_id, COUNT(fa.film_id) as number_of_films
            FROM film_actor fa
            GROUP BY fa.actor_id
        ) actor_film_counts
    )
));

-- Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., 
-- the customer who has made the largest sum of payments.

SELECT f.title
FROM film f
WHERE f.film_id IN (
SELECT i.film_id
FROM inventory i
WHERE i.inventory_id IN
(SELECT r.inventory_id
FROM rental r
WHERE r.customer_id IN
(SELECT p.customer_id
FROM payment p
GROUP BY p.customer_id
HAVING SUM(p.amount) = 
(SELECT MAX(total_customer.total_by_customer) as max_total
FROM 
	(SELECT p.customer_id, SUM(p.amount) AS total_by_customer
	FROM payment p
	GROUP BY customer_id) total_customer))));