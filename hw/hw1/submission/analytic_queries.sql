-- 1. Find the top 20 authors with the largest number of publications. (Runtime: under 10s)

-- Without name
-- SELECT ID, COUNT(*) AS PUBNUM FROM AUTHORED GROUP BY ID ORDER BY PUBNUM DESC LIMIT 20; 
-- With name
SELECT a.ID, a.Name, COUNT(*) AS NumPublications
FROM Author AS a
INNER JOIN Authored AS au ON a.ID = au.ID
GROUP BY a.ID, a.Name
ORDER BY NumPublications DESC
LIMIT 20;

-- Answer:
/*
 id    |         name         | numpublications 
---------+----------------------+-----------------
 1859111 | H. Vincent Poor      |            2830
 2047952 | Yang Liu             |            2172
  348298 | Philip S. Yu         |            2045
   31608 | Mohamed-Slim Alouini |            2010
 2958511 | Yu Zhang             |            1929
 2550154 | Wei Wang             |            1926
 1141633 | Wei Zhang            |            1905
 2274241 | Dacheng Tao          |            1831
 2881866 | Lajos Hanzo          |            1766
 1492366 | Zhu Han 0001         |            1743
 2324293 | Lei Wang             |            1667
 1037071 | Witold Pedrycz       |            1604
 1417963 | Xin Wang             |            1579
   87642 | Hai Jin 0001         |            1576
 2419246 | Hao Wang             |            1572
  583344 | Jing Wang            |            1532
   38273 | Wei Li               |            1531
 1493474 | Victor C. M. Leung   |            1524
  366928 | Luc Van Gool         |            1498
  128642 | Luca Benini          |            1496
(20 rows)
*/

-- 2. Find the top 20 authors with the largest number of publications in STOC. Repeat this for two more conferences, of your choice.  
-- Suggestions: top 20 authors in SOSP, or CHI, or SIGMOD, or SIGGRAPH; note that you need to do some digging to find out how DBLP spells the name of your conference. (Runtime: under 10s.)

-- Without name:
-- CREATE VIEW conference AS (SELECT pubid, booktitle
-- 		FROM Incollection) UNION (SELECT pubid, booktitle
-- 		FROM Inproceedings);
-- CREATE VIEW STOC AS (SELECT a.id, COUNT(*) AS NumPublications
-- 		FROM conference c LEFT OUTER JOIN Authored a ON c.pubid=a.pubid
-- 	WHERE c.booktitle LIKE '%STOC%' OR c.booktitle LIKE '%symposium of theory of computing%'
-- 	GROUP BY a.id
-- );
-- SELECT * FROM STOC ORDER BY NumPublications DESC LIMIT 20;
 
-- With name:
CREATE MATERIALIZED VIEW STOC AS
SELECT DISTINCT f.k AS PubKey
FROM Field f
WHERE 	(f.p = 'booktitle' AND f.v LIKE '%STOC%') OR
	  	(f.p = 'crossref' AND f.v LIKE '%STOC%') OR
	  	(f.p = 'title' AND f.v LIKE '%Symposium on Theory of Computing%');

SELECT a.ID, a.Name, COUNT(ad.PubID) AS NumPublications
FROM Author AS a
INNER JOIN Authored AS ad ON a.ID = ad.ID
INNER JOIN Publication AS p ON ad.PubID = p.PubID
INNER JOIN STOC AS s ON p.PubKey = s.PubKey
GROUP BY a.ID, a.Name
ORDER BY NumPublications DESC
LIMIT 20;

