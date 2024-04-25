DROP SEQUENCE seqAuthor;
DROP SEQUENCE seqPublication;
DROP TABLE tempHomepage;
DROP TABLE tempAuthor;
DROP TABLE tempTitle;
DROP TABLE tempYear;
DROP TABLE tempJournal;
DROP TABLE tempPublisher;
DROP TABLE tempMonth;
DROP TABLE tempVolume;
DROP TABLE tempNumber;
DROP TABLE tempISBN;
DROP TABLE tempBookTitle;
DROP TABLE tempEditor;

CREATE TABLE tempAuthor (
		PubKey TEXT NOT NULL,
		Name TEXT
		);

CREATE TABLE tempTitle (
		PubKey TEXT NOT NULL,
		Title TEXT
		);
		
CREATE TABLE tempYear (
		PubKey TEXT NOT NULL,
		Year TEXT
		);

CREATE TABLE tempJournal (
		PubKey TEXT NOT NULL,
		Journal TEXT
		);

CREATE TABLE tempPublisher (
		PubKey TEXT NOT NULL,
		Publisher TEXT
		);

CREATE TABLE tempMonth (
		PubKey TEXT NOT NULL,
		Month TEXT
		);
		
CREATE TABLE tempVolume (
		PubKey TEXT NOT NULL,
		Volume TEXT
		);
	
CREATE TABLE tempNumber (
		PubKey TEXT NOT NULL,
		Number TEXT
		);

CREATE TABLE tempISBN (
		PubKey TEXT NOT NULL,
		ISBN TEXT
		);

CREATE TABLE tempBookTitle (
		PubKey TEXT NOT NULL,
		BookTitle TEXT
		);
		
CREATE TABLE tempEditor (
		PubKey TEXT NOT NULL,
		Editor TEXT
		);

-- Taking too long
/*
INSERT INTO tempAuthor (SELECT k, v FROM Field WHERE p = 'author');

INSERT INTO tempTitle (SELECT k, v FROM (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v FROM Field WHERE p = 'title') WHERE r = 1);

INSERT INTO tempYear (SELECT k, v FROM (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v FROM Field WHERE p = 'year') WHERE r = 1);

INSERT INTO tempJournal (SELECT k, v FROM (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v FROM Field WHERE p = 'journal') WHERE r = 1);

INSERT INTO tempPublisher (SELECT k, v FROM (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v FROM Field WHERE p = 'publisher') WHERE r = 1);

INSERT INTO tempMonth (SELECT k, v FROM (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v FROM Field WHERE p = 'month') WHERE r = 1);

INSERT INTO tempVolume (SELECT k, v FROM (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v FROM Field WHERE p = 'volume') WHERE r = 1);

INSERT INTO tempNumber (SELECT k, v FROM (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v FROM Field WHERE p = 'number') WHERE r = 1);

INSERT INTO tempISBN (SELECT k, v FROM (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v FROM Field WHERE p = 'isbn') WHERE r = 1);

INSERT INTO tempBookTitle (SELECT k, v FROM (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v FROM Field WHERE p = 'booktitle') WHERE r = 1);

INSERT INTO tempEditor (SELECT k, v FROM (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v FROM Field WHERE p = 'editor') WHERE r = 1);

*/
INSERT INTO tempAuthor (SELECT k, v FROM Field WHERE p = 'author');
	
WITH tmp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
FROM Field WHERE p = 'title')
INSERT INTO tempTitle (SELECT k, v FROM tmp WHERE r = 1);

WITH tmp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
FROM Field WHERE p = 'year')
INSERT INTO tempYear (SELECT k, v FROM tmp WHERE r = 1);

WITH tmp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
FROM Field WHERE p = 'journal')
INSERT INTO tempJournal (SELECT k, v FROM tmp WHERE r = 1);

WITH tmp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
FROM Field WHERE p = 'publisher')
INSERT INTO tempPublisher (SELECT k, v FROM tmp WHERE r = 1);

WITH tmp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
FROM Field WHERE p = 'month')
INSERT INTO tempMonth (SELECT k, v FROM tmp WHERE r = 1);

WITH tmp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
FROM Field WHERE p = 'volume')
INSERT INTO tempVolume (SELECT k, v FROM tmp WHERE r = 1);
	
WITH tmp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
FROM Field WHERE p = 'number')
INSERT INTO tempNumber (SELECT k, v FROM tmp WHERE r = 1);

WITH tmp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
FROM Field WHERE p = 'isbn')
INSERT INTO tempISBN (SELECT k, v FROM tmp WHERE r = 1);

WITH tmp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
FROM Field WHERE p = 'booktitle')
INSERT INTO tempBookTitle (SELECT k, v FROM tmp WHERE r = 1);

