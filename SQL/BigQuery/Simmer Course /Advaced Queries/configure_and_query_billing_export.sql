select 
    invoice.month,
    project.id,
    cost_type,
    location.location,
    service.description as service,
    sku.description,
    currency,
    sum(cost) + ifnull(sum((select amount from unnest(credits))),0) as cost,
    sum(usage.amount) as amount,
    usage.unit
from 
    `bigquery-ga4-course.billing_export.gcp_billing_export_resource_v1_0106E8_EA90EA_BD2769`
group by 
    month,
    id,
    cost_type,
    location,
    service,
    description,
    currency,
    unit
order by 
    month
