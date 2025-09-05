# Introduction

This project demonstrates foundational SQL skills through hands-on practice with a country club database system. The database contains three main entities: members, facilities, and bookings, designed to track facility usage and member activity at a fictional country club. Through a series of progressive SQL queries, this project explores essential database operations including data retrieval, joins, aggregations, and window functions.

The primary users of this system would be club administrators and managers who need to analyze membership data, facility utilization, and booking patterns to make informed business decisions. The project utilizes PostgreSQL as the database engine, running in a Docker container for consistent development environment management. Additional technologies include pgAdmin for database administration, Git for version control, and Linux command-line tools for system management.

This exercise serves as practical preparation for real-world data engineering scenarios, particularly relevant for working with financial institutions where complex data relationships and analytical queries are essential for business intelligence and reporting systems.

# SQL Queries

###### Table Setup (DDL)

### Overview
Created a PostgreSQL database schema for a country club management system with members, facilities, and booking functionality.

#### Schema Setup
```sql
-- Create the schema namespace
CREATE SCHEMA cd;
```

### Tables Created

#### 1. Members Table
```sql
CREATE TABLE cd.members
(
   memid integer NOT NULL, 
   surname varchar(200) NOT NULL, 
   firstname varchar(200) NOT NULL, 
   address varchar(300) NOT NULL, 
   zipcode integer NOT NULL, 
   telephone varchar(20) NOT NULL, 
   recommendedby integer,
   joindate timestamp NOT NULL,
   CONSTRAINT members_pk PRIMARY KEY (memid),
   CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
        REFERENCES cd.members(memid) ON DELETE SET NULL
);
```
- **Self-referencing foreign key**: `recommendedby` references `memid` in same table
- **ON DELETE SET NULL**: Prevents orphaned references when recommender is deleted

#### 2. Facilities Table
```sql
CREATE TABLE cd.facilities
(
   facid integer NOT NULL, 
   name varchar(100) NOT NULL, 
   membercost numeric NOT NULL, 
   guestcost numeric NOT NULL, 
   initialoutlay numeric NOT NULL, 
   monthlymaintenance numeric NOT NULL, 
   CONSTRAINT facilities_pk PRIMARY KEY (facid)
);
```
- Tracks bookable facilities with member/guest pricing
- Includes financial tracking (initial cost, monthly maintenance)

#### 3. Bookings Table
```sql
CREATE TABLE cd.bookings
(
   bookid integer NOT NULL, 
   facid integer NOT NULL, 
   memid integer NOT NULL, 
   starttime timestamp NOT NULL,
   slots integer NOT NULL,
   CONSTRAINT bookings_pk PRIMARY KEY (bookid),
   CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
   CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
);
```
- Links members to facility bookings
- Uses 30-minute time slots for booking duration

##### Modifying Data

###### Question 1: Insert some data into a table

```sql
INSERT INTO
	cd.facilities
VALUES
	(9, 'Spa', 20, 30, 100000, 800);
```

###### Question 2: Insert calculated data into a table

```sql
INSERT INTO
	cd.facilities (
		facid,
		name,
		membercost,
		guestcost,
		initialoutlay,
		monthlymaintenance
	)
SELECT
	(
		SELECT
			MAX(facid)
		FROM
			cd.facilities
	) + 1,
	'Spa',
	20,
	30,
	100000,
	800;
```

###### Question 3: Update some existing data
```sql
UPDATE cd.facilities
SET
	initialoutlay = 10000
WHERE
	facid = 1;
```

###### Question 4: Update a row based on the contents of another row
```sql
UPDATE cd.facilities
SET
	membercost = (
		SELECT
			membercost * 1.1
		FROM
			cd.facilities
		WHERE
			facid = 0
	),
	guestcost = (
		SELECT
			guestcost * 1.1
		FROM
			cd.facilities
		WHERE
			facid = 0
	)
WHERE
	facid = 1;
```

###### Question 5: Delete all bookings
```sql
DELETE FROM cd.bookings;
```

###### Question 6: Delete a member from the cd.members table
```sql
DELETE FROM cd.members
WHERE
	memid = 37;
```

##### Basics

###### Q1: Control which rows are retrieved - part 2
```sql
SELECT
	facid,
	name,
	membercost,
	monthlymaintenance
FROM
	cd.facilities
WHERE
	membercost > 0
	AND membercost < monthlymaintenance / 50;
```

###### Q2: Basic string searches
```sql
SELECT
	*
FROM
	cd.facilities
WHERE
	name ILIKE '%tennis%';
```

###### Q3: Matching against multiple possible values
```sql  
SELECT
	*
FROM
	cd.facilities
WHERE
	facid IN (1, 5);
```

###### Q4: Working with dates
```sql  
SELECT
	memid,
	surname,
	firstname,
	joindate
FROM
	cd.members
WHERE
	joindate >= '2012-09-01';
```

###### Q5: Combining results from multiple queries
```sql  
SELECT
	surname
FROM
	cd.members
UNION
SELECT
	name
FROM
	cd.facilities;
```

##### Join

