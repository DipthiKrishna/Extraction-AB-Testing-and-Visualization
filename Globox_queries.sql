/* Can a user show up more than once in the activity table?*/
SELECT COUNT(uid) - COUNT(DISTINCT(uid)) AS repeated_uid FROM activity;
/* the start and end dates of the experiment*/
SELECT MIN(dt) AS start_date , MAX(dt) AS end_date FROM activity;
/* total users were in the experiment*/
SELECT COUNT(DISTINCT(id)) as total_users FROM users;

/* users in the control and treatment groups*/
SELECT g.group, COUNT(DISTINCT(uid)) FROM groups as g GROUP BY 1;
/* conversion rate of all users*/
WITH S1 AS(SELECT (SELECT COUNT(DISTINCT(uid))
FROM activity a
WHERE a.spent>0)AS active_users,
COUNT(DISTINCT (id)) AS total_users
FROM users)
SELECT ROUND((CAST(active_users AS NUMERIC(10,2))/total_users)*100,2) AS conversion_rate
FROM S1;
/* user conversion rate for the control and treatment groups*/
WITH S1 AS(SELECT groups.group, COUNT(DISTINCT(a.uid)) AS group_users
FROM groups
JOIN activity a
ON groups.uid=a.uid
GROUP BY 1),
S2 AS(SELECT g.group, COUNT(DISTINCT(uid)) AS total_users
FROM groups as g
GROUP BY 1)
SELECT S1.group,ROUND((CAST(S1.group_users AS NUMERIC(10,2))/S2.total_users)*100,2) AS
conversion_rate
FROM S1
JOIN S2
ON S1.group=S2.group;
/* average amount spent per user for the control and treatment groups, including users who did*/
not convert
WITH S1 AS
(SELECT g.group, SUM(a.spent) AS amount_spent, COUNT(DISTINCT(g.uid)) AS user_count
FROM groups as g
LEFT JOIN activity a
ON a.uid=g.uid
GROUP BY 1)
SELECT S1.group, ROUND(S1.amount_spent/S1.user_count,3) AS conversion_rate
FROM S1;
/*Query used to download the data.*/

SELECT g.uid, g.group, g.join_dt, COALESCE(g.device, 'no info') as device,
COALESCE(u.country, 'no info') as country,
COALESCE(u.gender, 'no info') as gender, COALESCE(SUM(a.spent),0) as total_spent,
CASE WHEN COALESCE(SUM(a.spent),0) > 0 THEN 1 ELSE 0 END as converted
FROM groups as g
LEFT JOIN activity as a
ON g.uid = a.uid
LEFT JOIN users as u
ON g.uid = u.id
GROUP BY 1, 2, 3, 4, 5,6;

