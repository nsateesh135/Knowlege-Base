-- source, medium,campaign are event scope
-- active users : users where engagement_time_msec > 0 
-- engaged sessions: sessions where sessions_engaged = 1 
-- active users count need not necessarily be equal to engaged sessions as active users could also be users who trigger first_visit_event
select 
ifnull(source,'direct') as source,
ifnull(medium,'(none)') as medium,
ifnull(campaign,'(not set)') as campaign,
count(distinct user_pseudo_id) as users,
count(distinct case when engagement_time> 0 then user_pseudo_id end) as active_users,
count(distinct session_id ) as sessions,
count(distinct case when is_session_engaged = true then session_id end) as engaged_sessions
from(
select
user_pseudo_id,
(select value.string_value from unnest(event_params) where key = "source") as source,
(select value.string_value from unnest(event_params) where key = "medium") as medium,
(select value.string_value from unnest(event_params) where key = "campaign") as campaign,
concat(user_pseudo_id,(select value.int_value from unnest(event_params) where key = "ga_session_id")) as session_id,
if(max(coalesce(cast((select value.string_value from unnest(event_params) where key = "session_engaged") as int64),(select value.int_value from unnest(event_params) where key = "session_engaged")))=1,true,false) as is_session_engaged,
sum((select value.int_value from unnest(event_params) where key = "engagement_time_msec")) as engagement_time
from `simoahava-com.analytics_206575074.events_20210601`
group by 1,2,3,4,5
)
group by 1,2,3

-- session traffic source
-- https://tanelytics.com/ga4-bigquery-session-traffic_source/
-- though ga4 property default attribution method is DDA(data driven), session traffic source rely on last non-direct click attribution
-- ga4 tracks the session’s first event’s traffic source as the source for the entire session
-- for last non-direct click attribution :GA4 will get the data from the last event that includes traffic source details
-- table1 (session-level): partioned by date 
/*
eventtimestamp : this is the timestamp when events data is sent to GA4/BQ. 
GA4 batches the events at an interval of 5 seconds before sending it to GA4 property. So sequencing 
of events which happen with the 5 seconds would be difficult. 
A quick work around would be to pass a custom timestamp with every hit from GTM (https://www.teamsimmer.com/2023/01/12/how-do-i-access-the-individual-timestamp-of-a-ga4-event/)
Though we create a custom timestamp, this won't apply to automatically collected events

eventtimestamp is a unix timestamp indicating time in milliseconds since Jan 1st ,1970
To convert to required timezone : datetime(timestamp_millis(eventtimestamp),"Australia/Melbourne")
*/

/* 
session_start and first_visit events
- number of session_start events != number of sessions
- number of first_visit events = number of new users (but measured incorrectly)
- A page_view event that includes both the _ss and _fv flags signaling that a session_start and a first_visit event should be generated using the event’s data.
- Returning user : where session number > 1 
*/
with events as (
select
parse_date("%Y%m%d",event_date) as date,
concat(user_pseudo_id, (select value.int_value from unnest(event_params) where key = 'ga_session_id')) as session_id,
user_pseudo_id,
(select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_start,
collected_traffic_source,
event_timestamp
from `<project>.<dataset>.events_*`
where (_table_suffix >= '20230701' and _table_suffix <= '20231231')
    and event_name not in ('session_start', 'first_visit')
)
select
min(date) as date,
session_id,
user_pseudo_id,
session_start,
array_agg(if(
      collected_traffic_source is not null,
      (
          select as struct 
            collected_traffic_source.* except(manual_source, manual_medium),
            if(collected_traffic_source.gclid is not null, 'google', collected_traffic_source.manual_source) as manual_source,
            if(collected_traffic_source.gclid is not null, 'cpc', collected_traffic_source.manual_medium) as manual_medium
      ),
      null
    )
    order by
      event_timestamp asc
    limit
      1
  ) [safe_offset(0)] as session_first_traffic_source,
  -- the last not null traffic source of the session
 array_agg(
    if(
      collected_traffic_source is not null,
      (
          select as struct 
            collected_traffic_source.* except(manual_source, manual_medium),
            if(collected_traffic_source.gclid is not null, 'google', collected_traffic_source.manual_source) as manual_source,
            if(collected_traffic_source.gclid is not null, 'cpc', collected_traffic_source.manual_medium) as manual_medium
      ),
      null
    ) ignore nulls
    order by
      event_timestamp desc
    limit
      1
  ) [safe_offset(0)] as session_last_traffic_source
from
  events
where
  session_id is not null
group by
  session_id,
  user_pseudo_id,
  session_start

-- last non-direct click attribution table
select
  date,
  session_id,
  user_pseudo_id,
  session_start,
  session_first_traffic_source,
  ifnull(
    session_first_traffic_source,
    last_value(session_last_traffic_source ignore nulls) over(
      partition by user_pseudo_id
      order by
        session_start range between 2592000 preceding
        and 1 preceding -- 30 day lookback
    )
  ) as session_traffic_source_last_non_direct,
from
  `<project>.<dataset>.<session traffic source table>`;

-- final query 
-- When a visitor is assigned a user id mid-session, GA4 will attribute the session’s traffic source to “(direct)” / “(none)”, or I guess the last non-direct source derived from that, regardless of what the session’s first traffic source was.
--iOS 14+ WBRAID, GBRAID : 

select
ifnull(session_traffic_source_last_non_direct.manual_source, 
    '(direct)'
  ) as source,
  ifnull(session_traffic_source_last_non_direct.manual_medium, 
    '(none)'
  ) as medium,
  count(distinct session_id) as sessions
from
  `<project>.<dataset>.<session last non-direct traffic source table>`
where
  date between '<start>'
  and '<end>'
group by
  1,
  2
order by
  sessions desc, source
