# BigQuery Scheduled Queries  

- Use this service to schedule certain queries to execute at a recurring cadence
- The scheduled query is not affected by daylight savings as Google converts local time to UTC while executing
- BigQuery Admin role would encompass required permissions, if providing this access is a compliance issue consider creating a custom role
  with permissions mentioned on this [list](https://cloud.google.com/bigquery/docs/scheduling-queries)
- We can use  @run_date and @run_time query parameters for scheduling queries rather than adding mannual date filter
  like current_date("Australia/Melbourne) - 1
- The destination dataset and table for a scheduled query must be in same project as the scheduled query
- If no destination table is created before scheduling a query, BigQuery automatically creates a table for us by default
- We can use query parameters run_date and run_time to partiton destination table.
  For Example: If we want to shrad a table like tablename_20240301 then we need to add mytable_{run_time|"%Y%m%d"} in the destination table field
  while scheduling queries. More examples can be found [here](https://cloud.google.com/bigquery/docs/scheduling-queries#templating-examples)
- Scheduled queries are subject to same BigQuery Quotas and limits as mannual queries
- Scheduled queries are priced same as mannual queries
- 
