/*
1. Explore items data
2. Count items and revenue
3. build an items funnel with events
*/
-- 1. Explore items data
select 
    event_name,
    items
from 
    `simoahava-com.analytics_206575074.events_20210701`,
    unnest(items) as items;
----------------------------------------------------------------
-- 2. Count items and revenue

select 
    sum(items.quantity) as items,
    sum(items.item_revenue) as item_revenue
from 
    `simoahava-com.analytics_206575074.events_20210701`,
    unnest(items) as items
where 
    event_name = 'purchase';
-----------------------------------------------------------------------------
-- 3. build an items funnel with events

with prep as (
select 
    event_name,
    items.item_name,
    # If items.quantity is not set, default to 1:
    sum(ifnull(items.quantity, 1)) as items
from 
    `simoahava-com.analytics_206575074.events_20210701`,
    unnest(items) as items
group by 
    event_name,
    item_name)

select 
    item_name,
    sum(case when event_name = 'view_item' then items else 0 end) as view_item,
    sum(case when event_name = 'add_to_cart' then items else 0 end) as add_to_cart,
    sum(case when event_name = 'begin_checkout' then items else 0 end) as begin_checkout,
    sum(case when event_name = 'purchase' then items else 0 end) as purchase,
    safe_divide(sum(case when event_name = 'purchase' then items else 0 end),sum(case when event_name = 'view_item' then items else 0 end)) as view_to_purchase_rate
from 
    prep
group by 
    item_name
order by 
    view_item desc;