WITH tmp AS (SELECT ROW_NUMBER() OVER (PARTITION BY k) AS r, k, v
FROM Field WHERE p = 'editor')
INSERT INTO tempEditor (SELECT k, v FROM tmp WHERE r = 1);


				
CREATE SEQUENCE seqAuthor;
CREATE SEQUENCE seqPublication;

CREATE TABLE tempHomepage (
Name TEXT NOT NULL UNIQUE,
Homepage TEXT
);

WITH tmp AS (SELECT row_number() over (partition BY ta.Name) AS r, ta.Name, f2.v AS hp
FROM tempAuthor ta INNER JOIN Field f1 ON ta.PubKey = f1.k
INNER JOIN Field f2 ON ta.PubKey = f2.k
WHERE f1.p = 'title' AND f1.v = 'Home Page' AND f2.p = 'url')
INSERT INTO tempHomepage (SELECT Name, hp FROM tmp WHERE tmp.r = 1);
		
INSERT INTO Author (
	SELECT NEXTVAL('seqAuthor'), ta.Name, th.Homepage
	FROM (SELECT DISTINCT Name FROM tempAuthor) AS ta 
	LEFT OUTER JOIN tempHomepage AS th ON ta.Name = th.Name
	);
	
INSERT INTO Publication (
	SELECT NEXTVAL('seqPublication'), p.k, tt.Title, ty.Year
	FROM Pub AS p 
	LEFT OUTER JOIN tempTitle AS tt ON p.k = tt.PubKey
	LEFT OUTER JOIN tempYear AS ty ON p.k = ty.PubKey
	WHERE p.p in ('article', 'book', 'inproceedings', 'incollection')
	);
	
DROP TABLE tempHomepage;
DROP SEQUENCE seqAuthor;	
DROP SEQUENCE seqPublication;


INSERT INTO Authored (
	SELECT DISTINCT a.ID, p.PubID
	FROM tempAuthor AS ta 
	INNER JOIN Author AS a on ta.Name = a.Name
	INNER JOIN Publication AS p ON ta.PubKey = p.PubKey
	);

INSERT INTO Article (
	SELECT p.PubID, tj.Journal, tm.Month, tv.Volume, tn.Number
	FROM Publication AS p
	LEFT OUTER JOIN tempJournal AS tj ON p.PubKey = tj.PubKey
	LEFT OUTER JOIN tempMonth AS tm ON p.PubKey = tm.PubKey
	LEFT OUTER JOIN tempVolume AS tv ON p.PubKey = tv.PubKey
	LEFT OUTER JOIN tempNumber AS tn ON p.PubKey = tn.PubKey
	WHERE EXISTS (
		SELECT * FROM Pub
		WHERE Pub.k = p.PubKey and Pub.p = 'article'
		)
	);	

INSERT INTO Book (
	SELECT p.PubID, tp.Publisher, ti.ISBN
	FROM Publication AS p
	LEFT OUTER JOIN tempPublisher AS tp ON p.PubKey = tp.PubKey
	LEFT OUTER JOIN tempISBN AS ti ON p.PubKey = ti.PubKey
	WHERE EXISTS (
		SELECT * FROM Pub
		WHERE Pub.k = p.PubKey and Pub.p = 'book'
		)
	);

INSERT INTO InCollection (
	SELECT p.PubID, tb.BookTitle, tp.Publisher, ti.ISBN
	FROM Publication AS p
	LEFT OUTER JOIN tempBookTitle AS tb ON p.PubKey = tb.PubKey
	LEFT OUTER JOIN tempPublisher AS tp ON p.PubKey = tp.PubKey
	LEFT OUTER JOIN tempISBN AS ti ON p.PubKey = ti.PubKey
	WHERE EXISTS (
		SELECT * FROM Pub
		WHERE Pub.k = p.PubKey and Pub.p = 'incollection'
		)
	);
	
INSERT INTO InProceedings (
	SELECT p.PubID, tb.BookTitle, te.Editor
	FROM Publication AS p
	LEFT OUTER JOIN tempBookTitle AS tb ON p.PubKey = tb.PubKey
	LEFT OUTER JOIN tempEditor AS te ON p.PubKey = te.PubKey
	WHERE EXISTS (
		SELECT * FROM Pub
		WHERE Pub.k = p.PubKey and Pub.p = 'inproceedings'
		)
	);


DROP TABLE tempAuthor;
DROP TABLE tempTitle;
DROP TABLE tempYear;
DROP TABLE tempJournal;
DROP TABLE tempPublisher;
DROP TABLE tempMonth;
DROP TABLE tempVolume;
DROP TABLE tempNumber;
DROP TABLE tempISBN;
DROP TABLE tempBookTitle;
DROP TABLE tempEditor;
