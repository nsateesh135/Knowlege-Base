create or replace function functions.clean(page string,type string)
  returns string
  as (
case
  when type = 'parameters' then regexp_replace(page,'(?.*)|(#.*)','')
  when type = 'protocol' then regexp_replace(page,'(https?|ftp)://','')
  when type = 'domain' then regexp_replace(page,'^(?:https?://)?(?:[^@/n]+@)?(?:www.)?([^:/?n]+)','')
  when type = 'all' then regexp_replace(page,'^(?:https?://)?(?:[^@/n]+@)?(?:www.)?([^:/?n]+)|(?.*)|(#.*)','')
  end);

with prep as (
select
  user_pseudo_id,
  (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
  (select value.string_value from unnest(event_params) where key = 'page_location') as page
from
  `simoahava-com.analytics_206575074.events_20220901`
where
  event_name = 'page_view')

select
  functions.clean(page,'all') as page_path,
  count(distinct concat(user_pseudo_id,session_id)) as unique_pageviews
from
  prep
group by
  page_path
order by
  unique_pageviews desc