-- Answer:
/*
 id    |           name            | numpublications 
---------+---------------------------+-----------------
 2651248 | Avi Wigderson             |              59
 3013057 | Robert Endre Tarjan       |              33
 2349751 | Ran Raz                   |              32
 1094615 | Venkatesan Guruswami      |              31
  561997 | Moni Naor                 |              29
 1743507 | Noam Nisan                |              29
 1067786 | Santosh S. Vempala        |              28
   65085 | Uriel Feige               |              28
 2768279 | Rafail Ostrovsky          |              27
  403579 | Mihalis Yannakakis        |              27
 3287329 | Mikkel Thorup             |              25
 1287305 | Oded Goldreich 0001       |              25
    2221 | Frank Thomson Leighton    |              25
 2753966 | Yin Tat Lee               |              25
 1865409 | Christos H. Papadimitriou |              24
 2970841 | Moses Charikar            |              24
 1097931 | Prabhakar Raghavan        |              24
   62375 | Sanjeev Khanna            |              23
 2826371 | Madhu Sudan 0001          |              23
  520949 | Salil P. Vadhan           |              23
(20 rows)
*/

-- Without name SIGMOD:
-- CREATE VIEW SIGMOD AS (SELECT a.id, COUNT(*) AS NumPublications
-- FROM conference c LEFT OUTER JOIN Authored a ON c.pubid=a.pubid
-- WHERE c.booktitle LIKE '%SIGMOD%' OR c.booktitle LIKE '%special interest group on management of data%'
-- GROUP BY a.id
-- );
-- SELECT * FROM SIGMOD ORDER BY NumPublications DESC LIMIT 20;

-- With name:
CREATE MATERIALIZED VIEW SIGMOD AS
SELECT DISTINCT f.k AS PubKey
FROM Field f
WHERE 	(f.p = 'booktitle' AND f.v LIKE '%SIGMOD%') OR
		(f.p = 'cdrom' AND f.v LIKE '%SIGMOD%') OR
		(f.p = 'journal' AND f.v LIKE '%SIGMOD%') OR
		(f.p = 'note' AND f.v LIKE '%SIGMOD%') OR
		(f.p = 'url' AND f.v LIKE '%SIGMOD%') OR
		(f.p = 'title' AND f.v LIKE '%SIGMOD%') OR
		(f.p = 'title' AND f.v LIKE '%Special Interest Group on Management of Data%');

SELECT a.ID, a.Name, COUNT(ad.PubID) AS NumPublications
FROM Author AS a
INNER JOIN Authored AS ad ON a.ID = ad.ID
INNER JOIN Publication AS p ON ad.PubID = p.PubID
INNER JOIN SIGMOD AS si ON p.PubKey = si.PubKey
GROUP BY a.ID, a.Name
ORDER BY NumPublications DESC
LIMIT 20;

-- Answer:
/*
id    |         name          | numpublications 
---------+-----------------------+-----------------
 2106037 | Marianne Winslett     |             105
 1280808 | Michael Stonebraker   |              82
  258022 | H. V. Jagadish        |              76
  236883 | Surajit Chaudhuri     |              74
  584040 | Divesh Srivastava     |              71
 2167951 | Richard T. Snodgrass  |              70
   65982 | Michael J. Franklin   |              67
 3224140 | Michael J. Carey 0001 |              64
  858590 | Jeffrey F. Naughton   |              62
 1144805 | Dan Suciu             |              61
 1066060 | Beng Chin Ooi         |              61
 1380457 | David J. DeWitt       |              59
 3377747 | Samuel Madden 0001    |              52
 1398698 | Tim Kraska            |              52
 1289135 | Joseph M. Hellerstein |              51
 3089165 | Hector Garcia-Molina  |              51
 3484609 | Johannes Gehrke       |              50
 2018719 | Jennifer Widom        |              48
   54705 | Donald Kossmann       |              48
 3233226 | Jiawei Han 0001       |              48
(20 rows)
*/

-- Without name SOSP:
-- CREATE VIEW SOSP AS (SELECT a.id, COUNT(*) AS NumPublications
-- FROM conference c LEFT OUTER JOIN Authored a ON c.pubid=a.pubid
-- WHERE c.booktitle LIKE '%SOSP%' OR c.booktitle LIKE '%symposium on operating systems principles%'
-- GROUP BY a.id
-- );
-- SELECT * FROM SOSP ORDER BY NumPublications DESC LIMIT 20;