###### Q1: Retrieve the start times of members' bookings
```sql
SELECT
	bks.starttime
FROM
	cd.members AS mems
	INNER JOIN cd.bookings AS bks ON mems.memid = bks.memid
WHERE
	firstname = 'David'
	AND surname = 'Farrell';
```

###### Q2: Work out the start times of bookings for tennis courts
```sql
SELECT
	bks.starttime AS start,
	fac.name
FROM
	cd.bookings AS bks
	INNER JOIN cd.facilities AS fac ON bks.facid = fac.facid
WHERE
	fac.name IN ('Tennis Court 1', 'Tennis Court 2')
	AND bks.starttime >= '2012-09-21'
	AND bks.starttime < '2012-09-22'
ORDER BY
	bks.starttime ASC;
```

###### Q3: Produce a list of all members, along with their recommender
```sql
SELECT
	mem.firstname AS memfname,
	mem.surname AS memsname,
	rec.firstname AS recfname,
	rec.surname AS recsname
FROM
	cd.members AS mem
	LEFT JOIN cd.members AS rec ON rec.memid = mem.recommendedby
ORDER BY
	memsname,
	memfname;
```

###### Q4: Produce a list of all members, along with their recommender
```sql
SELECT DISTINCT
	mem.firstname,
	mem.surname
FROM
	cd.members AS mem
	INNER JOIN cd.members AS rec ON rec.recommendedby = mem.memid
ORDER BY
	mem.surname,
	mem.firstname
```

###### Q5: Produce a list of all members, along with their recommender, using no joins.
```sql
SELECT DISTINCT
	mems.firstname || ' ' || mems.surname AS member,
	(
		SELECT
			recs.firstname || ' ' || recs.surname AS recommender
		FROM
			cd.members AS recs
		WHERE
			recs.memid = mems.recommendedby
	)
FROM
	cd.members AS mems
ORDER BY
	member;
```

##### Aggregation

###### Q1: Count the number of recommendations each member makes.
```sql
SELECT
	recommendedby,
	COUNT(*)
FROM
	cd.members
WHERE
	recommendedby IS NOT NULL
GROUP BY
	recommendedby
ORDER BY
	recommendedby ASC;
```

###### Q2: List the total slots booked per facility
```sql
SELECT
	facid,
	SUM(slots) AS "Total Slots"
FROM
	cd.bookings
GROUP BY
	facid
ORDER BY
	facid;
```

###### Q3: List the total slots booked per facility in a given month
```sql
SELECT
	facid,
	SUM(slots) AS "Total Slots"
FROM
	cd.bookings
WHERE
	starttime >= '2012-09-01'
	AND starttime < '2012-10-01'
GROUP BY
	facid
ORDER BY
	SUM(slots);
```

###### Q4: List the total slots booked per facility per month
```sql
SELECT
	facid,
	EXTRACT(
		MONTH
		FROM
			starttime
	) AS MONTH,
	SUM(slots) AS "Total Slots"
FROM
	cd.bookings
WHERE
	EXTRACT(
		YEAR
		FROM
			starttime
	) = 2012
GROUP BY
	facid,
	MONTH
ORDER BY
	facid,
	MONTH;
```

###### Q5: Find the count of members who have made at least one booking 
```sql
SELECT
	COUNT(*)
FROM
	(
		SELECT DISTINCT
			memid
		FROM
			cd.bookings
	);
```

###### Q6: List each member's first booking after September 1st 2012
```sql
SELECT
	mems.surname,
	mems.firstname,
	mems.memid,
	MIN(bks.starttime) AS starttime
FROM
	cd.bookings bks
	INNER JOIN cd.members mems ON mems.memid = bks.memid
WHERE
	starttime >= '2012-09-01'
GROUP BY
	mems.memid
ORDER BY
	mems.memid;
```

###### Q7: Produce a list of member names, with each row containing the total member count
```sql
SELECT
	COUNT(*) OVER (),
	firstname,
	surname
FROM
	cd.members
ORDER BY
	joindate
```

###### Q8: Produce a numbered list of members
```sql
SELECT
	ROW_NUMBER() OVER (
		ORDER BY
			joindate
	),
	firstname,
	surname
FROM
	cd.members
ORDER BY
	joindate
```

###### Q9: Output the facility id that has the highest number of slots booked, again
```sql
SELECT
	facid,
	total
FROM
	(
		SELECT
			facid,
			SUM(slots) total,
			RANK() OVER (
				ORDER BY
					SUM(slots) DESC
			) rank
		FROM
			cd.bookings
		GROUP BY
			facid
	) AS ranked
WHERE
	rank = 1
```

##### String

###### Q1: 
```sql
SELECT
	surname || ', ' || firstname AS name
FROM
	cd.members;
```

###### Q2: Find telephone numbers with parentheses
```sql
SELECT
	memid,
	telephone
FROM
	cd.members
WHERE
	telephone ~ '[()]';
```

###### Q3: Count the number of members whose surname starts with each letter of the alphabet
```sql
select substr(mems.surname,1,1) as letter, count(*) as count 
    from cd.members mems
    group by letter
    order by letter  
```

