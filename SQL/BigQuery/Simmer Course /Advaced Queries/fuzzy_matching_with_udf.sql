with prep_1 as (
select
  (select value.string_value from unnest(event_params) where key = 'search_term') as search_term_1,
  count(*) as count_1
from
  `simoahava-com.analytics_206575074.events_202208*`
where
  event_name like '%search%'
group by
  search_term_1),

prep_2 as (
select
  search_term_1 as search_term_2,
  count_1 as count_2
from
  prep_1),

join_data as (
select
  *,
  round(functions.levenshtein(search_term_1,search_term_2),3) as similarity
from
  prep_1
cross join
  prep_2)

select
  search_term_1 as search_term,
  count_1 as count,
  array_agg(search_term_2 order by similarity desc,count_2 desc) as related_terms,
  array_agg(count_2 order by similarity desc,count_2 desc) as related_count,
  sum(count_2) as total_related_terms,
  count_1 + sum(count_2) as total_search_cluster,
  array_agg(similarity order by similarity desc,count_2 desc) as similarity
from
  join_data
where
  search_term_2 is not null
  and similarity between 0.75 and 0.999
group by
  search_term_1,
  count_1
order by
  count_1 desc;
with prep_1 as (
select
  (select value.string_value from unnest(event_params) where key = 'search_term') as search_term_1,
  count(*) as count_1
from
  `simoahava-com.analytics_206575074.events_202208*`
where
  event_name like '%search%'
group by
  search_term_1),

prep_2 as (
select
  search_term_1 as search_term_2,
  count_1 as count_2
from
  prep_1),

join_data as (
select
  *,
  soundex(prep_1.search_term_1) as soundex_1,
  soundex(prep_2.search_term_2) as soundex_2,
  soundex(prep_1.search_term_1) = soundex(prep_2.search_term_2) as soundex_match,
  round(functions.levenshtein(search_term_1,search_term_2),3) as similarity
from
  prep_1
cross join
  prep_2)

select
  search_term_1 as search_term,
  count_1 as count,
  array_agg(search_term_2 order by similarity desc,soundex_match desc,count_2 desc) as related_terms,
  array_agg(cast(count_2 as string) order by similarity desc,soundex_match desc, count_2 desc) as related_count,
  sum(count_2) as total_related_terms,
  count_1 + sum(count_2) as total_search_cluster,
  array_agg(cast(similarity as string) order by similarity desc,soundex_match desc, count_2 desc) as similarity,
  array_agg(soundex_match order by similarity desc,soundex_match desc,count_2 desc) as soundex_match
from
join_data
where
  similarity between 0.75 and 0.999
  or (similarity between 0.50 and 0.999 and soundex_match is true)
group by
  search_term_1,
  count_1
order by
  count_1 desc;
