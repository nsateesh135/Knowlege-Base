/* 
1. Count Scroll Intercations
2. Count Outbound Clicks
3. Track Site Search
4. Explore Video Engagement
5. Count File Downloads
6. Count Events Per User With a Pivot Table
*/

-- 1. Count Scroll Intercations

-- METHOD 1: Query all scroll events
select
    (select value.string_value from unnest(event_params) where event_name = 'scroll' and key = 'page_location') as scroll_page,
    countif(event_name = 'scroll') as scrolls
from 
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    scroll_page
order by 
    scrolls desc;
-- METHOD 2: Query only scrolls that reach a certain threshold
select
    case 
        when (select value.int_value from unnest(event_params) where event_name = 'scroll' and key = 'percent_scrolled') = 90
        then (select value.string_value from unnest(event_params) where event_name = 'scroll' and key = 'page_location') else null end as scroll_page_90_percent,
    countif(event_name = 'scroll') as scrolls
from 
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    scroll_page_90_percent
order by 
    scrolls desc;
-----------------------------------------------------------------------------------------------
-- 2. Count Outbound Clicks

select
    (select value.string_value from unnest(event_params) where event_name = 'click' and key = 'page_location') as page,
    (select value.string_value from unnest(event_params) where event_name = 'click' and key = 'link_domain') as link_domain,
    (select value.string_value from unnest(event_params) where event_name = 'click' and key = 'link_url') as link_url,
    countif(event_name = 'click' and (select value.string_value from unnest(event_params) where event_name = 'click' and key = 'outbound') = 'true') as clicks
from 
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    page,
    link_domain,
    link_url
order by 
    clicks desc;
------------------------------------------------------------------------------------
-- 3.Track Site Search
-- unique_search_term is a parameter part of view_search_results event. This parameter is session scoped and is flagged with a value 1 for first time search of a term in a session
select
    (select value.string_value from unnest(event_params) where event_name = 'view_search_results' and key = 'search_term') as search_term,
    countif(event_name = 'view_search_results') as searches
from 
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    search_term
order by 
    searches desc;
-------------------------------------------------------------
-- 4. Explore Video Engagement

select 
    (select value.string_value from unnest(event_params) where event_name like 'video%' and key = 'video_provider') as video_provider,
    (select value.string_value from unnest(event_params) where event_name like 'video%' and key = 'video_title') as video_title,
    (select value.string_value from unnest(event_params) where event_name like 'video%' and key = 'video_url') as video_url,
    (select value.int_value from unnest(event_params) where event_name like 'video%' and key = 'video_duration') as video_duration,
    countif(event_name = 'video_start') as video_start,
    countif(event_name = 'video_progress' and (select value.int_value from unnest(event_params) where event_name = 'video_progress' and key = 'video_percent') = 50) as video_progress_50_percent,
    countif(event_name = 'video_complete') as video_complete
from 
    `simoahava-com.analytics_206575074.events_20210601`
group by 
    video_provider,
    video_title,
    video_url,
    video_duration
order by 
    video_start desc;
----------------------------------------------------------------------------------------------------------------------------------
-- 5. Count File Downloads

select
    (select value.string_value from unnest(event_params) where event_name = 'file_download' and key = 'file_extension') as file_type,
    (select value.string_value from unnest(event_params) where event_name = 'file_download' and key = 'file_name') as file_name,
    (select value.string_value from unnest(event_params) where event_name = 'file_download' and key = 'link_text') as link_text,
    (select value.string_value from unnest(event_params) where event_name = 'file_download' and key = 'link_url') as link_url,
    countif(event_name = 'file_download') as downloads
from
    `simoahava-com.analytics_206575074.events_202106*`
group by
    file_type,
    file_name,
    link_text,
    link_url
order by
    downloads desc;

------------------------------------------------------------------------------------------------------------------
-- 6. Count Events Per User With a Pivot Table

select
    *
from (
    select
        user_pseudo_id,
        event_name
    from
        `simoahava-com.analytics_206575074.events_202106*`)
pivot (
    count(*)
    for
        event_name
    in (
        'session_start', 
        'first_visit',
        'page_view',
        'scroll',
        'click',
        'view_search_results',
        'file_download', 
        'video_start'))
