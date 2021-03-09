/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name 
FROM Facilities
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) 
FROM Facilities
WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance 
FROM Facilities
WHERE membercost > 0 AND membercost < monthlymaintenance * 0.2;	

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * 
FROM Facilities
WHERE facid IN (1,5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT  name,
		monthlymaintenance,
		CASE WHEN monthlymaintenance > 100 THEN 'expensive'
		ELSE 'cheap' END AS type
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE memid = (SELECT MAX(memid) FROM Members);


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(m.firstname, m.surname) as name
FROM Bookings as b
LEFT JOIN Facilities as f
ON b.facid = f.facid
LEFT JOIN Members as m
ON b.memid = m.memid
WHERE f.name LIKE 'Tennis%' and m.memid != 0
ORDER BY m.firstname;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name, m.firstname ,
		CASE WHEN b.memid !=0 THEN f.membercost * b.slots
							ELSE f.guestcost * b.slots END AS revenue
FROM `Bookings` as b
LEFT JOIN `Members` as m
ON b.memid = m.memid
LEFT JOIN `Facilities` as f
ON b.facid = f.facid
WHERE starttime >= '2012-09-14 00:00:00' and starttime < '2012-09-15 00:00:00' 
  AND (CASE WHEN b.memid !=0 THEN f.membercost * b.slots
							ELSE f.guestcost * b.slots END) > 30
ORDER BY revenue DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT name, firstname , revenue
FROM (  SELECT f.name as name, m.firstname as firstname, CASE WHEN b.memid !=0 THEN f.membercost * b.slots
							ELSE f.guestcost * b.slots END AS revenue
	    FROM `Bookings` as b
	    LEFT JOIN `Members` as m
		ON b.memid = m.memid
		LEFT JOIN `Facilities` as f
		ON b.facid = f.facid
		WHERE starttime >= '2012-09-14 00:00:00' and starttime < '2012-09-15 00:00:00') t
WHERE revenue > 30
ORDER BY revenue DESC;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT name, sum(revenue) as revenue 
FROM
        (SELECT f.*, m.*, b.*, 
        CASE WHEN b.memid !=0 THEN f.membercost * b.slots
        ELSE f.guestcost * b.slots END AS revenue
        FROM `Bookings` AS b
        LEFT JOIN `Members` AS m ON b.memid = m.memid
        LEFT JOIN `Facilities` AS f ON f.facid = b.facid) as t
GROUP BY name
HAVING sum(revenue) < 1000
ORDER by revenue;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m1.*, m2.firstname as reco_firstname, m2.surname as reco_surname
FROM Members m1
INNER JOIN Members m2
ON m1.recommendedby = m2.memid
WHERE m1.memid !=0 and m1.recommendedby != ''
ORDER BY m1.surname, m1.firstname;

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT facid, name, count(facid) as f_usage
FROM (SELECT b.facid, f.name
	FROM `Bookings` as b
	LEFT JOIN `Facilities` as f
	ON f.facid = b.facid
	WHERE b.memid != 0) as t
GROUP BY facid, name;


/* Q13: Find the facilities usage by month, but not guests */
SELECT facid, name, m_month, count(*) as f_usage
FROM (SELECT b.facid, f.name, EXTRACT(MONTH from b.starttime) as m_month
	FROM `Bookings` as b
	LEFT JOIN `Facilities` as f
	ON f.facid = b.facid
	WHERE b.memid != 0) as t
GROUP BY facid, name, m_month;
