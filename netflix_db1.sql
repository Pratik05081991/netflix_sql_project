--Netflix Project
drop table if exists netflix;

CREATE TABLE netflix
(
	show_id varchar(10),
	type	varchar(10),
	title	varchar(150),
	director	varchar(250),
	casts	varchar(1000),
	country varchar(150),
	date_added varchar(50),
	release_year integer,
	rating varchar(10),
	duration varchar(20),
	listed_in varchar(100),
	description varchar(300)
);

select * from netflix;

select count(*) as Total_content
from netflix;

SELECT DISTINCT type
FROM netflix;

--- 15 BUSINESS PROBLEMS

--1. COUNT THE NUMBER OF MOVIES VS TV SHOWS
SELECT type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type
	
--2. FIND THE MOST COMMON RATING FOR MOVIES AND TV SHOWS
SELECT
	type,
	RATING
FROM
(
SELECT 
	type,
	rating,
	COUNT(*),
	--MAX(rating)
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY 1, 2
--ORDER BY 1, 3 DESC;
) AS t1
WHERE
	ranking = 1;

--3. LIST ALL THE MOVIES RELEASED IN A SPECIFIC YEAR (e.g., 2020)
--filter 2020
--movies

SELECT * from netflix
WHERE
	type = 'Movie'
	AND
	release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix
select * from netflix;

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP By 1
ORDER BY 2 DESC
LIMIT 5;

--5. Identify the longest movies

SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix);

--6. Find the content that has been added in the last 5 years

select 
     *
	 from netflix
where 
   TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 Years'


--7. Find all the Movies/TV Shows by director 'Rajiv Chilaka'

SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

--8. List all the TV Shows with more than 5 seasons

SELECT * FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration,' ',1)::numeric > 5;

--9. Count the number of content items in each genre

SELECT 
     TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS GENRE,
	 COUNT(show_id) AS TOTAL_CONTENT
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

--10. Find each year and the average number of content releases by India on Netflix. 
--Return the top 5 years with the highest avg content release.

SELECT 
      EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) as Year,
	  COUNT(*) AS YEAR_CONTENT,
	  ROUND
	  (
	  COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100,2)
	  as Avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 3 DESC;

--11. List all the movies that are documentaries

select * from netflix
where listed_in ILIKE '%documentaries%';

--12. Find all the content without the director

SELECT * FROM netflix
WHERE director IS NULL;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT * FROM netflix
WHERE
     casts ILIKE '%Salman Khan%'
	 AND
	 release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
      --show_id,
	  --casts,
	  TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as actors,
	  COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
--Label content containing these keywords as 'BAD' and all other content as 'Good'. 
--Count how many items fall into each category.

WITH new_table
AS
(
SELECT 
*, 
     CASE
	 WHEN
	     description ILIKE '%kill%' OR
		 description ILIKE '%violence%' THEN 'Bad_Content'
		 ELSE 'Good_Content'
	END category
	FROM netflix
)
SELECT 
      category,
	  COUNT(*) as total_content
FROM new_table
GROUP BY 1
ORDER BY 2 DESC;




