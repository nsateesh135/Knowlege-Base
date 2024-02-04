/*
Assume you're given the tables below about Facebook Page and Page likes 
(as in "Like a Facebook Page").

Write a query to return the IDs of the Facebook pages 
which do not possess any likes. 
The output should be sorted in ascending order

pages Table:
Column Name	Type
page_id	integer
page_name	varchar

page_likes Table:
Column Name	Type
user_id	integer
page_id	integer
liked_date	datetime

Example Output
page_id
20701
*/
SELECT 
distinct pages.page_id
     FROM pages 
LEFT JOIN 
    page_likes 
on(pages.page_id = page_likes.page_id)
where page_likes.page_id is null
order by 1 asc
;