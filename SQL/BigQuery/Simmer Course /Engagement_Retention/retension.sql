/* 
1. Count new and returning users 
2. Calculate user retension 1/2
3. Calculate user retension 2/2
4. Calculate user retension by cohort
*/

-- 1. Count new and returning users

with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_number') as session_number,
    max((select value.int_value from unnest(event_params) where key = 'engagement_time_msec')) as engagement_time_msec
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between '20210601' and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
group by
    user_pseudo_id,
    session_id,
    session_number)

select
    count(distinct case when session_number = 1 and engagement_time_msec > 0 then user_pseudo_id else null end) as new_users,
    count(distinct case when session_number > 1 and engagement_time_msec > 0 then user_pseudo_id else null end) as returning_users
from 
    prep;

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. Calculate user retension 1/2
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_number') as session_number,
    max((select value.int_value from unnest(event_params) where key = 'engagement_time_msec')) as engagement_time_msec,
    parse_date('%Y%m%d',event_date) as session_date,
    first_value(parse_date('%Y%m%d',event_date)) over (partition by user_pseudo_id order by event_date) as first_session_date
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between format_date('%Y%m%d',date_sub(current_date(), interval 43 day)) and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
group by
    user_pseudo_id,
    session_id,
    session_number,
    event_date
order by
    user_pseudo_id,
    session_id,
    session_number;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3. Calculate user retension 2/2
with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_number') as session_number,
    max((select value.int_value from unnest(event_params) where key = 'engagement_time_msec')) as engagement_time_msec,
    parse_date('%Y%m%d',event_date) as session_date,
    first_value(parse_date('%Y%m%d',event_date)) over (partition by user_pseudo_id order by event_date) as first_session_date
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between format_date('%Y%m%d',date_sub(current_date(), interval 43 day)) and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
group by
    user_pseudo_id,
    session_id,
    session_number,
    event_date
order by
    user_pseudo_id,
    session_id,
    session_number)

select 
    date_diff(session_date,first_session_date,day) as day,
    count(distinct case when session_number = 1 and engagement_time_msec > 0 then user_pseudo_id else null end) as new_users,
    count(distinct case when session_number > 1 and engagement_time_msec > 0 then user_pseudo_id else null end) as returning_users,
    count(distinct case when session_number > 1 and engagement_time_msec > 0 then user_pseudo_id else null end) / max(count(distinct case when session_number = 1 and engagement_time_msec > 0 then user_pseudo_id else null end)) over () as retention_percentage
from 
    prep
group by 
    day
order by 
    day;
---------------------------------------------------------------------------------------------------------------------------------
-- 4. Calculate user retension by cohort

with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_number') as session_number,
    max((select value.int_value from unnest(event_params) where key = 'engagement_time_msec')) as engagement_time_msec,
    parse_date('%Y%m%d',event_date) as session_date,
    first_value(parse_date('%Y%m%d',event_date)) over (partition by user_pseudo_id order by event_date) as first_session_date
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between format_date('%Y%m%d',date_sub(current_date(), interval 100 day)) and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
group by
    user_pseudo_id,
    session_id,
    session_number,
    event_date
order by
    user_pseudo_id,
    session_id,
    session_number)

select
    distinct concat(extract(isoyear from first_session_date),'-',format('%02d',extract(isoweek from first_session_date))) as year_week,
    count(distinct case when date_diff(session_date,first_session_date,isoweek) = 0 and session_number >= 1 and engagement_time_msec > 0 then user_pseudo_id end) as week_0,
    count(distinct case when date_diff(session_date,first_session_date,isoweek) = 1 and session_number > 1 and engagement_time_msec > 0 then user_pseudo_id end) as week_1,
    count(distinct case when date_diff(session_date,first_session_date,isoweek) = 2 and session_number > 1 and engagement_time_msec > 0 then user_pseudo_id end) as week_2,
    count(distinct case when date_diff(session_date,first_session_date,isoweek) = 3 and session_number > 1 and engagement_time_msec > 0 then user_pseudo_id end) as week_3,
    count(distinct case when date_diff(session_date,first_session_date,isoweek) = 4 and session_number > 1 and engagement_time_msec > 0 then user_pseudo_id end) as week_4,
    count(distinct case when date_diff(session_date,first_session_date,isoweek) = 5 and session_number > 1 and engagement_time_msec > 0 then user_pseudo_id end) as week_5
from
    prep
group by 
    year_week 
order by
   year_week;