-- With name:
CREATE MATERIALIZED VIEW SOSP AS
SELECT DISTINCT f.k AS PubKey
FROM Field f
WHERE 	(f.p = 'booktitle' AND f.v LIKE '%SOSP%') OR
		(f.p = 'cdrom' AND f.v LIKE '%SOSP%') OR
		(f.p = 'note' AND f.v LIKE '%SOSP%') OR
		(f.p = 'title' AND f.v LIKE '%SOSP%') OR
		(f.p = 'title' AND f.v LIKE '%symposium on operating systems principles%');

SELECT a.ID, a.Name, COUNT(ad.PubID) AS NumPublications
FROM Author AS a
INNER JOIN Authored AS ad ON a.ID = ad.ID
INNER JOIN Publication AS p ON ad.PubID = p.PubID
INNER JOIN SOSP AS so ON p.PubKey = so.PubKey
GROUP BY a.ID, a.Name
ORDER BY NumPublications DESC
LIMIT 20;

-- Answer:
/*
  id    |           name           | numpublications 
---------+--------------------------+-----------------
   36427 | M. Frans Kaashoek        |              26
 3236940 | Nickolai Zeldovich       |              19
   86799 | Henry M. Levy            |              13
 1623238 | Roger M. Needham         |              13
 1518671 | Remzi H. Arpaci-Dusseau  |              12
 1148595 | Andrea C. Arpaci-Dusseau |              11
 1224269 | David Mazires            |              10
 3162564 | Gregory R. Ganger        |              10
 2895134 | Gerald J. Popek          |              10
 2799689 | Yuanyuan Zhou 0001       |              10
   42199 | Barbara Liskov           |              10
  717286 | Taesoo Kim               |              10
 1205033 | Thomas E. Anderson       |               9
 3042718 | Emmett Witchel           |               9
  874513 | David R. Cheriton        |               9
 1913370 | Matei Zaharia            |               9
 1193869 | Mahadev Satyanarayanan   |               9
 1812752 | Brian N. Bershad         |               9
 2211339 | Ion Stoica               |               9
 3009299 | Haibo Chen 0001          |               9
(20 rows)
*/

-- 3. The two major database conferences are 'PODS' (theory) and 'SIGMOD Conference' (systems). Find

-- (a). all authors who published at least 10 SIGMOD papers but never published a PODS paper, 
-- Without name:
-- SELECT s.id FROM SIGMOD s LEFT OUTER JOIN PODS p ON s.id = p.id WHERE s.cnt >= 10 AND p.cnt IS NULL;

-- With name:
CREATE MATERIALIZED VIEW PODS AS
SELECT DISTINCT f.k AS PubKey
FROM Field f
WHERE 	(f.p = 'booktitle' AND f.v LIKE '%PODS%') OR
        (f.p = 'cdrom' AND f.v LIKE '%PODS%') OR
        (f.p = 'note' AND f.v LIKE '%PODS%') OR
        (f.p = 'title' AND f.v LIKE '%PODS%') OR
        (f.p = 'title' AND f.v LIKE '%Symposium on Principles of Database Systems%');

CREATE VIEW tmpPODS AS (SELECT ad.ID, COUNT(ad.PubID) AS NumPublications
FROM Authored AS ad
INNER JOIN Publication AS p ON ad.PubID = p.PubID
INNER JOIN PODS AS po ON p.PubKey = po.PubKey
GROUP BY ad.ID
ORDER BY NumPublications DESC);

CREATE VIEW tmpSIGMOD AS (SELECT ad.ID, COUNT(ad.PubID) AS NumPublications 
FROM Authored AS ad INNER JOIN Publication AS p ON ad.PubID = p.PubID 
INNER JOIN SIGMOD AS si ON p.PubKey = si.PubKey 
GROUP BY ad.ID 
ORDER BY NumPublications DESC);

