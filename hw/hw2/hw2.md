# Homework 2

## Objectives:
  -  Practice using a modern cloud database system.

## Assigned date:
  - Jan 24, 2021

## Due date:
  - Feb 7, 2021

## Assignment tools:
  - <a href="https://signup.snowflake.com/?trial=student">Snowflake</a>!
  - Some graphing software (excel, etc.)

## What to turn in:
You will turn in:
  - Answers for the queries where relevant (`part_4_answers.pdf`, `part_5_answers.pdf`)
  - SQL for the queries (`part_4_solutions.sql`)

## How to submit the assignment:

In your GitLab repository you should see a directory called `hw/hw2/submission/`. Put your report in that directory. Remember to commit and push your report to GitLab (`git add && git commit && git push`)!

# Assignment Overview
At a high level, this assignment will ask you to do three things:
1. Become familiar with using the command line & web interface to access a cloud database provider (specifically Snowflake)
2. Ingest a dataset (IMDB) onto a cloud database
3. Perform data analysis and visualization to answer questions about this dataset

# Assignment Details

## 1. Setting up your Snowflake account (0 points)
  - Activate your Snowflake account by going <a href="https://signup.snowflake.com/?trial=student">here</a>
    - Use @uw.edu email
    - Set company to "University of Washington Student"

  <img src="starter-code/account_setup_1.png" alt="page 1" width="300"/>

  <img src="starter-code/account_setup_2.png" alt="page 2" width="300"/>

  - You should recieve an account activation email; follow the prompt
  <!-- - IMPORTANT: ensure that that correct role -- named "[Your UW NetID]Role" -- is shown in the upper-righthand corner of the Snowflake console.  Let us know on edstem/email if you do not see it (or are in the "Public" role)  -->
  - Optional: follow the "Getting Started" tutorial and familiarize yourself with the Snowflake interface

    This should result in free trial account with 400 credits of compute/storage available.

**Important** You will need your account ID, username (different from account ID), and password later on, so make sure to note them down.  

## 2. Download the SnowSQL command line interface
Because the web interface of Snowflake doesn't allow for bulk data download, we will need to install and get comfortable with the command line interface. The installer can be found [here](https://developers.snowflake.com/snowsql/) for various systems.

If you are using WSL or a standard linux terminal, you can download the installer using `wget` and run installation using `bash`, i.e.
```sh
wget https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.2/linux_x86_64/snowsql-1.2.31-linux_x86_64.bash
bash snowsql-1.2.31-linux_x86_64.bash
```
Once this is installed, open a new terminal and the following command should run,
```sh
snowsql -a [account_id] -u [username]
```
If this ran correctly, then you are now in the Snowflake CLI! From here, you can do things like create databases, define tables, upload data, etc..


## 3. Ingest data (10 points)

### Allocating compute resources
In the cloud database model, compute and storage are separate resources which need to be independently allocated. So, before we start allocating storage for our database, we are going to allocate a server to process our data. In the language of Snowflake, a compute server is called a "warehouse", so we can run the following command to request one,

```sh
create or replace warehouse [warehouse_name] with WAREHOUSE_SIZE="XSmall";
```

This will begin charging your account for the use of that server (1 credit per hour), so make sure to suspend it when you're not using it with, 
```sh 
alter warehouse [warehouse_name] suspend;
```
When you come back to it, you can run the following to connect back to it,
```sh
alter warehouse [warehouse_name] resume;
use warehouse [warehouse_name];
```

### Defining a database
Now that we have a compute server, we're going to begin defining our database. Because you did the hard work coming up with a schema last time, this time we are going to give you the schema. Before you run the following commands, take a look through them and make sure you understand the structure of the tables!

Broadly, this database stores information about films, actors, movie companies, etc., although it primarily has data from 2015 and earlier.

