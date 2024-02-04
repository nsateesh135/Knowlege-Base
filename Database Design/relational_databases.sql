/*  Database : Postgresql */
/* To extract metadata about tables from the database */
SELECT table_schema, table_name
FROM information_schema.tables;

/* To extract metadata about columns in a table of a database */
SELECT table_name,column_name,data_type
FROM information_schame.columns;


/* Create a new table */
CREATE TABLE <TABLE_NAME> (
    name_of_field <data_type>
    clouds text, 
    temperature numeric,
    weather_station char(5));


/* Add columms to an exsisting table */
ALTER TABLE <table_name>
ADD COLUMN <column_name> <data_type>;

/* Rename a particular column in a table*/
ALTER TABLE <table_name>
RENAME COLUMN old_name TO new_name;

/* Drop column from an exsisting database */
ALTER TABLE <table_name>
DROP COLUMN <column_name>;

/* Alter table columns after table has been created*/
ALTER TABLE <table_name>
ALTER COLUMN name 
TYPE varchar(128);

ALTER TABLE students
ALTER COLUMN average_grade
TYPE integer
-- Turns 5.54 into 6 not 5 
USING ROUND(avergae_grade)

/* Adding not null constraint to an exsisting table*/

ALTER TABLE <table_name>
ALTER COLUMN <column_name>
SET NOT NULL;


ALTER TABLE <table_name>
ALTER COLUMN <column_name>
DROP NOT NULL;

ALTER TABLE <table_name>
ADD CONSTRAINT some_name UNIQUE(column_name);

/* Inserting data into tables*/ 
INSERT INTO <table_name> (column_a, column_b)
VALUES("value_a","value_b")


/* To delete a tables from the database*/
DROP TABLE <name_of_the_table>

/* cast value from one datatype to another */
SELECT CAST(some_column as integer) FROM table;

/* 
Most common data types 
text, varchar[(x)]: a maximum number of n characters, char[(x)]: a fixed length string of n characters, boolean
date, time,timestamp, numeric: arbitary precsion number (3.1456), integer
*/

CREATE TABLE <table_name>(
    <column_name> integer,
    <column_name> varchar(64),
    <column_name> dob data,
    <column_name> numeric (3,2), /*Total of 3 digits wuth a precsion of 2 (3.142) */
)

/* The not null and unique constraints
not null : The present and future values of the fields can't be null or unknown
 */

CREATE TABLE students(

    ssn integer not null,
    lastname varchar(64) not null,
    home_phone integer,
    office_phone integer
)

/* unique constraint */

CREATE TABLE table_name(
    column_name UNIQUE
);


/* Keys 
Attributes that identify a record uniquely
As long as attributes can be removed: superkey
If no more attributes can be removed: minimal superkey or key

Steps to examine a superkey
1. count the distinct records for all possible combinations of columns. 
    If the resulting number x = 
   the number of all the rows in the table, that is the super key
2. Then remove one column after another until you can no longer 
   remove columns without seeing the number x decrease
   this would be a candidate key
*/

/* Primary Keys
1. One primary key is chosen from candidate keys
2. Uniquely identifies records
3. Unique and not null constraints both apply
4. Are time variant : never change over time
*/

CREATE TABLE <table_name>(
    <column_name> INTEGER PRIMARY KEY
);

CREATE TABLE <table_name>(
    a INTEGER,
    b INTEGER,
    c INTEGER
    PRIMARY KEY (a,b)
);

ALTER TABLE <table_name>
ADD CONSTRAINT <name_of_constraint> PRIMARY KEY (<column_name>)

/* SURROGATE KEY (kind of primary key)
When a single column can't identify as a PRIMARY KEY 
we can use a combination of columns or create a new column(serial). 
this is called surrogate key 

In Postgresql the way we can do this is using a serial data type which squentially increments a number based on number of records
written to the table
*/

ALTER TABLE cars 
ADD COLUMN id serial PRIMARY KEY;

/* If key(id) = (1) already exsists, this error is when we try to write to a table  which has already allocated serial 
value 1 to another roe */

/* Surrogate key as a combination of 2 columns */

ALTER TABLE <table_name>
ADD COLUMN column_c varchar(256);

UPDATE <table_nane>
SET column_c = CONCAT(<column_a>,<column_b>);

ALTER TABLE <table_name>
ADD CONSTRAINT pk PRIMARY KEY (column_c);



/* Foregin Key
1. Points to primary key of another table 
2. Domain of FK must be equal to Domain of PK
3. Each value of FK must exsist in PK of other table 
    thats why foreign contraint = referencial integrity
4. FK are not actual keys as they can have null values
*/

/* When we try to insert data into cars table, only manufactures which exisit in manufacturers table is allowed */
CREATE TABLE manufacturers(
name varchar(255) PRIMARY KEY
)
CREATE TABLE cars(
    model varchar(255) PRIMARY KEY,
    manufacturer_name varchar(255) REFERENCES manufacturers (name)
);

/*  Adding foreign key to an exsisting table  */
ALTER TABLE a 
ADD CONSTRAINT a_fkey FOREIGN KEY (b_id) REFERENCES b (id)


/*  Implementing N:M relationships 
    like one professor can belong to multiple universities 
    and one university can have multiple professors

    Example: 
    1. Create a new table
    2. Add foreign keys for every connected table
    3. Add additional attributes 
    4. No primary key, 
    possible PK = {professor_id,organization_id,function}
*/

CREATE TABLE affliations(

    professor_id integer REFERENCES professors(id),
    organization_id varchar(256) REFERENCES organizations (id),
    function varchar(256)
)

/* Update a particular column value in an exsisting table */
UPDATE affiliations
SET professor_id = professors.id
FROM professors
WHERE affiliations.firstname = professors.first_name AND affliations.lastname = professors.lastname;


/* Referencial integrity 
Referencial integrity from table A to table B is violated if
1. a record in table B that is referenced from a record in table A 
  is deleted
2. a record in table A refrencing a non-exsisting 
record from table B is inserted

Dealing with violations 
1. By default ON DELETE NO ACTION is enforced 
2. We can opt for ON DELETE CASCADE which deletes all referencing records

OTHER OPTIONS :
1. RESTRICT : Thow an error
2. SET NULL : Set referencing column to NULL
3. SET DEFAULT: Set the referencing column to its default value
*/

CREATE TABLE <table_name>(
    id integer PRIMARY KEY 
    b_id integer REFERENCES b (id) ON DELETE NO ACTION 
)

CREATE TABLE <table_name>(
    id integer PRIMARY KEY 
    b_id integer REFERENCES b (id) ON DELETE CASCADE


-- Identify the correct constraint name
SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY';

-- Drop the right foreign key constraint
ALTER TABLE affiliations
DROP CONSTRAINT affiliations_organization_id_fkey;

-- Add a new foreign key constraint from affiliations to organizations which cascades deletion
ALTER TABLE affiliations
ADD CONSTRAINT affiliations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES organizations (id) ON DELETE CASCADE;

-- Delete an organization 
DELETE FROM organizations 
WHERE id = 'CUREM';

-- Check that no more affiliations with this organization exist
SELECT * FROM affiliations
WHERE organization_id = 'CUREM';