SELECT ts.ID, a.Name, ts.NumPublications
FROM tmpPODS AS tp 
FULL OUTER JOIN tmpSIGMOD AS ts ON tp.ID = ts.ID
LEFT OUTER JOIN Author AS a ON ts.ID = a.ID
WHERE tp.NumPublications IS NULL AND ts.NumPublications >= 10
ORDER BY ts.NumPublications DESC;

-- Answer:
/*
 id    |            name             | numpublications 
---------+-----------------------------+-----------------
 1398698 | Tim Kraska                  |              52
 3233226 | Jiawei Han 0001             |              48
   54705 | Donald Kossmann             |              48
 3339754 | Carsten Binnig              |              45
 3000568 | Vanessa Braganholo          |              44
 1310620 | Volker Markl                |              44
   81153 | Guoliang Li 0001            |              42
   22894 | Feifei Li 0001              |              37
   73466 | Alfons Kemper               |              37
  523592 | Stratos Idreos              |              35
 2287884 | Elke A. Rundensteiner       |              35
 3234327 | Jeffrey Xu Yu               |              34
  678424 | Christian S. Jensen         |              34
   95195 | Xiaokui Xiao                |              33
 1131135 | Sihem Amer-Yahia            |              32
 2413590 | Bin Cui 0001                |              31
 1371543 | Jim Gray 0001               |              30
 1828638 | Jignesh M. Patel            |              30
   22624 | David B. Lomet              |              29
 2223556 | Eugene Wu 0002              |              29
 2205595 | Ihab F. Ilyas               |              28
  690648 | Krithi Ramamritham          |              27
 3257297 | Arun Kumar 0001             |              26
 1393599 | Jun Yang 0001               |              25
 1004476 | Nan Tang 0001               |              25
 2132102 | Arie Segev                  |              25
  530302 | Anthony K. H. Tung          |              25
 1511577 | Andrew Pavlo                |              24
   11862 | Gao Cong                    |              23
   55007 | Ling Liu 0001               |              23
 3380593 | Ahmed K. Elmagarmid         |              23
 2136158 | Mourad Ouzzani              |              22
 1168242 | Nick Roussopoulos           |              22
 1749570 | Kevin Chen-Chuan Chang      |              21
  309156 | Laura M. Haas               |              21
  325661 | Aditya G. Parameswaran      |              21
 3132819 | Louiqa Raschid              |              21
 1317933 | Guy M. Lohman               |              21
 3490572 | Jim Melton                  |              21
  804021 | Ioana Manolescu             |              20
 1507863 | Karl Aberer                 |              20
 2002728 | Goetz Graefe                |              19
 2408116 | Badrish Chandramouli        |              19
 2163070 | E. F. Codd                  |              19
 1820085 | Jian Pei                    |              19
 1518106 | Stanley B. Zdonik           |              18
 2051747 | Hans-Arno Jacobsen          |              18
   91125 | Andrew Eisenberg            |              18
 1105732 | Barzan Mozafari             |              18
 2942722 | Daniel J. Abadi             |              18
  185115 | Meihui Zhang 0001           |              18
  138143 | Themis Palpanas             |              18
 1655937 | Jiannan Wang 0001           |              18
 2600942 | Bingsheng He                |              18
 3482006 | Michael J. Cafarella        |              18
 2106281 | Arnon Rosenthal             |              18
 2653548 | Immanuel Trummer            |              18
 1914661 | Gang Chen 0001              |              18
   48768 | Bruce G. Lindsay 0001       |              17
 1401460 | Carlo Curino                |              17
  992104 | Ce Zhang 0001               |              17
 1197913 | Amit P. Sheth               |              17
 2950466 | Asuman Dogac                |              17
  386711 | Jorge-Arnulfo Quian-Ruiz    |              17
 2214013 | Ugur etintemel              |              16
  916822 | Lu Qin 0001                 |              16
 2008090 | Jingren Zhou                |              16
 2969325 | Viktor Leis                 |              16
  120235 | Dirk Habich                 |              16
 2589188 | James Cheng                 |              16
 3497641 | Aaron J. Elmore             |              15
  440868 | Raymond Chi-Wing Wong       |              15
 1377321 | Sanjay Krishnan             |              15
 1492340 | Patrick Valduriez           |              15
 2001079 | Wei Wang 0011               |              15
 2105626 | C. J. Date 0001             |              15
 2251107 | Nesime Tatbul               |              15
 2303861 | Luis Gravano                |              15
 1832145 | Jianliang Xu                |              14
 1780767 | Yinghui Wu                  |              14
 3357165 | Cong Yu 0001                |              14
 3286585 | Jayavel Shanmugasundaram    |              14
 3262170 | Byron Choi                  |              14
  100104 | Yuanyuan Tian               |              14
 3054176 | Babak Salimi                |              14
 3386897 | Kaushik Chakrabarti         |              14
 1595453 | Sebastian Schelter          |              14
  388569 | Torsten Grust               |              14
 1480142 | Boris Glavic                |              14
  392416 | Suman Nath                  |              14
   20333 | Qiong Luo 0001              |              14
  699461 | Betty Salzberg              |              14
  841567 | Fatma zcan                  |              14
  133252 | Kevin S. Beyer              |              13
 1646950 | Ashraf Aboulnaga            |              13
 1888608 | Nicolas Bruno               |              13
  572772 | Xiaofang Zhou 0001          |              13
 2378394 | Clement T. Yu               |              13
 2383079 | Alvin Cheung                |              13
 2530798 | Manos Athanassoulis         |              13
 2575752 | Arash Termehchy             |              13
 2628626 | Lijun Chang                 |              13
 2661551 | Philippe Bonnet             |              13
 2722965 | Eric N. Hanson              |              13
 2935362 | Xifeng Yan                  |              13
   50467 | Hongjun Lu                  |              13
  491231 | Jens Teubner                |              12
   38364 | Ben Kao                     |              12
 1281274 | Nan Zhang 0004              |              12
 3381933 | Vasilis Vassalos            |              12
 2578988 | Zhen Hua Liu                |              12
  969829 | Senjuti Basu Roy            |              12
 1195250 | Theodoros Rekatsinas        |              12
 1706985 | Jianhua Feng                |              12
  379304 | Sainyam Galhotra            |              12
 1612547 | Bolin Ding                  |              12
  691928 | Zhifeng Bao                 |              12
 2675285 | Ryan Marcus                 |              12
 2834816 | Abolfazl Asudeh             |              12
   70066 | Sailesh Krishnamurthy       |              12
 2830756 | Mohamed F. Mokbel           |              12
 2242330 | Reynold Cheng               |              12
 1510178 | Rajasekar Krishnamurthy     |              12
 2262466 | Alekh Jindal                |              12
 1298440 | Jayant Madhavan             |              12
 2101512 | Xu Chu                      |              12
 1913370 | Matei Zaharia               |              12
  878972 | Chi Wang 0001               |              12
 3080951 | Peter Bailis                |              12
 1744769 | Sudipto Das                 |              12
 1827284 | Joy Arulraj                 |              12
 3074974 | Jos A. Blakeley             |              12
  700210 | Eric Lo 0001                |              12
 1930495 | Dong Deng 0001              |              11
   28879 | Sang-Won Lee 0001           |              11
  841465 | Xiaoyong Du 0001            |              11
 2176371 | Stefan Manegold             |              11
 1700622 | Yinan Li                    |              11
   16783 | Wentao Wu 0001              |              11
 2353670 | Saravanan Thirumuruganathan |              11
 2361331 | Joachim Hammer              |              11
 1506990 | Gio Wiederhold              |              11
 3373767 | Arijit Khan 0001            |              11
 2413069 | Chengkai Li 0001            |              11
  423875 | Zhenjie Zhang               |              11
 2622533 | Amihai Motro                |              11
 1469607 | Ju Fan                      |              11
 2786489 | Chris Jermaine              |              11
 2831562 | Matthias Boehm 0001         |              11
 2935231 | Pinar Tzn                   |              11
 2944231 | Carlos Ordonez 0001         |              11
 3000320 | Chee Yong Chan              |              11
 3137453 | Xiaolei Qian                |              11
 3149354 | Sunita Sarawagi             |              11
 3324651 | Kyuseok Shim                |              11
 1789546 | Matthias Jarke              |              11
 3408492 | Lawrence A. Rowe            |              11
 1181882 | K. Seluk Candan             |              10
  124835 | Calton Pu                   |              10
 2557283 | Shamkant B. Navathe         |              10
  506778 | Anastassia Ailamaki         |              10
 2364044 | Chuan Lei                   |              10
  103481 | Arnab Nandi 0001            |              10
 3333558 | Man Lung Yiu                |              10
 1075111 | Anisoara Nica               |              10
 1497222 | Thomas J. Cook              |              10
   93897 | Martin L. Kersten           |              10
  654174 | Il-Yeol Song                |              10
 2082543 | Shaoxu Song                 |              10
 3279196 | Margaret H. Eich            |              10
 1320159 | Alkis Simitsis              |              10
 1095684 | Berthold Reinwald           |              10
 1772597 | Yannis Velegrakis           |              10
 1919378 | Mal Castellanos             |              10
 2829605 | Semih Salihoglu             |              10
 1128930 | Antonios Deligiannakis      |              10
 1474113 | Kai-Uwe Sattler             |              10
 1003060 | Torben Bach Pedersen        |              10
 1476285 | Oliver Kennedy              |              10
 1454287 | Yin Yang 0001               |              10
 1111706 | Florin Rusu                 |              10
  160834 | Shuigeng Zhou               |              10
 1546986 | Konstantinos Karanasos      |              10
(183 rows)
*/

