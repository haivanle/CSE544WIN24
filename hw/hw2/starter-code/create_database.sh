export SNOWSQL_USER="" # Change to your snowflake username
export SNOWSQL_ACCOUNT="XXXXXX-XXXXXX" # Change to your snowflake account id (XXXXXXX-XXXXXXXX)
export SNOWSQL_PWD="" # Change to your snowflake password
export SNOWSQL_WAREHOUSE="" # Change to the warehouse you created in Step 3
export SNOWSQL_DATABASE="imdb" # Change to whatever database name you chose
export SNOWSQL_SCHEMA="public" # This shouldn't require a change.

tables=("aka_name aka_title cast_info char_name comp_cast_type company_name company_type complete_cast info_type keyword kind_type link_type movie_companies movie_info movie_info_idx movie_keyword movie_link name person_info role_type title")
imdb_files_directory=/Users/haivanle/cse544-levh/hw/hw2/IMDB  # Change to the file path holding the IMDB .csv files 

snowsql -q "Create or replace FILE FORMAT IMDB_CSV TYPE = CSV Field_Delimiter = ',' FIELD_OPTIONALLY_ENCLOSED_BY = '\"' escape=none escape_unenclosed_field=none;"

for table in $tables;
do
    snowsql -q "create or replace stage $table;"
    snowsql -q "put file://$imdb_files_directory/$table.csv @$table;"
    snowsql -q "copy into $table from @$table FILE_FORMAT = IMDB_CSV;"
done
