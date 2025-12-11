-- 1: Movies Count as per Duration / Length

	SELECT 
	CASE 
		WHEN length < 50 THEN 'Short_Film'
		WHEN length Between 50 AND 100 THEN 'Medium_Length'
		ELSE 'Long_Film'
		END AS 'Film_Duration',
		COUNT(*) AS 'Film_Count'
		FROM film
	GROUP BY Film_Duration;

-- 2: Monthly Payment Received by Each Staff

	SELECT
		TB1.Month, concat(TB1.first_name," ",TB1.last_name) AS Staff_Name ,cast(sum(TB1.amount) AS INT) AS Payment_BY_Staff
	FROM
		(
		SELECT 
			I.inventory_id,I.film_id,r.rental_id,p.staff_id,p.amount,STRFTIME('%Y-%m', p.payment_date) AS Month ,S.first_name,S.last_name
		FROM inventory I
		LEFT JOIN rental r 
		ON I.inventory_id = r.inventory_id
		JOIN payment p
		ON r.rental_id = p.rental_id
		JOIN staff S
		ON p.staff_id=S.staff_id
		)TB1
	GROUP BY TB1.Month, TB1.staff_id
	ORDER BY TB1.Month,TB1.staff_id;
	
-- 3: Top 10 Actors by Films Count

	WITH film_by_Actors AS
		(
		SELECT 
			f.film_id,fa.actor_id,concat(a.first_name," ", a.last_name) AS Actor_Name
			FROM film f
			JOIN film_actor fa
			ON f.film_id = fa.film_id
			JOIN actor a
			ON fa.actor_id = a.actor_id
		)
		
	SELECT
		Actor_Name,
		COUNT(*) AS Films_Count
	FROM
		film_by_Actors
	GROUP BY Actor_Name
	ORDER BY COUNT(*) DESC
	LIMIT 10;

-- 4: Total Rental Amount per Film category

	WITH CTE AS 
		(
		SELECT r.rental_id,r.inventory_id,p.amount,i.film_id,f.title,fc.category_id,c.name
		FROM rental r
		LEFT JOIN payment p
		ON r.rental_id = p.rental_id
		LEFT JOIN inventory i
		ON r.inventory_id = i.inventory_id
		LEFT JOIN film f
		ON i.film_id = f.film_id
		LEFT JOIN film_category fc
		ON f.film_id = fc.film_id
		LEFT JOIN category c
		ON fc.category_id = c.category_id
	)

	SELECT 
		CTE.name AS Film_Category, 
		SUM(CTE.amount) AS Total_rental_amount
	FROM CTE
	GROUP BY CTE.name
	ORDER BY SUM(CTE.amount) DESC;
	
-- 5: Films Percentage Count per Rating Categort

	SELECT
		rating FilmRating,
		COUNT(*) AS CategoryCount,
		(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()) || '%'  AS PercentageOfTotal
	FROM
		film
	GROUP BY
		rating
	ORDER BY
		PercentageOfTotal DESC;
