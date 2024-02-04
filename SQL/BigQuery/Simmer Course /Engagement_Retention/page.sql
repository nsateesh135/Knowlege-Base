/* 
1. Page, Page Title, Page Views
2. Unique PageViews
3. Landing Page
4. Identify The Exit Page of a Single Session
5. Identify the most popular exit pages 
6. Identify page pathing for a single session
7. Identify most page pathing for any page
*/
--1. Page , Page Title, Page Views
select
    (select value.string_value from unnest(event_params) where key = 'page_title') as page_title,
    (select value.string_value from unnest(event_params) where key = 'page_location') as page,
    count(event_name) as pageviews
from
    `simoahava-com.analytics_206575074.events_20210601`
where
    event_name = 'page_view'
group by 
    page_title,
    page
order by 
    pageviews desc;
-------------------------------------
--2. Unique Pageviews 
-- Number of unique times the page occured in a session
with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') as session_id,
    (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_title') as page_title,
    (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as page
from
    `simoahava-com.analytics_206575074.events_20210601`
where
    event_name = 'page_view')

select 
    page_title,
    page,
    count(*) as total_pageviews,
    count(distinct concat(user_pseudo_id,session_id)) as unique_pageviews
from 
    prep
group by 
    page_title,
    page
order by
    unique_pageviews desc;
-------------------------------------------
--3.Landing Page 
with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
    (select value.string_value from unnest(event_params) where key = 'page_location') as page,
    case when (select value.int_value from unnest(event_params) where key = 'entrances') = 1 then true else false end as landing_page
from
    `simoahava-com.analytics_206575074.events_20210601`
where
    event_name = 'page_view')

select 
    case when landing_page is true then page else null end as landing_page,
    count(distinct concat(user_pseudo_id,session_id)) as entrances
from 
    prep
group by 
    landing_page
having 
    landing_page is not null
order by
    entrances desc;
--------------------------------------------
--4. Identify The Exit Page of a Single Session

with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') as session_id,
    (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as page,
    event_timestamp
from
    `simoahava-com.analytics_206575074.events_20210601`
where
    event_name = 'page_view'
    and user_pseudo_id = '693452447.1622524545'
order by 
    event_timestamp)

select 
    user_pseudo_id,
    session_id,
    page,
    event_timestamp,
    first_value(concat(page,event_timestamp)) over (partition by user_pseudo_id,session_id order by event_timestamp desc) as exit_page
from 
    prep 
order by 
    event_timestamp;
---------------------------------------------------------------------------------------------------------
--5. Identify the most popular exit pages 
select 
case when concat(page,event_timestamp) = exit_page then page else null end exit_page,
count(distinct unique_session_id) as exits 

from(
select 
*,
first_value(concat(page,event_timestamp)) over (partition by unique_session_id order by event_timestamp desc) as exit_page
from(
select
user_pseudo_id,
concat(user_pseudo_id,(select value.int_value from unnest(event_params) where key = "ga_session_id")) as unique_session_id,
(select value.string_value from unnest(event_params) where key = "page_location") as page,
(select value.string_value from unnest(event_params) where key = "page_title") as page_tile,
event_timestamp
from
    `simoahava-com.analytics_206575074.events_20210601`
where event_name = "page_view"
)
)
group by 1
having exit_page is not null
order by 2 desc;
-------------------------------------------------------------------------------------------------------------
-- 6. Identify page pathing for a single session
with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') as session_id,
    (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as page,
    event_timestamp
from
    `simoahava-com.analytics_206575074.events_20210601`
where
    event_name = 'page_view'
    and user_pseudo_id = '693452447.1622524545')

select
    user_pseudo_id,
    session_id,
    lag(page,1) over (partition by user_pseudo_id,session_id order by event_timestamp asc) as previous_page,
    page,
    lead(page,1) over (partition by user_pseudo_id,session_id order by event_timestamp asc) as next_page,
    event_timestamp
from 
    prep;
--------------------------------------------------------------------------------------------------------------
--7. Identify most page pathing for any page
 with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') as session_id,
    (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as page,
    event_timestamp
from
    `simoahava-com.analytics_206575074.events_20210601`
where
    event_name = 'page_view'
    and user_pseudo_id = '693452447.1622524545')

select
    user_pseudo_id,
    session_id,
    lag(page,1) over (partition by user_pseudo_id,session_id order by event_timestamp asc) as previous_page,
    page,
    lead(page,1) over (partition by user_pseudo_id,session_id order by event_timestamp asc) as next_page,
    event_timestamp
from 
    prep
Final query
with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where event_name = 'page_view' and key = 'ga_session_id') as session_id,
    (select value.string_value from unnest(event_params) where event_name = 'page_view' and key = 'page_location') as page,
    event_timestamp
from
    `simoahava-com.analytics_206575074.events_20210601`
where
    event_name = 'page_view'),

prep_navigation as (
select
    user_pseudo_id,
    session_id,
    lag(page,1) over (partition by user_pseudo_id,session_id order by event_timestamp asc) as previous_page,
    page,
    lead(page,1) over (partition by user_pseudo_id,session_id order by event_timestamp asc) as next_page,
    event_timestamp
from 
    prep)

select 
    ifnull(previous_page,'(entrance)') as previous_page,
    page,
    ifnull(next_page,'(exit)') as next_page,
    count(distinct concat(user_pseudo_id, session_id)) as count
from 
    prep_navigation
where 
    page = 'https://www.simoahava.com/analytics/enhanced-ecommerce-guide-for-google-tag-manager/'
group by 
    previous_page,
    page,
    next_page
having 
    page not in (previous_page,next_page)
order by 
    count desc;
---------------------------------------------------------------------------------------------------
