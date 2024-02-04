/*  
1. Calculate user lifetime revenue
2. Calculate average lifetime revenue
*/

-- 1. Calculate user lifetime revenue
-- we could user_ltv record but the caveat is the revenue value is appended for every user transaction and data outside the date range selected could be included
select
    user_pseudo_id,
    sum(ecommerce.purchase_revenue) as lifetime_value
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between format_date('%Y%m%d',date_sub(current_date(), interval 60 day))
    and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
    and ecommerce.purchase_revenue is not null
group by 
    user_pseudo_id
order by 
    lifetime_value desc;

----------------------------------------------------------------------------------------------
-- 2. Calculate average lifetime revenue
with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
    parse_date('%Y%m%d',event_date) as session_date,
    first_value(parse_date('%Y%m%d',event_date)) over (partition by user_pseudo_id order by event_date) as first_session_date,
    sum(ecommerce.purchase_revenue) as revenue
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between format_date('%Y%m%d',date_sub(current_date(), interval 60 day)) and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
group by
    user_pseudo_id,
    session_id,
    event_date
order by
    user_pseudo_id,
    session_id),

prep_ltv as (
select 
    date_diff(session_date,first_session_date,day) as day,
    count(distinct user_pseudo_id) as users,
    sum(revenue) as ltv_revenue_per_day,
    sum(revenue) / max(count(distinct user_pseudo_id)) over () as avg_ltv_revenue_per_day
from 
    prep
group by 
    day
order by 
    day)

select 
    day,
    sum(avg_ltv_revenue_per_day) over (order by day) as average_ltv_revenue
from 
    prep_ltv
group by 
    day,
    avg_ltv_revenue_per_day
order by 
    day;
