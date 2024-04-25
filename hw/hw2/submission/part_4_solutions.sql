-- 1a Find the name of the director who has directed the most movies. (5 points)
SELECT
    n.name AS director_name,
    COUNT(DISTINCT c.movie_id) AS movie_count
FROM
    name n
JOIN
    cast_info c ON n.id = c.person_id
JOIN
    role_type r ON c.role_id = r.id
JOIN
    title t ON c.movie_id = t.id
WHERE
    r.role = 'director'
GROUP BY
    director_name
ORDER BY
    movie_count DESC
LIMIT 1;

-- Answer:
/*
+---------------+-------------+                                                 
| DIRECTOR_NAME | MOVIE_COUNT |
|---------------+-------------|
| Carson, Dick  |        3058 |
+---------------+-------------+
*/

-- 1b Find the 10 most frequent collaborators with that director. This means the 10 people that appear in cast info on the most movies directed by that director. (5 points)

WITH MostFrequentDirector AS (
    SELECT n.id AS director_id
    FROM name n
    WHERE n.name = 'Carson, Dick'
)

SELECT
    n.name,
    COUNT(DISTINCT ci.movie_id) AS collaboration_count
FROM
    cast_info ci
JOIN
    name n ON ci.person_id = n.id
JOIN
    MostFrequentDirector hd ON ci.movie_id IN (
        SELECT dm.movie_id
        FROM cast_info dm
        JOIN role_type rt ON dm.role_id = rt.id
        WHERE rt.role = 'director' AND dm.person_id = hd.director_id
    )
WHERE
    ci.role_id != (SELECT id FROM role_type WHERE role = 'director')
GROUP BY
    n.name
ORDER BY
    collaboration_count DESC
LIMIT 10;

/*

+--------------------+---------------------+                                    
| NAME               | COLLABORATION_COUNT |
|--------------------+---------------------|
| Griffin, Merv      |                3021 |
| White, Vanna       |                2988 |
| Sajak, Pat         |                2983 |
| Jones, Nancy       |                2411 |
| O'Donnell, Charlie |                1887 |
| Clark, Jack        |                 977 |
| Friedman, Harry    |                 611 |
| Macker, John       |                 195 |
| Kelly, M.G.        |                 113 |
| Stafford, Susan    |                  29 |
+--------------------+---------------------+
*/

-- 1c Find the year where this director produced the most movies. (5 points)
WITH MostFrequentDirector AS (
    SELECT
        n.id AS director_id
    FROM
        name n
    WHERE
        n.name = 'Carson, Dick'
    LIMIT 1
)

SELECT
    t.production_year AS production_year,
    COUNT(DISTINCT t.id) AS movie_count
FROM
    cast_info c
JOIN
    name n ON c.person_id = n.id
JOIN
    title t ON c.movie_id = t.id
JOIN
    MostFrequentDirector mfd ON c.person_id = mfd.director_id
GROUP BY
    production_year 
ORDER BY
    movie_count DESC
LIMIT 1;

/*

+-----------------+-------------+                                               
| PRODUCTION_YEAR | MOVIE_COUNT |
|-----------------+-------------|
|            1984 |         210 |
+-----------------+-------------+
*/

-- 2a Create a view called budget_table which contains pairs of movie_id's and movie budgets. This is challenging because the movie budgets are stored as strings in movie_info. For simplicity, you only need to consider budgets which are listed in dollars, i.e. "$ XXXXXX". To get them stored as numbers, you'll likely need to make use of the REGEXP_SUBSTR, REPLACE, and TO_NUMBER functions. 
CREATE OR REPLACE VIEW budget_table AS
                      SELECT MOVIE_ID, TO_NUMBER(REGEXP_SUBSTR(REPLACE(REGEXP_SUBSTR(info, '[$].*'),
                       ',', ''), '[0-9]+')) as budget
                      FROM movie_info
                      WHERE INFO_TYPE_ID = 105 AND budget IS NOT NULL;

-- 2b Create a view called gross_table which contains pairs of movie_id's and movie gross revenues.
CREATE OR REPLACE VIEW gross_table AS
SELECT MOVIE_ID, gross
FROM (
    SELECT
        MOVIE_ID,
        TO_NUMBER(REGEXP_SUBSTR(REPLACE(REGEXP_SUBSTR(info, '[$].*'), ',', ''), '[0-9]+')) AS gross,
        RANK() OVER (PARTITION BY MOVIE_ID ORDER BY TO_NUMBER(REGEXP_SUBSTR(REPLACE(REGEXP_SUBSTR(info, '[$].*'), ',', ''), '[0-9]+')) DESC) AS rnk
    FROM
        movie_info
    WHERE
        INFO_TYPE_ID = 107
        AND TO_NUMBER(REGEXP_SUBSTR(REPLACE(REGEXP_SUBSTR(info, '[$].*'), ',', ''), '[0-9]+')) IS NOT NULL
) ranked
WHERE
    rnk = 1;

-- 2c Using the temporary views, find the top 10 most profitable movies (i.e. had the greatest gross - budget difference)
SELECT
    b.MOVIE_ID,
    t.TITLE,
    g.gross - b.budget AS profit
FROM
    budget_table b
JOIN
    gross_table g ON b.MOVIE_ID = g.MOVIE_ID
JOIN
    title t ON b.MOVIE_ID = t.ID
ORDER BY
    profit DESC
LIMIT 10;
/*

+----------+-----------------------------------------------+------------+       
| MOVIE_ID | TITLE                                         |     PROFIT |
|----------+-----------------------------------------------+------------|
|  1704289 | Avatar                                        | 2545275172 |
|  2438179 | Titanic                                       | 1985372302 |
|  2346436 | The Avengers                                  | 1291757910 |
|  1938931 | Harry Potter and the Deathly Hallows: Part 2  | 1216511219 |
|  2388429 | The Lord of the Rings: The Return of the King | 1025929521 |
|  2447265 | Transformers: Dark of the Moon                |  928746996 |
|  2292728 | Skyfall                                       |  908561013 |
|  2387041 | The Lion King                                 |  900578747 |
|  2445639 | Toy Story 3                                   |  863171911 |
|  2006991 | Jurassic Park                                 |  851691118 |
+----------+-----------------------------------------------+------------+
*/

-- 3a Count the number of movies where the director is also an actor or actress to see how common it is. 
WITH director AS ( SELECT movie_id, person_id FROM cast_info WHERE role_id = 8 ), 
actor_actress AS ( SELECT movie_id, person_id FROM cast_info WHERE role_id = 1 OR role_id = 2 ) 
SELECT COUNT(DISTINCT d.movie_id) AS num_movies FROM director d JOIN actor_actress aa ON d.movie_id = aa.movie_id AND d.person_id = aa.person_id;


/*
+------------+                                                                  
| NUM_MOVIES |
|------------|
|     139180 |
+------------+
*/

-- 3b Find the average number of actors/actresses in each movie.
SELECT AVG(num_actors) AS average_actors_per_movie
                      FROM (
                          SELECT movie_id, COUNT(person_id) AS num_actors
                          FROM cast_info
                          WHERE role_id = 1 OR role_id = 2    GROUP BY movie_id) AS actors_per_movie
                      ;


/*
+--------------------------+                                                    
| AVERAGE_ACTORS_PER_MOVIE |
|--------------------------|
|                 9.849613 |
+--------------------------+
*/