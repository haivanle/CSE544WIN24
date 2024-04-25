# CSE 544 Homework 1: Data Analytics Pipeline

**Objectives:** To get familiar with the main components of the data analytic pipeline: schema design, data acquisition, data transformation, and querying.

**Assignment tools:** postgres

**Assigned date:** January 3, 2024

**Due date:** January 19, 2024

**Questions:**  on the [Ed discussion board](https://edstem.org/us/dashboard).

**What to turn in:** These files:`pubER.pdf`, `createPubSchema.sql`, `exploratory_queries.sql`, `importPubData.sql`, `analytic_queries.sql`. Your `[filename].sql` files should be executable using the command `psql -f [filename].sql`

Turn in your solution on [CSE's GitLab](https://gitlab.cs.washington.edu). 
See [general instructions](https://gitlab.cs.washington.edu/cse544-2024wi/cse544-2024wi/-/tree/main/hw?ref_type=heads).  Specific instructions for this homework are below, at the end of thid document.


**Motivation:** In this homework you will implement a basic data
analysis pipeline: data acquisition, transformation and extraction,
cleaning, and analysis.  The data is
[DBLP](https://dblp.org/), the reference
citation website created and maintained by Michael Ley. The data definition, manipulation, and analysis will be done in postgres.


**Resources:**

- [postgres](https://www.postgresql.org/)

- starter code



# Problems

## Problem 0: Download Postgres
For this homework assignment, you're going to need a working version of postgres on your local machine. Postgres is an open-source SQL database managment system which is used by millions of people around the world! 

You'll start by downloading postgres [here](https://www.postgresql.org/download/). The download page will provide instructions specific to your OS (remember that if you're using WSL, then your OS is Linux/Ubuntu rather than Windows), but you want to make sure that you're downloading version 16, the latest stable version.

By the end of this, you should be able to successfully run the following two commands,
```sh
createdb --help
psql --help
```
These commands should just provide a list of options, but they confirm that you're able to run these functions.

## Problem 1: Conceptual Design

Design and create a database schema about publications.  We will refer to this schema as `PubSchema`, and to the data as `PubData`.
- E/R Diagram. Design the E/R diagram, consisting of the entity sets and relationships below. Draw the E/R diagram for this schema,  identify all keys in all entity sets, and indicate the correct type of all relationships (many-many or many-one); make sure you use the ISA box where needed.
  - `Author` has  attributes: `id` (a key; must be unique),  `name`, and `homepage` (a URL)
  - `Publication` has  attributes: `pubid` (the key -- an integer), `pubkey` (an alternative key, text; must be unique), `title`, and `year`. It has the following subclasses:
    - `Article` has additional attributes:  `journal`, `month`, `volume`, `number`
    - `Book`  has additional attributes:  `publisher`, `isbn`
    - `Incollection` has additional attributes:  `booktitle`, `publisher`, `isbn`
    - `Inproceedings` has additional attributes:  `booktitle`, `editor`
  - There is a many-many relationship `Authored` from `Author` to `Publication`
  - Refer to Chapter 2, "Introduction to Database Design," and Chapter 3.5, "Logical Database Design: ER to Relational" in R&G if you need additional references.

Feel free to create this schema in whatever software you are most familiar with, but Powerpoint or Google Slides would be a good starting place. We're grading on correctness not aesthetics, so no need to make it perfect just make sure that it's clear!

**Turn in** the file `pubER.pdf`

## Problem 2: Schema Design

Here you will create the SQL tables in a database in postgres.  First, check that you have installed postgres on your computer.  Then, create an empty database by running the following command:

```sh
$ createdb dblp
```

If you need to restart, then delete it by running:

```sh
$ dropdb dblp
```

To run queries in postgres, type:

```sh
$ psql dblp
```
then type in your SQL commands.  Remember three special commands:

```sh
\q -- quit psql
\h -- help
\? -- help for meta commands
```

Next, design the SQL tables that implement your conceptual schema (the E/R diagram).   We will call this database schema the  `PubSchema`.  Write `create Table` SQL statements, e.g.:

```sql
create Table Author (...);
...
```

Choose `int` and `text` for all data types.  Create keys, foreign
keys, and unique constraints, as needed; you may either do it within
`CREATE TABLE`, or postpone this for later and use `ALTER TABLE`.  Do
NOT use the `inherit` or `pivot` functionality in postgres, instead
use the simple design principles discussed in class.

Write all your commands in a file called  `createPubSchema.sql`.  You can execute them in two ways.  Start postgres interactively and copy/paste your commands one by one. Or, from the command line run:

```sh
psql -f createPubSchema.sql dblp
```

Hint: for debugging purposes, insert `drop Table` commands at the beginning of the `createPubSchema.sql` file:

```sql
drop table if exists Author;
...
```

**Turn in** the file  `createPubSchema.sql`.


## Problem 3: Data Acquisition

Typically, this step consists of downloading data, or extracting it with a
software tool, or inputting it manually, or all of the above.  Then it involves
writing and running some python script, called a *wrapper* that
reformats the data into some CSV format that we can upload to the database.

Download the DBLP data `dblp.dtd` and `dblp.xml.gz` from the dblp [website](http://dblp.uni-trier.de/xml/), then unzip the xml file.
Make sure you understand what data the  the big xml file contains: look inside by running:

```sh
more dblp.xml
```

If needed, edit the `wrapper.py` and update the   correct  location of `dblp.xml` and the output files `pubFile.txt`  and  `fieldFile.txt`, then run:

```sh
python wrapper.py
```

This will take several minutes, and produces two large files: `pubFile.txt` and `fieldFile.txt`. Before you proceed, make sure you understand what happened during this step, by looking inside these two files: they are tab-separated files, ready to be imported in postgres.

Next, edit the file `createRawSchema.sql` in the starter code to point to the correct path of `pubFile.txt` and `fieldFile.txt`: they  must be absolute paths, e.g. `/home/myname/mycourses/544/pubFile.txt`.   Then run:

```sh
psql -f createRawSchema.sql dblp
```

This creates two tables, `Pub` and `Field`, then imports the data (which may take a few minutes).  We will call these two tables `RawSchema` and  `RawData` respectively.


## Problem 4: Querying the Raw Data

During typical data ingestion, you sometimes need to discover the true schema of the data, and for that you need to query the  `RawData`.

Start `psql` then type the following commands:

```sql
select * from Pub limit 50;
select * from Field limit 50;
```

For example, go to the dblp [website](http://dblp.uni-trier.de/), check out this paper, search for `Henry M. Levy`, look for the "Vanish" paper, and export the entry in BibTeX format.  You should see the following in your browser

```bibtex
@inproceedings{DBLP:conf/uss/GeambasuKLL09,
  author    = {Roxana Geambasu and
               Tadayoshi Kohno and
               Amit A. Levy and
               Henry M. Levy},
  title     = {Vanish: Increasing Data Privacy with Self-Destructing Data},
  booktitle = {18th {USENIX} Security Symposium, Montreal, Canada, August 10-14,
               2009, Proceedings},
  pages     = {299--316},
  year      = {2009},
  crossref  = {DBLP:conf/uss/2009},
  url       = {http://www.usenix.org/events/sec09/tech/full_papers/geambasu.pdf},
  timestamp = {Thu, 15 May 2014 18:36:21 +0200},
  biburl    = {http://dblp.org/rec/bib/conf/uss/GeambasuKLL09},
  bibsource = {dblp computer science bibliography, http://dblp.org}
}
```


The **key** of this entry is `conf/uss/GeambasuKLL09`.  Try using this info by running this SQL query:

```sql
select * from Pub p, Field f where p.k='conf/uss/GeambasuKLL09' and f.k='conf/uss/GeambasuKLL09'
```


Write SQL Queries  to answer the following  questions using `RawSchema`:

- For each type of publication, count the total number of publications of that type. Your query should return a set of (publication-type, count) pairs. For example (article, 20000), (inproceedings, 30000), ... (not the real answer).

- We say that a field *occurs* in a publication type, if there exists at least one publication of that type having that field. For example, `publisher` occurs in `incollection`, but `publisher` does not occur in `inproceedings`. Find the fields that occur in *all* publications types. Your query should return a set of field names: for example it may return title, if  title occurs in all publication types (article, inproceedings, etc. notice that title does not have to occur in every publication instance, only in some instance of every type), but it should not return publisher (since the latter does not occur in any publication of type inproceedings).

- Your two queries above may be slow. Speed them up by creating appropriate indexes, using the CREATE INDEX statement. You also need indexes on `Pub` and `Field` for the next question; create all indices you need on `RawSchema`

**Turn in** a file  `exploratory_queries.sql` consising of SQL queries and all their answers inserted as comments


## Problem 5: Data Transformation.

Next, you will transform the DBLP data from `RawSchema` to  `PubSchema`.  This step is sometimes done using an ETL tool, but we will just use several SQL queries.  You need to write queries to  populate the tables in `PubSchema`. For example, to populate `Article`, you will likely run a SQL query like this:

```sql
insert into Article (select ... from Pub, Field ... where ...);
```

The `RawSchema` and `PubSchema` are quite different, so you will need to go through some trial and error to get the transformation right.  Here are a few hints (but your approach may vary):

- create temporary tables (and indices) to speedup the data transformation. Remember to drop all your temp tables when you are done

- it is very inefficient to bulk insert into a table that contains a key and/or foreign keys (why?); to speed up, you may drop the key/foreign key constraints, perform the bulk insertion, then `alter Table` to create the constraints.

- `PubSchema` requires an  integer key for each author and each publication. Use a `sequence` in postgres. For example, try this and see what happens:

```sql
create table R(a text);
insert into R values ('a');
insert into R values ('b');
insert into R values ('c');
create table S(id int, a text);
create sequence q;
insert into S (select nextval('q') as id, a from R);
drop sequence q;
select * from S;
```
- DBLP knows the Homepage of some authors, and you need to store these in the Author table. But where do you find homepages in `RawData`? DBLP uses a hack. Some publications of type `www` are not publications, but instead represent homepages. For example Hank's official name in DBLP is 'Henry M. Levy'; to find his homepage, run the following query (this  should run  very fast,  1 second or less, if you created the right indices):

```sql
select z.* from Pub x, Field y, Field z where x.k=y.k and y.k=z.k and x.p='www' and y.p='author' and y.v='Henry M. Levy';
```

Get it? Now you know Hank's homepage. However, you are not there yet. Some www entries are not homepages, but are real publications. Try this:

```sql
select z.* from Pub x, Field y, Field z where x.k=y.k and y.k=z.k and x.p='www' and y.p='author' and y.v='Dan Suciu'
```

Your challenge is to find out how to identify each author's correct Homepage. (A small number of authors have two correct, but distinct homepages; you may choose any of them to insert in Author)

- What if a publication in `RawData` has two titles? Or two `publishers`? Or two `years`? (You will encounter duplicate fields, but not necessarily these ones.) You may pick any of them, but you need to work a little to write this in SQL.

**Turn in** the file `importPubData.sql` containing several `insert`, `create Table`, `alter Table`, etc  statements.

## Problem 6: Run Data Analytic Queries

Finally, you can enjoy the fruits of your labors! Write SQL queries to answer the following questions using the schema that you designed:

- Find the top 20 authors with the largest number of publications. (Runtime: under 10s)

- Find the top 20 authors with the largest number of publications in STOC. Repeat this for two more conferences, of your choice.  Suggestions: top 20 authors in SOSP, or CHI, or SIGMOD, or SIGGRAPH; note that you need to do some digging to find out how DBLP spells the name of your conference. (Runtime: under 10s.)

- The two major database conferences are 'PODS' (theory) and 'SIGMOD Conference' (systems). Find
    - (a). all authors who published at least 10 SIGMOD papers but never published a PODS paper, and 
    - (b). all authors who published at least 5 PODS papers but never published a SIGMOD paper. (Runtime: under 10s)

- Find the institutions that have published most papers in STOC; return the top 20 institutions. Then repeat this query with your favorite conference (SOSP or CHI, or ...), and find out which institutions are most prolific. Hint: where do you get information about institutions? Use the Homepage information: convert a Homepage like <http://www.cs.washington.edu/homes/levy/> to <http://www.cs.washington.edu>, or even to www.cs.washington.edu; now you have grouped all authors from our department, and we can use this URL as a surrogate for the institution. To get started with substring manipulation in postgres, you can start by looking up the functions `substring`, `position`, and `trim` in the [postgres manual](https://www.postgresql.org/docs/16/index.html).


**Turn in** SQL queries in the file called `analytic_queries.sql`.


## Your submission should look like this

You may submit your code multiple times, and we will use the latest version that arrives before the deadline. Put all your files(`pubER.pdf`, `createPubSchema.sql`, `exploratory_queries.sql`, `importPubData.sql`, `analytic_queries.sql`) in `hw1/submission`. Your directory structure should look like this after you have completed the assignment: 

```sh
cse544-[your CSE or UW username]
\-- README.md
\-- turnInHW.sh     # script for turning in hw
\-- hw1
    \-- hw1.md      # this is the file that you are currently reading
    \-- submission
        \-- pubER.pdf  # your solution to question 1
        \-- createPubSchema.sql  # your solution to question 2
        \-- exploratory_queries.sql # you solution to question 4
        \-- importPubData.sql # your solution to question 5
        \-- analytic_queries.sql  # your solution to question 6
```
