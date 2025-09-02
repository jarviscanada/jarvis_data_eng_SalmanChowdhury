-- Modifying Data

-- Q1: Insert some data into a table
INSERT INTO
	cd.facilities
VALUES
	(9, 'Spa', 20, 30, 100000, 800);

-- Q2: Insert calculated data into a table
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

-- Q3: Update some existing data
UPDATE cd.facilities
SET
	initialoutlay = 10000
WHERE
	facid = 1;

-- Q4: Update a row based on the contents of another row
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

-- Q5: Delete all bookings
DELETE FROM cd.bookings;

-- Q6: Delete a member from the cd.members table
DELETE FROM cd.members
WHERE
	memid = 37;

-- Basics

-- Q1: Control which rows are retrieved - part 2
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

-- Q2: Basic string searches
SELECT
	*
FROM
	cd.facilities
WHERE
	name ILIKE '%tennis%';

-- Q3: Matching against multiple possible values
SELECT
	*
FROM
	cd.facilities
WHERE
	facid IN (1, 5);

-- Q4: Working with dates
SELECT
	memid,
	surname,
	firstname,
	joindate
FROM
	cd.members
WHERE
	joindate >= '2012-09-01';

-- Q5: Combining results from multiple queries
SELECT
	surname
FROM
	cd.members
UNION
SELECT
	name
FROM
	cd.facilities;

	
-- Join

-- Q1: Retrieve the start times of members' bookings
SELECT
	bks.starttime
FROM
	cd.members AS mems
	INNER JOIN cd.bookings AS bks ON mems.memid = bks.memid
WHERE
	firstname = 'David'
	AND surname = 'Farrell';

-- Q2: Work out the start times of bookings for tennis courts
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

-- Q3: Produce a list of all members, along with their recommender
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

-- Q4: Produce a list of all members, along with their recommender
SELECT DISTINCT
	mem.firstname,
	mem.surname
FROM
	cd.members AS mem
	INNER JOIN cd.members AS rec ON rec.recommendedby = mem.memid
ORDER BY
	mem.surname,
	mem.firstname

-- Q5: Produce a list of all members, along with their recommender, using no joins.
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

-- Aggregation

-- Q1:	Count the number of recommendations each member makes.
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

-- Q2: List the total slots booked per facility
SELECT
	facid,
	SUM(slots) AS "Total Slots"
FROM
	cd.bookings
GROUP BY
	facid
ORDER BY
	facid;

-- Q3: List the total slots booked per facility in a given month
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

-- Q4: List the total slots booked per facility per month
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

-- Q5: Find the count of members who have made at least one booking
SELECT
	COUNT(*)
FROM
	(
		SELECT DISTINCT
			memid
		FROM
			cd.bookings
	);

-- Q6: List each member's first booking after September 1st 2012
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

-- Q7: Produce a list of member names, with each row containing the total member count
SELECT
	COUNT(*) OVER (),
	firstname,
	surname
FROM
	cd.members
ORDER BY
	joindate

-- Q8: Produce a numbered list of members
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

-- Q9: Output the facility id that has the highest number of slots booked, again
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

-- String

-- Q1: 
SELECT
	surname || ', ' || firstname AS name
FROM
	cd.members;

-- Q2: Find telephone numbers with parentheses
SELECT
	memid,
	telephone
FROM
	cd.members
WHERE
	telephone ~ '[()]';

-- Q3: Count the number of members whose surname starts with each letter of the alphabet
select substr(mems.surname,1,1) as letter, count(*) as count
    from cd.members mems
    group by letter
    order by letter