```sh
create or replace database IMDB;

create or replace table aka_name (
    id integer NOT NULL PRIMARY KEY,
    person_id integer NOT NULL,
    name text NOT NULL,
    imdb_index character varying(12),
    name_pcode_cf character varying(5),
    name_pcode_nf character varying(5),
    surname_pcode character varying(5),
    md5sum character varying(32)
);

create or replace table aka_title (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    title text NOT NULL,
    imdb_index character varying(12),
    kind_id integer NOT NULL,
    production_year integer,
    phonetic_code character varying(5),
    episode_of_id integer,
    season_nr integer,
    episode_nr integer,
    note text,
    md5sum character varying(32)
);

create or replace table cast_info (
    id integer NOT NULL PRIMARY KEY,
    person_id integer NOT NULL,
    movie_id integer NOT NULL,
    person_role_id integer,
    note text,
    nr_order integer,
    role_id integer NOT NULL
);

create or replace table char_name (
    id integer NOT NULL PRIMARY KEY,
    name text NOT NULL,
    imdb_index character varying(12),
    imdb_id integer,
    name_pcode_nf character varying(5),
    surname_pcode character varying(5),
    md5sum character varying(32)
);

create or replace table comp_cast_type (
    id integer NOT NULL PRIMARY KEY,
    kind character varying(32) NOT NULL
);

create or replace table company_name (
    id integer NOT NULL PRIMARY KEY,
    name text NOT NULL,
    country_code character varying(255),
    imdb_id integer,
    name_pcode_nf character varying(5),
    name_pcode_sf character varying(5),
    md5sum character varying(32)
);

create or replace table company_type (
    id integer NOT NULL PRIMARY KEY,
    kind character varying(32) NOT NULL
);

create or replace table complete_cast (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer,
    subject_id integer NOT NULL,
    status_id integer NOT NULL
);

create or replace table info_type (
    id integer NOT NULL PRIMARY KEY,
    info character varying(32) NOT NULL
);

create or replace table keyword (
    id integer NOT NULL PRIMARY KEY,
    keyword text NOT NULL,
    phonetic_code character varying(5)
);

create or replace table kind_type (
    id integer NOT NULL PRIMARY KEY,
    kind character varying(15) NOT NULL
);

create or replace table link_type (
    id integer NOT NULL PRIMARY KEY,
    link character varying(32) NOT NULL
);

create or replace table movie_companies (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    company_id integer NOT NULL,
    company_type_id integer NOT NULL,
    note text
);

create or replace table movie_info (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    info_type_id integer NOT NULL,
    info text NOT NULL,
    note text
);

create or replace table movie_info_idx (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    info_type_id integer NOT NULL,
    info text NOT NULL,
    note text
);

create or replace table movie_keyword (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    keyword_id integer NOT NULL
);

create or replace table movie_link (
    id integer NOT NULL PRIMARY KEY,
    movie_id integer NOT NULL,
    linked_movie_id integer NOT NULL,
    link_type_id integer NOT NULL
);

create or replace table name (
    id integer NOT NULL PRIMARY KEY,
    name text NOT NULL,
    imdb_index character varying(12),
    imdb_id integer,
    gender character varying(1),
    name_pcode_cf character varying(5),
    name_pcode_nf character varying(5),
    surname_pcode character varying(5),
    md5sum character varying(32)
);

create or replace table person_info (
    id integer NOT NULL PRIMARY KEY,
    person_id integer NOT NULL,
    info_type_id integer NOT NULL,
    info text NOT NULL,
    note text
);

create or replace table role_type (
    id integer NOT NULL PRIMARY KEY,
    role character varying(32) NOT NULL
);

create or replace table title (
    id integer NOT NULL PRIMARY KEY,
    title text NOT NULL,
    imdb_index character varying(12),
    kind_id integer NOT NULL,
    production_year integer,
    imdb_id integer,
    phonetic_code character varying(5),
    episode_of_id integer,
    season_nr integer,
    episode_nr integer,
    series_years character varying(49),
    md5sum character varying(32)
);
```

The above schema mostly self explanatory, but has a couple of quirks which I want to point out here.