-- (b). all authors who published at least 5 PODS papers but never published a SIGMOD paper. (Runtime: under 10s)

-- Without name:
-- CREATE VIEW PODS AS (SELECT a.id, COUNT(*) AS NumPublications
-- 	FROM conference c LEFT OUTER JOIN Authored a ON c.pubid=a.pubid
-- 	WHERE c.booktitle LIKE '%PODS%'
-- 	GROUP BY a.id
-- );
-- SELECT p.id
-- FROM PODS p LEFT OUTER JOIN SIGMOD s ON s.id = p.id
-- WHERE p.NumPublications >= 5 AND s.NumPublications IS NULL;

-- With name:
SELECT tp.ID, a.Name, tp.NumPublications
FROM tmpPODS AS tp 
FULL OUTER JOIN tmpSIGMOD AS ts ON tp.ID = ts.ID
LEFT OUTER JOIN Author AS a ON tp.ID = a.ID
WHERE tp.NumPublications >= 5 AND ts.NumPublications IS NULL
ORDER BY tp.NumPublications DESC;
-- Answer:
/*id    |          name           | numpublications 
---------+-------------------------+-----------------
 2848710 | Eljas Soisalon-Soininen |               8
  443671 | Nofar Carmeli           |               8
 3412575 | Stavros S. Cosmadakis   |               8
 2191130 | Marco Calautti          |               7
 3085481 | Kobbi Nissim            |               6
 1721128 | Diego Figueira          |               6
 3204747 | Marco Console           |               6
   11961 | Nancy A. Lynch          |               5
 2708048 | Kari-Jouko Rih          |               5
 1259052 | Jelani Nelson           |               5
  204404 | Jerzy Marcinkowski      |               5
 2937439 | Srikanta Tirthapura     |               5
 3129493 | Hubie Chen              |               5
 3255778 | Vassos Hadzilacos       |               5
 2515573 | Alan Nash               |               5
(15 rows)
*/


