-- Find the SIDs of suppliers who supply a red part and a green part.
SELECT DISTINCT C.sid FROM Catalog C, Parts P WHERE C.pid = P.pid AND P.color = 'Red'
INTERSECT
SELECT DISTINCT C.sid FROM Catalog C, Parts P WHERE C.pid=P.pid AND P.color = 'Green';

2 -- Find the SIDs of suppliers who supply a red part or a green part.
SELECT DISTINCT C.sid FROM Catalog C, Parts P WHERE C.pid = P.pid AND P.color = 'Red'
UNION
SELECT DISTINCT C.sid FROM Catalog C, Parts P WHERE C.pid=P.pid AND P.color = 'Green';

-- Find the SNAMEs of suppliers who supply every red part and every green part.
SELECT C.sid FROM Catalog C
WHERE ( EXISTS (SELECT P.pid FROM Parts P WHERE P.color = 'red' AND
( EXISTS (SELECT C1.sid FROM Catalog C1 WHERE C1.sid = C.sid AND C1.pid = P.pid))))
AND ( EXISTS (SELECT P1.pid FROM Parts P1 WHERE P1.color = 'green' AND 
( EXISTS (SELECT C2.sid FROM Catalog C2 WHERE C2.sid = C.sid AND C2.pid = P1.pid))));

-- Find the SNAMEs of suppliers who do not supply every red part.
SELECT DISTINCT sid 
FROM Catalog c, Parts p
WHERE c.pid=p.pid AND p.color = 'Red' AND sid NOT IN (
   SELECT sid 
   FROM Catalog c1, parts p1 
   WHERE p1.color != 'Red' AND p1.pid = c1.pid);


-- For every supplier that only supplies red parts, print the SID and the name of the supplier and the average cost of parts that she supplies.
SELECT S.SID, S.sname, AVG(C.COST) as AvgCount
FROM Suppliers S, Catalog C, Parts P
WHERE C.sid = S.sid and P.pid = C.pid and P.color = 'red'
GROUP BY S.sname, S.Sid;

-- For each part, find the SNAMEs of the suppliers who do not charge the most for that part. The answer of this query should have two columns: PID and SNAME.
SELECT P.pid, S.sname
FROM Parts P, Suppliers S, Catalog C
WHERE C.pid = P.pid AND C.sid=S.sid AND C.cost =
 (SELECT MIN(C.cost)
 FROM Catalog C
 WHERE C.pid=P.pid);

-- For every part supplied by a supplier who is at the city of Newark, print the PID and the SID and the name of the suppliers who sell it at the highest price. 
SELECT P.pid, S.sid, s.SNAME
FROM Parts P, Suppliers S, Catalog C
WHERE s.SID = c.SID AND p.PID = c.PID AND s.CITY =
 (SELECT s.city
 FROM suppliers S
 WHERE S.sid=C.sid AND s.CITY = 'Newark')
 AND c.COST =
(
    SELECT MAX(c.cost) from catalog WHERE c.SID = s.SID
 );


-- For every part which has at least two suppliers, find its PID, its PNAME and the total number of suppliers who sell it. 
select c.PID,p.PNAME,count(c.SID) from CATALOG c
left join PARTS p on p.PID=c.PID
group by c.PID having count(c.SID)>=2;

-- Find the PIDs of parts supplied by every supplier who is at the city of Newark or by every supplier who is at the city of Trenton
SELECT DISTINCT C.pid FROM Catalog C, suppliers S WHERE S.sid = C.sid AND s.CITY = 'Newark'
UNION
SELECT DISTINCT C.pid FROM Catalog C, suppliers S WHERE S.sid = C.sid AND s.CITY = 'Trenton';

-- Find the PIDs of parts supplied by every supplier who is at the city of Newark and by every supplier who is at the city of Trenton
SELECT DISTINCT C.pid FROM Catalog C, suppliers S WHERE S.sid = C.sid AND s.CITY = 'Newark'
INTERSECT
SELECT DISTINCT C.pid FROM Catalog C, suppliers S WHERE S.sid = C.sid AND s.CITY = 'Trenton';

--  Find the SIDs of suppliers who supply a red part but do not supply a blue part
SELECT DISTINCT C.sid FROM Catalog C, Parts P, suppliers S WHERE c.sid = s.sid AND c.PID=p.PID AND P.color = 'red'
Intersect
SELECT DISTINCT C.sid FROM Catalog C, Parts P, suppliers S WHERE s.sid=c.sid AND c.PID=p.PID AND P.color != 'blue';

-- For every supplier who supplies at least 4 parts, find his SID, SNAME and the PID of the most expensive part(s) that he supplies.
create view temp2
as

SELECT  c.sid, S.sname
FROM Catalog C
LEFT join suppliers s on s.sid = c.sid
left join PARTS p on p.PID=c.PID
group by c.pid having count(c.sid)>=4;

SELECT s.sid, s.sname,Max(c.cost)
from temp2,catalog c,suppliers s
where temp2.sid=c.sid and c.sid=s.sid
GROUP BY S.sname, S.sid

-- For every distinct color of the parts, find the total number of suppliers who supply a part of this color
SELECT count(c.sid) from catalog c, parts p
WHERE c.pid = p.PID AND p.color
IN (SELECT DISTINCT p.COLOR from parts p);

-- Find the SIDs of suppliers who supply at least two parts of different color.
select c.sid from CATALOG c
left join PARTS p on p.PID=c.PID
group by c.pid having count(p.color)>=2;

--  For every part which has a supplier, find its PID, PNAME, its average cost, maximum cost and minimum cost. 
create view temp3
as

SELECT c.pid
FROM Catalog C, Parts P
WHERE C.pid = P.pid

SELECT c.pid, p.pname, avg(c.cost), Max(c.cost), min(c.cost)
from temp3,catalog c,parts p
where temp3.pid=c.pid and c.pid=p.pid
GROUP BY p.pname, c.pid