# select DATE_FORMAT(create_at, " %M ") , COUNT(MONTH(create_at))  as total
# from users 
# group by MONTH(create_at)
# ORDER BY total
# DESC
# ;


# # select count(email) as yahoo_users from users 
# # where email 
# # like '%yahoo.com'

# # ;

select  


CASE

when email like "%gmail.com" then "gmail"

when email like "%yahoo.com" then "yahoo"

when email like "%hotmail.com" then "hotmail"

else "other"

End as Provider, count(email) Total_users

from users

group by Provider

Order by Total_users
DESC;