-- 4. Find the institutions that have published most papers in STOC; return the top 20 institutions. 
-- Then repeat this query with your favorite conference (SOSP or CHI, or ...), and find out which institutions are most prolific. 
-- Hint: where do you get information about institutions? Use the Homepage information: convert a Homepage like http://www.cs.washington.edu/homes/levy/ 
-- to http://www.cs.washington.edu, or even to www.cs.washington.edu; now you have grouped all authors from our department, and we can use this URL 
-- as a surrogate for the institution. To get started with substring manipulation in postgres, you can start by looking up the functions substring, position, and trim in the postgres manual.

CREATE VIEW Insti AS (
SELECT ID, SPLIT_PART(Homepage, '/', 3) AS Institution
FROM Author
WHERE Homepage IS NOT NULL);

SELECT i.Institution, COUNT(DISTINCT ad.PubID) AS NumPublications
FROM STOC AS s
INNER JOIN Publication AS p ON s.PubKey = p.PubKey
INNER JOIN Authored AS ad ON p.PubID = ad.PubID
INNER JOIN Insti AS i ON ad.ID = i.ID
GROUP BY i.Institution
ORDER BY NumPublications DESC
LIMIT 20;

-- Answer:
/*
institution        | numpublications 
---------------------------+-----------------
 orcid.org                 |             886
 scholar.google.com        |             514
 www.wikidata.org          |             477
 dl.acm.org                |             446
 zbmath.org                |             442
 mathgenealogy.org         |             401
 en.wikipedia.org          |             333
 mathscinet.ams.org        |             277
 id.loc.gov                |             235
 d-nb.info                 |             209
 isni.org                  |             159
 viaf.org                  |             119
 awards.acm.org            |              59
 www.scopus.com            |              48
 ieeexplore.ieee.org       |              45
 www1.cs.columbia.edu      |              45
 csd.cmu.edu               |              42
 www.cs.cmu.edu            |              42
 www.wisdom.weizmann.ac.il |              40
 www-2.cs.cmu.edu          |              37
(20 rows)
*/

