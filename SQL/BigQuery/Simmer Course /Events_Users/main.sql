/* Code Repository */ 
/* Section : Events and users 
1. number of sessions
2. number of sessions (dynamic date range)
3. size of data stored in a dataset
4. count sessions across event and intraday tables 
5. count sessions by part of the week 
6. count sessions by part of the day
7. count unique users 
8. group users by the year of there first visit 
9. group users by acquisition campaign 
10.group users by geographical location
11.group users by technology
12.unnest a specific user property
13.access a user property with a scalar subquery 
14.combine user properties with other user data
*/ 

-- 1. number of sessions
-- Keep in mind that there could be some sessions which don't have session_start associated this is known bug which Google is working on
select
    count(event_name) as sessions
from
    `simoahava-com.analytics_206575074.events_20210501`
where
    event_name = 'session_start';

-- 2. number of sessions (dynamic date range)
select
    event_date,
    count(event_name) as sessions
from
    `simoahava-com.analytics_206575074.events_*`
where
    event_name = 'session_start'
    and _table_suffix between '20210501' and format_date('%Y%m%d', date_sub(current_date(), interval 1 day))
group by
    event_date
order by
    event_date desc;

-- 3. size of data stored in a dataset
with meta_data as (
select
    *
from
    `simoahava-com.analytics_206575074.__TABLES__`)

select
    dataset_id,
    count(*) as tables,
    sum(row_count) as total_rows,
    sum(size_bytes)/1000000000 as size_gb
from
    meta_data
group by
    dataset_id;
-- 4. count sessions across event and intraday tables
-- The approach here is to use regexp_extract() to match/extract the date part 
-- we can't just extract the date part because there are user tables as well 
/*
select 
*
from(
select 
event_date,
count(*) as num_sessions
from `mydeal-bigquery.analytics_156804695.events_intraday_*`
where regexp_extract(_table_suffix,r"[0-9]+") = format_date("%Y%m%d",current_date("Australia/Melbourne"))
and event_name = "session_start"
group by 1 


union all 

select 
event_date,
count(*) as num_sessions

from  `mydeal-bigquery.analytics_156804695.events_20*`
where regexp_extract(_table_suffix,r"[0-9]+") between "231224" and format_date("%y%m%d",current_date("Australia/Melbourne")-1)
and event_name = "session_start"
group by 1 
order by 1 desc
)
order by 1;
*/
select
    event_date as date,
    count(event_name) as sessions
from
    `simoahava-com.analytics_206575074.events_*`
where
    regexp_extract(_table_suffix, '[0-9]+') between '20210501' and format_date('%Y%m%d', current_date())
    and event_name = 'session_start'
group by 
    date
order by
    date desc;
-- 5. count sessions by part of the week 
select
    event_date as date,
    case
        when extract(dayofweek from parse_date('%Y%m%d',event_date)) in (1,7) then 'weekend'
        else 'week' end as part_of_week,
    count(event_name) as sessions
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between '20210501' and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
    and event_name = 'session_start'
group by 
    date
order by
    date desc;

-- 6. count sessions by part of the day

select
    case
        when extract(dayofweek from parse_date('%Y%m%d',event_date)) in (1,7) then 'weekend'
        else 'week' end as part_of_week,
    case
        when extract(hour from timestamp_micros(event_timestamp)) between 0 and 5 then 'night'
        when extract(hour from timestamp_micros(event_timestamp)) between 6 and 11 then 'morning'
        when extract(hour from timestamp_micros(event_timestamp)) between 12 and 17 then 'afternoon'
        else 'evening' end as part_of_day,
    count(event_name) as sessions
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between '20210501' and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
    and event_name = 'session_start'
group by 
    part_of_week,
    part_of_day
order by
    sessions desc;

-- 7. count unique users 
select
    count(distinct user_pseudo_id) as users
from
    `simoahava-com.analytics_206575074.events_20210601`;

-- 8. group users by the year of there first visit 
select
    extract(year from timestamp_micros(user_first_touch_timestamp)) as year_first_touch,
    count(distinct user_pseudo_id) as users
from
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    year_first_touch
having 
    year_first_touch is not null
order by
    year_first_touch desc;
-- 9. group users by acquisition campaign 
select
    traffic_source.source,
    traffic_source.medium,
    traffic_source.name as campaign,
    count(distinct user_pseudo_id) as users
from
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    source,
    medium,
    campaign
order by
    users desc;

-- 10.group users by geographical location
select
    geo.continent,
    geo.country,
    nullif(geo.city,'') as city,
    count(distinct user_pseudo_id) as users
from
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    continent,
    country,
    city
order by 
    users desc;
-- 11.group users by technology
select
    device.category,
    device.operating_system,
    device.operating_system_version,
    device.language,
    device.web_info.browser,
    device.web_info.browser_version,
    device.web_info.hostname,
    count(distinct user_pseudo_id) as users
from
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    category,
    operating_system,
    operating_system_version,
    language,
    browser,
    browser_version,
    hostname
order by
    users desc;
-- 12. unnest a specific user property
select
    user_pseudo_id,
    value.string_value as visitor_status
from
    `simoahava-com.analytics_206575074.events_20210601`,
    unnest(user_properties)
where 
    key = 'visitor_status'
group by 
    user_pseudo_id,
    value.string_value;
-- 13.access a user property with a scalar subquery 
select
    user_pseudo_id,
    max((select value.string_value from unnest(user_properties) where key = 'visitor_status')) as visitor_status
from
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    user_pseudo_id
having 
    visitor_status is not null;
-- 14.combine user properties with other user data
select
    user_pseudo_id,
    timestamp_micros(user_first_touch_timestamp) as user_first_touch_timestamp,
    traffic_source.medium,
    max((select value.string_value from unnest(user_properties) where key = 'visitor_status')) as visitor_status,
    max((select value.string_value from unnest(user_properties) where key = 'custom_client_id')) as custom_client_id,
    max((select value.string_value from unnest(user_properties) where key = 'loyalty_level')) as loyalty_level,
    countif(event_name = 'session_start') as number_of_sessions
from
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    user_pseudo_id,
    user_first_touch_timestamp,
    medium
order by
    number_of_sessions desc;
