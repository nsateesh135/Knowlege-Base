/* 
Why should you set up log export for BiGQuery logs into BigQuery? 

The job information readily avaialble goes back to a max of 30 days so do keep history log we need to set up
the export

What kind of BigQuery logs does the export contain? 
-- All BQ jobs; ones created by individual user, service accounts, conncted sheets etc

How do you set up BigQuery logs export? 

Navigate to log explorer in GCP 
--> Type out the following query 
resource.type="bigquery_resource"
log_name="projects/mydeal-bigquery/logs/cloudaudit.googleapis.com%2Fdata_access" 
--> create a sink 
--> Sink Name: bigquery-jobs
--> Sink Description : The sink extracts BQ jobs and exports data to BigQuery
--> Sink Service : BigQuery data set (This could be GCS, Pub/Sub,Splunk,Another GCP Project)
--> BQ dataset : bigquery_logging_export (check use partitioned tables)
--> Sink : This wil have the query you pasted in the log explorer as a query
--> Build an exclusion Filetr : If we need to exclude certain logs 
*/
/*
1.logName:
Log Type set up on Log Explorer
projects/mydeal-bigquery/logs/cloudaudit.googleapis.com%2Fdata_access

2.resource:
what kind of resource? In this case BigQuery - bigquery_resource
which GCP project? mydeal-bigquery

3. protopayload_auditlog:

    protopayload_auditlog.serviceName - bigquery.googleapis.com

    protopayload_auditlog.methodName
    1.jobservice.cancel : terminated running query
    2.jobservice.insert : Initiation of a job (importing data orexporting data)
    3.jobservice.getqueryresults : Retrieved results of previosly executed queries 
    4.jobservice.jobcompleted : Completion of query,load,export jobs
    5.jobservice.query : log entry when user/application sends SQL query request to BQ service

    protopayload_auditlog.resourceName - Job id stats : projects/mydeal-bigquery/jobs/job_OdPo1-45t-W3HrNfpOFdNgVeHCe3
    protopayload_auditlog.resourceLocation.currentLocations - Region from where the query was executed US/global
    protopayload_auditlog.resourceLocation.originalLocations - Region from where the query was expected to be executed US/global

    status 
    protopayload_auditlog.status.code,-- error code: 13
    protopayload_auditlog.status.message -- error code messages : 13: An internal error occurred and the request could not be completed. This is usually caused by a transient issue

    protopayload_auditlog.authenticationInfo : User or service account executing the query
    protopayload_auditlog.authenticationInfo.principalEmail : Associated Email
    protopayload_auditlog.authenticationInfo.serviceAccountKeyName : If service account then key name

   protopayload_auditlog.authorizationInfo : Authority to create  BQ jobs
   protopayload_auditlog.`authorizationInfo.resource : Resource on which permission is applied : projects/mydeal-bigquery/datasets/fivetran_apologies_capricorn_staging
   protopayload_auditlog.`authorizationInfo.permission : what permission is granted to the user like bigquery.jobs.create

   protopayload_auditlog.servicedata_v1_bigquery 
   protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse

*/

select
protopayload_auditlog.authenticationInfo.principalEmail,
protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobName.projectId,
date(protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobStatistics.createTime) as created_date,
sum(protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobStatistics.totalProcessedBytes) as total_processed_bytes,
round(sum(protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobStatistics.totalProcessedBytes)/(1024*1024*1024),4) as total_processed_gb,
round(sum(protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobStatistics.totalProcessedBytes)/(1024*1024*1024*1024),4) as total_processed_tb,
round((sum(protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobStatistics.totalProcessedBytes)/(1024*1024*1024*1024))*6.5,4) as actual_cost,
sum(protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobStatistics.totalBilledBytes) as total_billed_bytes,
sum(protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobStatistics.totalBilledBytes)/(1024*1024*1024) as total_billed_gb,
sum(protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobStatistics.totalBilledBytes)/(1024*1024*1024*1024) as total_billed_tb,
round((sum(protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobStatistics.totalBilledBytes)/(1024*1024*1024*1024))*6.5,4) as billed_cost
from `mydeal-bigquery.bigquery_logging_export.cloudaudit_googleapis_com_data_access` 
where lower(protopayload_auditlog.authenticationInfo.principalEmail) like "%looker%"
and protopayload_auditlog.methodName ="jobservice.query"
and date(protopayload_auditlog.servicedata_v1_bigquery.jobQueryResponse.job.jobStatistics.createTime) between "2023-01-01" and "2025-02-28"
group by all 
order by created_date desc