SELECT i.Institution, COUNT(DISTINCT ad.PubID) AS NumPublications
FROM PODS AS po
INNER JOIN Publication AS p ON po.PubKey = p.PubKey
INNER JOIN Authored AS ad ON p.PubID = ad.PubID
INNER JOIN Insti AS i ON ad.ID = i.ID
GROUP BY i.Institution
ORDER BY NumPublications DESC
LIMIT 20;

-- Answer:
/*
 institution        | numpublications 
---------------------------+-----------------
 orcid.org                 |             359
 dl.acm.org                |             298
 scholar.google.com        |             268
 www.wikidata.org          |             221
 mathscinet.ams.org        |             120
 d-nb.info                 |             116
 mathgenealogy.org         |             110
 zbmath.org                |              99
 id.loc.gov                |              90
 en.wikipedia.org          |              62
 openlibrary.org           |              35
 twitter.com               |              33
 ieeexplore.ieee.org       |              31
 benny.cs.technion.ac.il   |              30
 researcher.watson.ibm.com |              23
 isni.org                  |              20
 viaf.org                  |              20
 pages.cs.wisc.edu         |              18
 www.cs.cmu.edu            |              18
 marceloarenas.cl          |              17
(20 rows)
*/

DROP MATERIALIZED VIEW STOC CASCADE;
DROP MATERIALIZED VIEW PODS CASCADE;
DROP MATERIALIZED VIEW SOSP CASCADE;
DROP MATERIALIZED VIEW SIGMOD CASCADE;
DROP VIEW tmpPODS;
DROP VIEW tmpSIGMOD;
DROP VIEW Insti;