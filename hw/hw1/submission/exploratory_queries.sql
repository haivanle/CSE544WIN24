-- 1. For each type of publication, count the total number of publications of that type. 
SELECT p AS PublicationType, COUNT(k) FROM Pub GROUP BY p;
--  publicationtype |  count  
-- -----------------+---------
--  article         | 3367467
--  book            |   20314
--  data            |    4653
--  incollection    |   70301
--  inproceedings   | 3390856
--  mastersthesis   |      21
--  phdthesis       |  124411
--  proceedings     |   57229
--  www             | 3415852
-- (9 rows)

-- 2. Find the fields that occur in all publications types. 
SELECT f.p as FieldName FROM Field f JOIN Pub p ON f.k = p.k GROUP BY f.p HAVING COUNT(DISTINCT p.p) = (SELECT COUNT(DISTINCT p.p) FROM Pub p);
-- Answer:
--  fieldname 
-- -----------
--  author
--  ee
--  title
--  year
-- (4 rows)

-- Note that there are 9 publication types as shown above.
-- SELECT f.p, COUNT(DISTINCT p.p) FROM Pub p INNER JOIN Field f ON p.k = f.k GROUP BY f.p HAVING COUNT(DISTINCT p.p) >= 9;
--    p    | count 
-- --------+-------
--  author |     9
--  ee     |     9
--  title  |     9
--  year   |     9
-- (4 rows)

-- Speed them up by creating appropriate indexes, using the CREATE INDEX statement. You also need indexes on Pub and Field for the next question; create all indices you need on RawSchema.
CREATE INDEX pubkey ON Pub(k);
CREATE INDEX pubp ON Pub(p);
CREATE INDEX fieldkey ON Field(k);
CREATE INDEX fieldp ON Field(p);
CREATE INDEX fieldv ON Field(v);
