/*
1. Calculate ecommerce metrics by date
2. Calculate conversion rate by engaged session
3. Add refund, tax, shipping data
*/

-- 1. Calculate ecommerce metrics by date
select 
    event_date as date,
    count(distinct ecommerce.transaction_id) as transactions,
    sum(ecommerce.purchase_revenue) as purchase_revenue
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between '20210701' and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
group by 
    date
order by
    date;
---------------------------------------------------------------------------------------------------------------------------------
-- 2. Calculate conversion rate by engaged session
with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
    event_date,
    max((select value.string_value from unnest(event_params) where key = 'session_engaged')) as session_engaged,
    ecommerce.transaction_id,
    ecommerce.purchase_revenue
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between '20210701' and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
group by
    user_pseudo_id,
    session_id,
    event_date,
    transaction_id,
    purchase_revenue)

select
    event_date as date,
    count(distinct transaction_id) as transactions,
    sum(purchase_revenue) as purchase_revenue,
    count(distinct transaction_id) / count(distinct concat(user_pseudo_id,session_id)) as ecommerce_conversion_rate_all_sessions,
    count(distinct transaction_id) / count(distinct case when session_engaged = '1' then concat(user_pseudo_id,session_id) else null end) as ecommerce_conversion_rate_engaged_sessions
from
    prep
group by 
    date
order by 
    date;
-------------------------------------------------------------------------------------------------------------------
-- 3. Add refund, tax, shipping data
-- Query updated 24 November 2022: Changed "total_item_quantity" to apply only to "purchase" events,
-- as other types of Ecommerce events can also have the "items" array. We are only
-- interested in purchase data in this topic.

with prep as (
select
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
    event_date,
    max((select value.string_value from unnest(event_params) where key = 'session_engaged')) as session_engaged,
    ecommerce.transaction_id,
    ecommerce.purchase_revenue,
    case when event_name = 'purchase' then ecommerce.total_item_quantity end as total_item_quantity,
    ecommerce.refund_value,
    ecommerce.tax_value,
    ecommerce.shipping_value
from
    `simoahava-com.analytics_206575074.events_*`
where
    _table_suffix between '20210701' and format_date('%Y%m%d',date_sub(current_date(), interval 1 day))
group by
    user_pseudo_id,
    session_id,
    event_date,
    transaction_id,
    purchase_revenue,
    total_item_quantity,
    refund_value,
    tax_value,
    shipping_value)

select
    event_date as date,
    count(distinct transaction_id) as transactions,
    sum(purchase_revenue) as purchase_revenue,
    count(distinct transaction_id) / count(distinct concat(user_pseudo_id,session_id)) as ecommerce_conversion_rate_all_sessions,
    count(distinct transaction_id) / count(distinct case when session_engaged = '1' then concat(user_pseudo_id,session_id) else null end) as ecommerce_conversion_rate_engaged_sessions,
    sum(total_item_quantity) as items,
    sum(refund_value) as refund_value,
    sum(tax_value) as tax_value,
    sum(shipping_value) as shipping_value,
    safe_divide(sum(purchase_revenue),count(distinct transaction_id)) as average_transaction_value,
    safe_divide(sum(shipping_value),count(distinct transaction_id)) as average_shipping_value,
    safe_divide(sum(total_item_quantity),count(distinct transaction_id)) as average_items
from
    prep
group by 
    date
order by 
    date;