1. The `Title` table's `id` column is the unique identifier for a movie or an episode of a tv show. Other tables which reference a `movie_id` are referring to this value. The `Name` table serves a similar role for people and `person_id`'s.
2. The tables `movie_info` and `movie_info_idx` both hold information about films, and you'll note that they have the same schema. In essence, they're a partition of the movie information into two tables for efficiency (it's worth taking a second and thinking about how this could make the system more efficient!).


### Ingesting Data

For this assignment, we will be analyzing data about movies, actors, and companies (i.e. the IMDB dataset). You can download this data from the following google drive [link](https://drive.google.com/drive/folders/1zihAUf2K9gJWaJbWp599h6KdEp8YrKYt?usp=sharing) (this might take a couple of minutes). It should contain a single csv file for each table in the schema above.

At this point, we need to get the data into our snowflake database which will require a few steps, all of which will happen within the snowsql command line. We have provided a script, `create_database.sh`, which will automate the following steps, but it's important to take a look and make sure that you understand them: read the steps below, and check them in `create_database.sh`:

First, we have to define our input data format which tells the database how to read our data files,
```
Create or replace FILE FORMAT IMDB_CSV TYPE = CSV Field_Delimiter = "," FIELD_OPTIONALLY_ENCLOSED_BY = '"' escape=none escape_unenclosed_field=none;
```
The next few steps will have to be done for every table in the schema. We need to upload the data to a "staging area". This stage-then-upload pattern is meant to unify the different mechanisms for data ingestion (e.g. importing from an Amazon S3 bucket vs your desktop). Arguably, it is also representative of the small frustrations inherent in working with cloud databases. 
```
create or replace stage [table_name];

put file://[file_path] @[table_name];
```
At this point, we can upload our data to the table,
```
copy into [table_name] from @[table_name] FILE_FORMAT = IMDB_CSV;
```

Now that you know what it does, you can run `create_database.sh`. However, you will need to change the user, account id, password, warehouse, database, and imdb_directory fields at the top to match yours! 

## 4. Run Queries (40 points)

At this point, you have uploaded the data to your cloud database! This means that you can query it using either the command line (i.e. SnowSQL) or using the slightly nicer web interface for snowflake. The remainder of this homework is about using this data to answer interesting questions about movies. A couple of overall notes for this assignment at the top:
1. This dataset contains information about films, tv shows, and occassionally plays. We won't distinguish between these in the assignment and will just call all the entries movies.
2. There are a couple of tables that hold casting information in the database, but in this portion we will focus on the `cast_info` table. You will not need to reference the `complete_cast` table in any of the following questions.


Specifically, you're taking on the role of an up-and-coming movie director looking to make your big break, and you need to analyze the industry to put together the perfect blockbuster for the summer of 2015.

1. Every great director stands on the shoulders of giants, and you're no different. So, the first step on your journey is finding the tallest giant to stand on, and everyone knows the best directors are the most prolific. 
    
    a. Find the name of the director who has directed the most movies. (5 points)
    
    b. Find the 10 most frequent collaborators with that director. This means the 10 people that appear in cast info on the most movies directed by that director. (5 points)
    
    c. Find the year where this director produced the most movies. (5 points) 

2. Now that you have a role model, it's time to look for some movies that you can model your movie on, and everyone knows that the best movies are the most profitable.
    
    a. Create a view called `budget_table` which contains pairs of movie_id's and movie budgets. This is challenging because the movie budgets are stored as strings in `movie_info`. For simplicity, you only need to consider budgets which are listed in dollars, i.e. "$ XXXXXX". To get them stored as numbers, you'll likely need to make use of the `REGEXP_SUBSTR`, `REPLACE`, and `TO_NUMBER` functions. (5 points)
    
    b. Create a view called `gross_table` which contains pairs of movie_id's and movie gross revenues. This process for this should be very similar to part b. However, some movies have multiple gross revenues (i.e. the revenue as of 2008, 2010, 2012, etc.), and we just want the largest one. (5 points)
    
    c. Using the temporary views, find the top 10 most profitable movies (i.e. had the greatest `gross - budget` difference) (5 points)

3. The directorial style is settled, and a blatant ripoff of a successful concept has been scripted. The only thing left to do is cast the movie, after that you can let the assistant director handle the details (shooting, editing, etc.).  


    a. You've taken some acting lessons and gotten pretty good feedback, so you're considering casting yourself in the movie. Count the number of movies where the director is also an actor or actress to see how common it is. (5 points)

    b. To get a sense for how large the cast should be, find the average number of actors/actresses in each movie. (5 points)

4. BONUS QUESTION: Briefly describe the movie that you would produce based on your research above (2 points extra credit).

Please record the specific answers to these questions (where applicable) in `part_4_answers.pdf` and the sql which produces them in `part_4_solutions.sql`.

## 5. Visualizations (10 points)

In this section, we want you to complete the data analysis pipeline by producing some graphs. The choice of graph and graphing software is up to you, but it the main point of the graph should be clear. Excel, google sheets, and python are reasonable choices here.

1. Make a histogram of the cast size for each movie.

2. Choose an interesting trend to study over time in the data and make a graph which demonstrates this trend.

Please put these graphs and a couple of sentences explaining them in a file labeled `part_5_answers.pdf`.


## Submission Folder

At the end of this assignment, your submission folder should contain `part_4_answers.pdf`, `part_4_solutions.sql`, `part_5_answers.pdf`