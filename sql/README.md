# Introduction

# SQL Queries

###### Table Setup (DDL)

#### Overview
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

###### Question 1: Show all members 

```sql
SELECT *
FROM cd.members
```

###### Question 2: Lorem ipsum...

```sql
SELECT blah blah 
```

