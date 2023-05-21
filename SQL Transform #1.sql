--------------------------------------------------------------------------------------- 
--Consolidated table base store
drop table if exists consolidated_table_base_store;
create temp table consolidated_table_base_store as (
select
	  x.*
	, xx.scheduled_hours_capped
	, xx.sun_scheduled_hours_capped
	, xx.sun_planned_hours 
from (
select
	  case when store_region in ('PN','RM') then 'MP' else store_region end as store_region
	, store_id
	, store_name_abb
	, store_name
	, to_date(case when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 0 then cast(dateadd(day,6,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 1 then cast(dateadd(day,5,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 2 then cast(dateadd(day,4,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 3 then cast(dateadd(day,3,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 4 then cast(dateadd(day,2,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 5 then cast(dateadd(day,1,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 6 then cast(dateadd(day,0,to_date(data_day,'YYYY-MM-DD')) as varchar)
        end , 'YYYY-MM-DD') as week_end_date
	, sum(availability_today_customers) as availability_today_customers
	, sum(cu_visits) as cu_visits
	, sum(num_cu) as num_cu
	, sum(ooc_visits_pick_exec) as ooc_visits_pick_exec 
	, sum(total_visits) as total_visits
	, sum(num_late_slam) as num_late_slam
	, sum(num_orders) as num_orders
	, sum(picked_hours) as picked_hours
	, sum(dropoff_hours) as dropoff_hours
	, sum(paid_hours) as paid_hours
	, sum(requested_units) as requested_units
	, sum(num_subs) as num_subs
	, sum(sub_rejected) as sub_rejected
	, sum(no_response_short) as no_response_short  
	, sum(num_shorts) as num_shorts
	, sum(inf_denominator) as inf_denominator
	, sum(do_not_replace) as do_not_replace
	, sum(sales) as sales
	, sum(orders) as orders
	, sum(sales_overall) as sales_overall
	, sum(paid_wages) as paid_wages -- VCPU
	, 0.23710000 as burdened_wages_rate
	, sum(picked_units) as picked_units
	, sum(time_available) as available_hours
	, sum(case when project_peanut_store_type = 'Non Project Peanut Store' then reg_shopper_available_hours else 0 end) as reg_shopper_available_hours_hv --network/region paid avail
	, sum(case when project_peanut_store_type = 'Non Project Peanut Store' then shopper_paid_hours else 0 end) as shopper_paid_hours_hv
	, sum(reg_shopper_available_hours) as reg_shopper_available_hours --store paid avail
	, sum(shopper_paid_hours) as shopper_paid_hours --store paid avail/paid util
	, sum(case when project_peanut_store_type = 'Non Project Peanut Store' then reg_shopper_picked_hours else 0 end) as reg_shopper_picked_hours_hv
	, sum(case when project_peanut_store_type = 'Non Project Peanut Store' then reg_shopper_dropoff_hours else 0 end) as reg_shopper_dropoff_hours_hv
	, sum(case when project_peanut_store_type = 'Non Project Peanut Store' then otj_paid_hours else 0 end) as otj_paid_hours_hv
	, sum(case when project_peanut_store_type = 'Non Project Peanut Store' then paid_hours  else 0 end) as paid_hours_hv
	, sum(case when project_peanut_store_type = 'Non Project Peanut Store' then time_available  else 0 end) as available_hours_hv
	, sum(reg_shopper_picked_hours) as reg_shopper_picked_hours --shopper paid util store 
	, sum(reg_shopper_dropoff_hours) as reg_shopper_dropoff_hours --shopper paid util store 
	, sum(otj_paid_hours) as otj_paid_hours --shopper paid util store 
	, sum(scheduled_hours) as scheduled_hours
	, sum(planned_hours) as planned_hours
	, sum(absent_hours) as absent_hours
	, sum(forecasted_units) as forecasted_units
	, sum(actual_units) as actual_units 
from ##
where 
	week_end_date  >= date(date_add('week',-4,date_trunc('week',GETDATE())+'5 days'::interval)) and 
	week_end_date <= getdate()-3 and
	metric_grain  = 'Daily' 
group by 1,2,3,4,5
order by 1,2) x
left join 
(select 
	  case when store_region in ('PN','RM') then 'MP' else store_region end as store_region
	, store_id
	, store_name_abb
	, store_name
	, to_date(case when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 0 then cast(dateadd(day,6,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 1 then cast(dateadd(day,5,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 2 then cast(dateadd(day,4,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 3 then cast(dateadd(day,3,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 4 then cast(dateadd(day,2,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 5 then cast(dateadd(day,1,to_date(data_day,'YYYY-MM-DD')) as varchar)
        when date_part('dow', to_date(data_day,'YYYY-MM-DD')) = 6 then cast(dateadd(day,0,to_date(data_day,'YYYY-MM-DD')) as varchar)
        end , 'YYYY-MM-DD') as week_end_date
	, sum(case when planned_hours > 0 and scheduled_hours >= planned_hours then planned_hours
	            when planned_hours > 0 then scheduled_hours
	            else null end) as scheduled_hours_capped  
	, sum(planned_hours) as planned_hours 
	, sum(case when date_part('dow',to_date(data_day,'YYYY-MM-DD')) = 0 then (case when planned_hours > 0 
                                                                               and scheduled_hours >= planned_hours then planned_hours
															                   when planned_hours > 0 then scheduled_hours
															                   else null end) else 0 end) as sun_scheduled_hours_capped
	, sum(case when date_part('dow',to_date(data_day,'YYYY-MM-DD')) = 0 then planned_hours else 0 end) as sun_planned_hours
from ##
where 
	metric_grain = 'Hourly' and 
	week_end_date  >= date(date_add('week',-4,date_trunc('week',GETDATE())+'5 days'::interval)) and 
	week_end_date  <= getdate()-3
group by 1,2,3,4,5
order by 1,2)xx
on 
	x.store_region = xx.store_region and 
	x.store_id = xx.store_id and 
	x.store_name_abb = xx.store_name_abb and 
	x.store_name = xx.store_name and
	x.week_end_date = xx.week_end_date)
;
--------------------------------------------------------------------------------------- 
--Consolidated table region 
drop table if exists consolidated_table_base_region;
create temp table consolidated_table_base_region as (
select 
	  store_region
	, 11111 as store_id
	, 'REG' as store_name_abb 
	, 'Region' as store_name 
	, week_end_date
	, sum(availability_today_customers) as availability_today_customers
	, sum(cu_visits) as cu_visits
	, sum(num_cu) as num_cu
	, sum(ooc_visits_pick_exec) as ooc_visits_pick_exec
	, sum(total_visits) as total_visits
	, sum(num_late_slam) as num_late_slam
	, sum(num_orders) as num_orders
	, sum(picked_hours) as picked_hours
	, sum(dropoff_hours) as dropoff_hours
	, sum(paid_hours) as paid_hours
	, sum(requested_units) as requested_units
	, sum(num_subs) as num_subs
	, sum(sub_rejected) as sub_rejected
	, sum(no_response_short) as no_response_short
	, sum(num_shorts) as num_shorts
	, sum(inf_denominator) as inf_denominator
	, sum(do_not_replace) as do_not_replace
	, sum(sales) as sales
	, sum(orders) as orders
	, sum(sales_overall) as sales_overall
	, sum(paid_wages) as paid_wages
	, avg(burdened_wages_rate) as burdened_wages_rate
	, sum(picked_units) as picked_units
	, sum(available_hours) as available_hours
	, sum(reg_shopper_available_hours_hv) as reg_shopper_available_hours_hv
	, sum(shopper_paid_hours_hv) as shopper_paid_hours_hv
	, sum(reg_shopper_available_hours) as reg_shopper_available_hours
	, sum(shopper_paid_hours) as shopper_paid_hours
	, sum(reg_shopper_picked_hours_hv) as reg_shopper_picked_hours_hv
	, sum(reg_shopper_dropoff_hours_hv) as reg_shopper_dropoff_hours_hv
	, sum(otj_paid_hours_hv) as otj_paid_hours_hv
	, sum(paid_hours_hv) as paid_hours_hv
	, sum(available_hours_hv) as available_hours_hv	
	, sum(reg_shopper_picked_hours) as reg_shopper_picked_hours
	, sum(reg_shopper_dropoff_hours) as reg_shopper_dropoff_hours
	, sum(otj_paid_hours) as otj_paid_hours
	, sum(scheduled_hours) as scheduled_hours	
	, sum(planned_hours) as planned_hours
	, sum(absent_hours) as absent_hours
	, sum(forecasted_units) as forecasted_units
	, sum(actual_units) as actual_units
	, sum(scheduled_hours_capped) as scheduled_hours_capped
	, sum(sun_scheduled_hours_capped) as sun_scheduled_hours_capped
	, sum(sun_planned_hours) as sun_planned_hours	
from consolidated_table_base_store
group by 1,2,3,4,5
order by 5
);

--------------------------------------------------------------------------------------- 
--Consolidated table global
drop table if exists consolidated_table_base_global;
create temp table consolidated_table_base_global as (
select 
	 'GL' as store_region
	, 0 as store_id
	, 'GBL' as store_name_abb 
	, 'Global' as store_name 
	, week_end_date
	, sum(availability_today_customers) as availability_today_customers
	, sum(cu_visits) as cu_visits
	, sum(num_cu) as num_cu
	, sum(ooc_visits_pick_exec) as ooc_visits_pick_exec
	, sum(total_visits) as total_visits
	, sum(num_late_slam) as num_late_slam
	, sum(num_orders) as num_orders
	, sum(picked_hours) as picked_hours
	, sum(dropoff_hours) as dropoff_hours
	, sum(paid_hours) as paid_hours
	, sum(requested_units) as requested_units
	, sum(num_subs) as num_subs
	, sum(sub_rejected) as sub_rejected
	, sum(no_response_short) as no_response_short
	, sum(num_shorts) as num_shorts
	, sum(inf_denominator) as inf_denominator
	, sum(do_not_replace) as do_not_replace
	, sum(sales) as sales
	, sum(orders) as orders
	, sum(sales_overall) as sales_overall
	, sum(paid_wages) as paid_wages
	, avg(burdened_wages_rate) as burdened_wages_rate
	, sum(picked_units) as picked_units
	, sum(available_hours) as available_hours
	, sum(reg_shopper_available_hours_hv) as reg_shopper_available_hours_hv
	, sum(shopper_paid_hours_hv) as shopper_paid_hours_hv
	, sum(reg_shopper_available_hours) as reg_shopper_available_hours
	, sum(shopper_paid_hours) as shopper_paid_hours
	, sum(reg_shopper_picked_hours_hv) as reg_shopper_picked_hours_hv
	, sum(reg_shopper_dropoff_hours_hv) as reg_shopper_dropoff_hours_hv
	, sum(otj_paid_hours_hv) as otj_paid_hours_hv
	, sum(paid_hours_hv) as paid_hours_hv
	, sum(available_hours_hv) as available_hours_hv	
	, sum(reg_shopper_picked_hours) as reg_shopper_picked_hours
	, sum(reg_shopper_dropoff_hours) as reg_shopper_dropoff_hours
	, sum(otj_paid_hours) as otj_paid_hours
	, sum(scheduled_hours) as scheduled_hours	
	, sum(planned_hours) as planned_hours
	, sum(absent_hours) as absent_hours
	, sum(forecasted_units) as forecasted_units
	, sum(actual_units) as actual_units
	, sum(scheduled_hours_capped) as scheduled_hours_capped
	, sum(sun_scheduled_hours_capped) as sun_scheduled_hours_capped
	, sum(sun_planned_hours) as sun_planned_hours	
from consolidated_table_base_store
group by 1,2,3,4,5
order by 5
);

--------------------------------------------------------------------------------------- 
drop table if exists consolidated_table_base;
create temp table consolidated_table_base as (
select * from consolidated_table_base_store
union 
select * from consolidated_table_base_region
union
select * from consolidated_table_base_global
);
--------------------------------------------------------------------------------------- 
--Consolidated table LW 
drop table if exists consolidated_table_lw;
create temp table consolidated_table_lw as (
select 
	  store_region
	, store_id
	, store_name_abb 
	, store_name 
	, week_end_date
	, (1 - (availability_today_customers / nullif(cu_visits,0))) as same_day_unavail_pct
	, (num_cu / nullif(cu_visits,0)) as complete_unavail_pct
	, (ooc_visits_pick_exec/nullif(total_visits,0)) as pe_ooc_pct
	, ((paid_wages * (1 + burdened_wages_rate)) / nullif (picked_units,0)) as vcpu
	, (picked_units / nullif(paid_hours,0)) as uplh
	, (requested_units / nullif(picked_hours,0)) as uph
	, ((picked_hours + coalesce(dropoff_hours,0))/ nullif(paid_hours,0)) as paid_utilization_old
	, (available_hours_hv / nullif(paid_hours_hv,0)) as paid_availability_pct
	, (available_hours / nullif(paid_hours,0)) as paid_availability_pct_old
	, ((reg_shopper_picked_hours_hv + reg_shopper_dropoff_hours_hv) / nullif((shopper_paid_hours_hv + otj_paid_hours_hv),0)) as shopper_paid_utilization_hv
	, ((reg_shopper_picked_hours + reg_shopper_dropoff_hours) / nullif((shopper_paid_hours + otj_paid_hours),0)) as shopper_paid_utilization_store
	, (reg_shopper_available_hours_hv / nullif(shopper_paid_hours_hv, 0)) as shopper_paid_availability_pct
    , (reg_shopper_available_hours / nullif(shopper_paid_hours,0)) as shopper_paid_availability_store
    , (num_late_slam / nullif(num_orders,0)) as late_slam_pct
    , (scheduled_hours_capped / nullif(planned_hours,0)) as sched_fill_rate
    , (sun_scheduled_hours_capped / nullif(sun_planned_hours,0)) as sun_sched_fill_rate
    , (scheduled_hours / nullif(planned_hours,0)) as schedule_compliance_pct
    , (absent_hours / nullif(scheduled_hours,0)) as absent_pct
    , (num_subs + sub_rejected + no_response_short)/nullif((num_shorts + num_subs - do_not_replace),0) as replacement_pct
    , ((num_subs + num_shorts) / nullif(inf_denominator,0)) as inf_pct
    , ((forecasted_units - actual_units) / nullif(forecasted_units,0)) as forecast_miss
    , forecasted_units
    , picked_units 
    , sales
	, orders
    , (sales / nullif(sales_overall,0)) as net_sales_wfmoa_pct
	, (sales / nullif(orders,0)) as basket_size
from consolidated_table_base 
where week_end_date = date(date_add('week',-1,date_trunc('week',GETDATE())+'5 days'::interval))
);

--------------------------------------------------------------------------------------- 
--Consolidated table T minus 2
drop table if exists consolidated_table_tminus2;
create temp table consolidated_table_tminus2 as (
select 
	  store_region
	, store_id
	, store_name_abb 
	, store_name 
	, week_end_date
	, (1 - (availability_today_customers / nullif(cu_visits,0))) as same_day_unavail_pct
	, (num_cu / nullif(cu_visits,0)) as complete_unavail_pct
	, (ooc_visits_pick_exec/nullif(total_visits,0)) as pe_ooc_pct
	, ((paid_wages * (1 + burdened_wages_rate)) / nullif (picked_units,0)) as vcpu
	, (picked_units / nullif(paid_hours,0)) as uplh
	, (requested_units / nullif(picked_hours,0)) as uph
	, ((picked_hours + coalesce(dropoff_hours,0))/ nullif(paid_hours,0)) as paid_utilization_old
	, (available_hours_hv / nullif(paid_hours_hv,0)) as paid_availability_pct
	, (available_hours / nullif(paid_hours,0)) as paid_availability_pct_old
	, ((reg_shopper_picked_hours_hv + reg_shopper_dropoff_hours_hv) / nullif((shopper_paid_hours_hv + otj_paid_hours_hv),0)) as shopper_paid_utilization_hv
	, ((reg_shopper_picked_hours + reg_shopper_dropoff_hours) / nullif((shopper_paid_hours + otj_paid_hours),0)) as shopper_paid_utilization_store
	, (reg_shopper_available_hours_hv / nullif(shopper_paid_hours_hv, 0)) as shopper_paid_availability_pct
    , (reg_shopper_available_hours / nullif(shopper_paid_hours,0)) as shopper_paid_availability_store
    , (num_late_slam / nullif(num_orders,0)) as late_slam_pct
    , (scheduled_hours_capped / nullif(planned_hours,0)) as sched_fill_rate
    , (sun_scheduled_hours_capped / nullif(sun_planned_hours,0)) as sun_sched_fill_rate
    , (scheduled_hours / nullif(planned_hours,0)) as schedule_compliance_pct
    , (absent_hours / nullif(scheduled_hours,0)) as absent_pct
    , (num_subs + sub_rejected + no_response_short)/nullif((num_shorts + num_subs - do_not_replace),0) as replacement_pct
    , ((num_subs + num_shorts) / nullif(inf_denominator,0)) as inf_pct
    , ((forecasted_units - actual_units) / nullif(forecasted_units,0)) as forecast_miss
    , forecasted_units
    , picked_units 
    , sales
	, orders
    , (sales / nullif(sales_overall,0)) as net_sales_wfmoa_pct
	, (sales / nullif(orders,0)) as basket_size
from consolidated_table_base 
where week_end_date = date(date_add('week',-2,date_trunc('week',GETDATE())+'5 days'::interval))
);

--------------------------------------------------------------------------------------- 
--Consolidated table WoW
drop table if exists consolidated_table_wow;
create temp table consolidated_table_wow as (
select 
	  c.store_region 
	, c.store_id
	, c.store_name_abb 
	, c.store_name
	, ((c.same_day_unavail_pct - ct2.same_day_unavail_pct)*100)*100 as same_day_unavail_pct_wow_change
	, ((c.complete_unavail_pct - ct2.complete_unavail_pct)*100)*100 as complete_unavail_pct_wow_change
	, ((c.pe_ooc_pct - ct2.pe_ooc_pct)*100)*100 as pe_ooc_pct_wow_change
	, (c.vcpu - ct2.vcpu) as vcpu_wow_change
	, (c.uplh - ct2.uplh)*100 as uplh_wow_change
	, (c.uph - ct2.uph)*100 as uph_wow_change
	, ((c.paid_utilization_old - ct2.paid_utilization_old)*100)*100 as paid_utilization_old_wow_change
	, ((c.paid_availability_pct - ct2.paid_availability_pct)*100)*100 as paid_availability_pct_wow_change
	, ((c.paid_availability_pct_old - ct2.paid_availability_pct_old)*100)*100 as paid_availability_pct_old_wow_change
	, ((c.shopper_paid_utilization_hv - ct2.shopper_paid_utilization_hv)*100)*100 as shopper_paid_utilization_hv_wow_change
	, ((c.shopper_paid_utilization_store - ct2.shopper_paid_utilization_store)*100)*100 as shopper_paid_utilization_store_wow_change
	, ((c.shopper_paid_availability_pct - ct2.shopper_paid_availability_pct)*100)*100 as shopper_paid_availability_pct_wow_change
	, ((c.shopper_paid_availability_store - ct2.shopper_paid_availability_store)*100)*100 as shopper_paid_availability_store_wow_change
	, ((c.late_slam_pct - ct2.late_slam_pct)*100)*100 as late_slam_wow_change
	, ((c.sched_fill_rate - ct2.sched_fill_rate)*100)*100 as sched_fill_rate_wow_change
	, ((c.sun_sched_fill_rate - ct2.sun_sched_fill_rate)*100)*100 as sun_sched_fill_rate_wow_change
	, ((c.schedule_compliance_pct - ct2.schedule_compliance_pct)*100)*100 as schedule_compliance_pct_wow_change
	, ((c.absent_pct - ct2.absent_pct)*100)*100 as absent_pct_wow_change
	, ((c.replacement_pct - ct2.replacement_pct)*100)*100 as replacement_pct_wow_change
	, ((c.inf_pct - ct2.inf_pct)*100)*100 as inf_pct_wow_change
	, ((c.forecast_miss - ct2.forecast_miss)*100)*100 as forecast_miss_wow_change
	, (c.forecasted_units - ct2.forecasted_units) as forecasted_units_wow_change
	, (c.picked_units - ct2.picked_units) as picked_units_wow_change
	, (c.sales - ct2.sales) as sales_wow_change
	, (c.orders - ct2.orders) as orders_wow_change
	, ((c.net_sales_wfmoa_pct - ct2.net_sales_wfmoa_pct)*100)*100 as net_sales_wfmoa_pct_wow_change
	, (c.basket_size - ct2.basket_size) as basket_size_wow_change
from consolidated_table_lw c 
join consolidated_table_tminus2 ct2 on 
	c.store_region = ct2.store_region and 
	c.store_id = ct2.store_id 
);

--------------------------------------------------------------------------------------- 
--Consolidated table T4W
drop table if exists consolidated_table_t4w;
create temp table consolidated_table_t4w as (
select 
	  store_region
	, store_id
	, store_name_abb 
	, store_name 
	, (1 - sum(availability_today_customers) / sum(nullif(cu_visits,0))) as same_day_unavail_pct_t4
	, sum(num_cu) / sum(nullif(cu_visits,0)) as complete_unavail_pct_t4
	, sum(ooc_visits_pick_exec) / sum(nullif(total_visits,0)) as pe_ooc_pct_t4
	, sum(paid_wages) * (1 + ( 0.23710000)) / sum(nullif(picked_units,0)) as vcpu_t4
	, sum(picked_units) / sum(nullif(paid_hours,0)) as uplh_t4
	, sum(requested_units) / sum(nullif(picked_hours,0)) as uph_t4
	, (sum(picked_hours) + sum(dropoff_hours))/ (sum(nullif(paid_hours,0))) as paid_utilization_old_t4
	, sum(available_hours_hv) / (sum(nullif(paid_hours_hv,0))) as paid_availability_pct_t4
	, sum(available_hours)/ (sum(nullif(paid_hours,0))) as paid_availability_pct_old_t4
	, (sum(reg_shopper_picked_hours_hv) + sum(reg_shopper_dropoff_hours_hv)) / (sum(nullif(shopper_paid_hours_hv,0)) + sum(nullif(otj_paid_hours_hv,0))) as shopper_paid_utilization_hv_t4
	, (sum(reg_shopper_picked_hours) + sum(reg_shopper_dropoff_hours)) / (sum(nullif(shopper_paid_hours,0)) + sum(nullif(otj_paid_hours,0))) as shopper_paid_utilization_store_t4
	, sum(reg_shopper_available_hours_hv) / (sum(nullif(shopper_paid_hours_hv,0))) as shopper_paid_availability_pct_t4
    , sum(reg_shopper_available_hours) / (sum(nullif(shopper_paid_hours,0))) as shopper_paid_availability_store_t4
    , sum(num_late_slam ) / sum(nullif(num_orders,0)) as late_slam_pct_t4
    , sum(scheduled_hours_capped) / sum(nullif(planned_hours,0)) as sched_fill_rate_t4
    , sum(sun_scheduled_hours_capped) / sum(nullif(sun_planned_hours,0)) as sun_sched_fill_rate_t4
    , sum(scheduled_hours) / sum(nullif(planned_hours,0)) as schedule_compliance_pct_t4
    , sum(absent_hours) / sum(nullif(scheduled_hours,0)) as absent_pct_t4
    , (sum(num_subs) + sum(sub_rejected) + sum(no_response_short))/ (sum(nullif(num_shorts,0)) + sum(nullif(num_subs,0)) - sum(nullif(do_not_replace,0))) as replacement_pct_t4
    , (sum(num_subs) + sum(num_shorts)) / sum(nullif(inf_denominator,0)) as inf_pct_t4
    , (sum(forecasted_units) - sum(actual_units)) / sum(nullif(forecasted_units,0)) as forecast_miss_t4
    , sum(forecasted_units) as forecasted_units_t4
    , sum(picked_units) as picked_units_t4
    , sum(sales) as sales_t4
	, sum(orders) as orders_t4
    , sum(sales) / sum(nullif(sales_overall,0)) as net_sales_wfmoa_pct_t4
	, sum(sales) / sum(nullif(orders,0)) as basket_size_t4
from consolidated_table_base 
group by 1,2,3,4
order by 1,2,3,4
);

--------------------------------------------------------------------------------------- 
--Consolidated table final 
drop table if exists consolidated_table_final;
create temp table consolidated_table_final as (
select 
	  c.store_region
	, c.store_id
	, c.store_name_abb
	, c.store_name
	, same_day_unavail_pct
	, complete_unavail_pct
	, pe_ooc_pct
	, vcpu
	, uplh
	, uph
	, paid_utilization_old
	, paid_availability_pct
	, paid_availability_pct_old
	, shopper_paid_utilization_hv
	, shopper_paid_utilization_store
	, shopper_paid_availability_pct
	, shopper_paid_availability_store
	, late_slam_pct 
	, sched_fill_rate
	, sun_sched_fill_rate
	, schedule_compliance_pct
	, absent_pct
	, replacement_pct
	, inf_pct
	, forecast_miss
	, forecasted_units
	, picked_units
	, sales
	, orders
	, net_sales_wfmoa_pct
	, basket_size
	, same_day_unavail_pct_wow_change
	, complete_unavail_pct_wow_change
	, pe_ooc_pct_wow_change
	, vcpu_wow_change
	, uplh_wow_change
	, uph_wow_change
	, paid_utilization_old_wow_change
	, paid_availability_pct_wow_change
	, paid_availability_pct_old_wow_change
	, shopper_paid_utilization_hv_wow_change
	, shopper_paid_utilization_store_wow_change
	, shopper_paid_availability_pct_wow_change
	, shopper_paid_availability_store_wow_change
	, late_slam_wow_change
	, sched_fill_rate_wow_change
	, sun_sched_fill_rate_wow_change
	, schedule_compliance_pct_wow_change
	, absent_pct_wow_change
	, replacement_pct_wow_change
	, inf_pct_wow_change
	, forecast_miss_wow_change
	, forecasted_units_wow_change
	, picked_units_wow_change
	, sales_wow_change
	, orders_wow_change
	, net_sales_wfmoa_pct_wow_change
	, basket_size_wow_change
	, same_day_unavail_pct_t4
	, complete_unavail_pct_t4
	, pe_ooc_pct_t4
	, vcpu_t4
	, uplh_t4
	, uph_t4 
	, paid_utilization_old_t4
	, paid_availability_pct_t4
	, paid_availability_pct_old_t4
	, shopper_paid_utilization_hv_t4
	, shopper_paid_utilization_store_t4
	, shopper_paid_availability_pct_t4
	, shopper_paid_availability_store_t4
	, late_slam_pct_t4
	, sched_fill_rate_t4
	, sun_sched_fill_rate_t4
	, schedule_compliance_pct_t4
	, absent_pct_t4
	, replacement_pct_t4
	, inf_pct_t4
	, forecast_miss_t4
	, forecasted_units_t4
	, picked_units_t4
	, sales_t4
	, orders_t4
	, net_sales_wfmoa_pct_t4
	, basket_size_t4
from consolidated_table_lw c
join consolidated_table_wow cw on 
	c.store_region = cw.store_region and 
	c.store_id = cw.store_id
join consolidated_table_t4w ct on 
	c.store_region = ct.store_region and
	c.store_id = ct.store_id 
order by 1,2,3,4
);
--------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------- 
--AUTO-FLEX base
drop table if exists auto_flex_base;
create temp table auto_flex_base as (
select
	weekend_date
	, case when region_name = 'Mid-Atlantic' then 'MA'
		   when region_name = 'Midwest' then 'MW'
		   when region_name = 'Southeast' then 'SE'
		   when region_name = 'Southwest' then 'SW'
		   when region_name = 'Northern California' then 'NC'
		   when region_name = 'Northeast' then 'NE'
		   when region_name = 'North Atlantic' then 'NA'
		   when region_name = 'Southern Pacific' then 'SP'
		   when region_name = 'Mountain Pacific' then 'MP'
		   when region_name = 'Global' then 'GL'
		   else null end as region_abbr
	, store_number
	, store_abbr
	, store_name 
	, sum(hc_flex_in_compliance_numerator) as hc_flex_in_compliance_numerator 
	, sum(hc_flex_denominator) as hc_flex_denominator
from ##
where 
	pickup_delivery = 'All' and 
	labor_model = 'All' and 
	grain = 'Weekly' and 
	weekend_date  >= date(date_add('week',-4,date_trunc('week',GETDATE())+'5 days'::interval)) and 
	weekend_date <= getdate()-3
group by 1,2,3,4,5
order by 1,2,3,4,5
);
--------------------------------------------------------------------------------------- 
--AUTO-FLEX LW
drop table if exists autoflex_lw;
create temp table autoflex_lw as (
select
	  weekend_date
	, region_abbr
	, store_number
	, store_abbr
	, store_name 
	, sum(hc_flex_in_compliance_numerator)/sum(hc_flex_denominator) as labor_flexibility
from auto_flex_base
where 
	weekend_date  = date(date_add('week',-1,date_trunc('week',GETDATE())+'5 days'::interval)) 
group by 1,2,3,4,5
);

--------------------------------------------------------------------------------------- 
--AUTO-FLEX T-MINUS 2
drop table if exists autoflex_t2w;
create table autoflex_t2w as (
select
	  weekend_date
	, region_abbr
	, store_number
	, store_abbr
	, store_name 
	, sum(hc_flex_in_compliance_numerator)/sum(hc_flex_denominator) as labor_flexibility
from auto_flex_base
where 
	weekend_date  = date(date_add('week',-2,date_trunc('week',GETDATE())+'5 days'::interval)) 
group by 1,2,3,4,5
);

--------------------------------------------------------------------------------------- 
--AUTO-FLEX WOW
drop table if exists autoflex_wow;
create temp table autoflex_wow as (
select 
	  al.region_abbr
	, al.store_number 
	, al.store_abbr
	, al.store_name
	, ((al.labor_flexibility - at2.labor_flexibility)*100)*100 as labor_flexibility_wow
from autoflex_lw al
join autoflex_t2w at2 on 
	al.region_abbr = at2.region_abbr and 
	al.store_number = at2.store_number
);
--------------------------------------------------------------------------------------- 
--AUTO-FLEX T4W
drop table if exists autoflex_t4;
create temp table autoflex_t4 as (
select
	  region_abbr 
	, store_number
	, store_abbr
	, store_name 
	, sum(hc_flex_in_compliance_numerator)/sum(hc_flex_denominator) as labor_flexibility_t4
from auto_flex_base at2
group by 1,2,3,4
);
--------------------------------------------------------------------------------------- 
--AUTO-FLEX FINAL
drop table if exists autoflex_final;
create temp table autoflex_final as (
select
	  autoflex_lw.region_abbr
	, autoflex_lw.store_number
	, autoflex_lw.store_abbr
	, autoflex_lw.store_name
	, autoflex_lw.labor_flexibility
	, labor_flexibility_wow
	, labor_flexibility_t4
from autoflex_lw 
join autoflex_wow aw on 
	autoflex_lw.region_abbr = aw.region_abbr and 
	autoflex_lw.store_number = aw.store_number 
join autoflex_t4 at4 on 
	autoflex_lw.region_abbr = at4.region_abbr and 
	autoflex_lw.store_number = at4.store_number
);
--------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------- 
--PDOR base
drop table if exists pdor_base;
create temp table pdor_base as (
select
	  weekend_date
	, region_abbr
	, store_abbr
	, store_number
	, store_name
	, sum(miss_utr_miss) as miss_utr_miss 
	, sum(num_orders_cust_wait) as num_orders_cust_wait
from ##
where 
	labor_model = 'All' and 
	low_volume = 'All' and 
	checkinsource = 'ON_MY_WAY' and 
	grain = 'Weekly' and 
	weekend_date  >= date(date_add('week',-4,date_trunc('week',GETDATE())+'5 days'::interval)) and 
	weekend_date  <= getdate()-3
group by 1,2,3,4,5
);
--------------------------------------------------------------------------------------- 
--PDOR LW
drop table if exists pdor_lw;
create temp table pdor_lw as (
select
	  region_abbr 
	, store_number
	, store_abbr
	, store_name 
	, sum(miss_utr_miss)/sum(num_orders_cust_wait) as utr_miss_pct
from pdor_base
where 
	weekend_date  = date(date_add('week',-1,date_trunc('week',GETDATE())+'5 days'::interval))
group by 1,2,3,4
);
--------------------------------------------------------------------------------------- 
--PDOR T-2W
drop table if exists pdor_tminus2;
create temp table pdor_tminus2 as (
select 
	  region_abbr 
	, store_number
	, store_abbr
	, store_name 
	, sum(miss_utr_miss)/sum(num_orders_cust_wait) as utr_miss_pct
from pdor_base
where 
	weekend_date  = date(date_add('week',-2,date_trunc('week',GETDATE())+'5 days'::interval))
group by 1,2,3,4
);
--------------------------------------------------------------------------------------- 
--PDOR WoW
drop table if exists pdor_wow;
create temp table pdor_wow as (
select 
	  pl.region_abbr
	, pl.store_number
	, pl.store_abbr
	, pl.store_name
	, (sum(pl.utr_miss_pct) - sum(pt2.utr_miss_pct)*100)*100 as utr_miss_wow
from pdor_lw pl
join pdor_tminus2 pt2 on 
	pl.region_abbr = pt2.region_abbr and
	pl.store_number = pt2.store_number
group by 1,2,3,4
);
--------------------------------------------------------------------------------------- 
--PDOR T4W
drop table if exists pdor_t4;
create temp table pdor_t4 as (
select 
	  region_abbr 
	, store_number
	, store_abbr
	, store_name 
	, sum(miss_utr_miss)/sum(num_orders_cust_wait) as utr_miss_pct_t4
from pdor_base
group by 1,2,3,4
);
---------------------------------------------------------------------------------------
--PDOR FINAL 
drop table if exists pdor_final;
create temp table pdor_final as (
select 
	  pdor_lw.region_abbr
	, pdor_lw.store_number
	, pdor_lw.store_abbr
	, pdor_lw.store_name
	, pdor_lw.utr_miss_pct
	, pdor_wow.utr_miss_wow
	, pdor_t4.utr_miss_pct_t4
from pdor_lw
join pdor_wow on 
	 pdor_lw.region_abbr = pdor_wow.region_abbr and 
	 pdor_lw.store_abbr = pdor_wow.store_abbr
join pdor_t4 on 
	 pdor_lw.region_abbr = pdor_t4.region_abbr and 
	 pdor_lw.store_abbr = pdor_t4.store_abbr
);
--------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------- 
--QUALITY CONCESSIONS BASE - STORE
drop table if exists quality_concessions_base_store;
create temp table quality_concessions_base_store as (
with lasst1 as (
select 
	 store_name_abb
   , max(case when metric ilike '%ENCRYPTED_MID%' then value else null end) as encrypted_merchant_id
   , replace(max(case when metric ilike '%Store_Code%' then value else null end),'WFM','10') as store_code
   , cast(max(case when metric ilike '%region%' then value else null end) as varchar(5)) region_lasst
from bison.wfm_lasst 
group by 1
order by 1),
concessions1 as (
select 
	 date(dateadd(day,6,date(week_start))) as week_end
   , region_lasst as region_abbr
   , store_name_abb 
   , cast(store_code as int) as store_code
   , case when concession_bucket = 'Tier 1' then cast(sum(conceded_orders) as decimal(10,2)) end as conceded_orders
   , case when concession_bucket = 'Tier 1' then cast(sum(total_orders) as decimal(10,2)) end as tier1_total_orders
   , case when concession_bucket = '% w/ Expired/Rotten/Moldy' then cast(sum(conceded_orders) as decimal(10,2)) end as erm_conceded_orders
   , case when concession_bucket = '% w/ Expired/Rotten/Moldy' then cast(sum(total_orders) as decimal(10,2)) end as erm_total_orders
   , sum(distinct total_orders) as total_orders
   , case when concession_bucket = '% w/ Expired/Rotten/Moldy' then sum(conceded_orders) end as erm_concessions
from ## 
join lasst1 on lasst1.encrypted_merchant_id = dwqcs.merchant_id
where delivery_type = 'All' and 
	  week_end  >= date(date_add('week',-5,date_trunc('week',GETDATE())+'5 days'::interval)) and 
	  week_end  <= getdate()-6
group by 1,2,3,4, concession_bucket)
select 
 	 week_end
	,region_abbr
	,store_name_abb 
	,store_code
	,max(conceded_orders) as conceded_orders
	,max(tier1_total_orders) as tier1_total_orders
	,max(erm_conceded_orders) as erm_conceded_orders
	,max(erm_total_orders) as erm_total_orders
from concessions1
group by 1,2,3,4
order by 1,2,3,4
);
--------------------------------------------------------------------------------------- 
--QUALITY CONCESSIONS BASE - REGION
drop table if exists quality_concessions_base_region;
create temp table quality_concessions_base_region as (
select 
	  week_end
	, region_abbr 
	, 'REG' as store_name_abb
	, 11111 as store_code
	, sum(conceded_orders) as conceded_orders
	, sum(tier1_total_orders) as tier1_total_orders
	, sum(erm_conceded_orders) as erm_conceded_orders
	, sum(erm_total_orders) as erm_total_orders
from quality_concessions_base_store
group by 1,2,3,4
order by 1,2,3,4
);
--------------------------------------------------------------------------------------- 
--QUALITY CONCESSIONS BASE - Global
drop table if exists quality_concessions_base_global;
create temp table quality_concessions_base_global as (
select 
	  week_end
	, 'GL' as region_abbr 
	, 'GBL' as store_name_abb
	, 0 as store_code
	, sum(conceded_orders) as conceded_orders
	, sum(tier1_total_orders) as tier1_total_orders
	, sum(erm_conceded_orders) as erm_conceded_orders
	, sum(erm_total_orders) as erm_total_orders
from quality_concessions_base_store
group by 1,2,3,4
order by 1,2,3,4
);
--------------------------------------------------------------------------------------- 
--QUALITY CONCESSIONS BASE 
drop table if exists quality_concessions_base;
create temp table quality_concessions_base as (
select * from quality_concessions_base_store
union 
select * from quality_concessions_base_region
union
select * from quality_concessions_base_global
);

--------------------------------------------------------------------------------------- ---------------------------------------------------------------------------------------
--QUALITY CONCESSIONS LW 
drop table if exists quality_concession_lw;
create temp table quality_concession_lw as (
select 
	  week_end
	, region_abbr
	, store_code
	, store_name_abb
	, sum(conceded_orders)/sum(tier1_total_orders) as quality_concession_rate
	, sum(erm_conceded_orders)/sum(erm_total_orders) as erm_concession_rate
from quality_concessions_base qcb
where week_end  = date(date_add('week',-2,date_trunc('week',GETDATE())+'5 days'::interval)) 
group by 1,2,3,4
);
--------------------------------------------------------------------------------------- 
--QUALITY CONCESSIONS T2W 
drop table if exists quality_concession_tminus2w;
create temp table quality_concession_tminus2w as (
select 
	  week_end
	, region_abbr
	, store_code
	, store_name_abb
	, sum(conceded_orders)/sum(tier1_total_orders) as quality_concession_rate
	, sum(erm_conceded_orders)/sum(erm_total_orders) as erm_concession_rate
from quality_concessions_base qcb
where week_end  = date(date_add('week',-3,date_trunc('week',GETDATE())+'5 days'::interval)) 
group by 1,2,3,4
);
--------------------------------------------------------------------------------------- 
--QUALITY CONCESSIONS WOW
drop table if exists quality_concessions_wow;
create temp table quality_concessions_wow as (
select 
	  ql.region_abbr
	, ql.store_code
	, ql.store_name_abb
	, ((ql.quality_concession_rate - qtm.quality_concession_rate)*100)*100 as quality_concession_rate_wow
	, ((ql.erm_concession_rate - qtm.erm_concession_rate)*100)*100 as erm_concession_rate_wow
from quality_concession_lw ql 
join quality_concession_tminus2w qtm on 
	ql.region_abbr = qtm.region_abbr and 
	ql.store_code = qtm.store_code
);
--------------------------------------------------------------------------------------- 
--QUALITY CONCESSIONS T4W
drop table if exists quality_concession_t4;
create temp table quality_concession_t4 as (
select 
	  region_abbr
	, store_code
	, store_name_abb
	, sum(conceded_orders)/sum(tier1_total_orders) as quality_concession_rate_t4
	, sum(erm_conceded_orders)/sum(erm_total_orders) as erm_concession_rate_t4
from quality_concessions_base qcb
group by 1,2,3
);
--------------------------------------------------------------------------------------- 
--QUALITY CONCESSIONS Final
drop table if exists quality_concession_final;
create temp table quality_concession_final as (
select 
	  ql.region_abbr
	, ql.store_code
	, ql.store_name_abb
	, ql.quality_concession_rate
	, ql.erm_concession_rate
	, qw.quality_concession_rate_wow
	, qw.erm_concession_rate_wow
	, qt.quality_concession_rate_t4
	, qt.erm_concession_rate_t4
from quality_concession_lw ql
join quality_concessions_wow qw on 
	ql.region_abbr = qw.region_abbr and 
	ql.store_code = qw.store_code
join quality_concession_t4 qt on 
	ql.region_abbr = qt.region_abbr and 
	ql.store_code = qt.store_code 
);
--------------------------------------------------------------------------------------- 
--FOOD SAFETY Base Store
drop table if exists food_safety_base_store;
create temp table food_safety_base_store as (
select 
	  weekend_date 
	, region_abbr 
	, store_id 
	, store_name_abb 
	, sum(bagging_opportunities) as bagging_opportunities 
	, sum(bagging_compliant) as bagging_compliant 
	, sum(temp_opportunities) as temp_opportunities 
	, sum(temp_miss) as temp_miss 
from ##
where 
	  weekend_date  >= date(date_add('week',-4,date_trunc('week',GETDATE())+'5 days'::interval)) and 
	  weekend_date  <= getdate()-3  and 
	  grain  = 'Weekly'  
group by 1,2,3,4
order by 1,2,4
);
--------------------------------------------------------------------------------------- 
--FOOD SAFETY Base Region
drop table if exists food_safety_base_region;
create temp table food_safety_base_region as (
select 
	  weekend_date 
	, region_abbr 
	, 11111 as store_id 
	, 'REG' as store_name_abb 
	, sum(bagging_opportunities) as bagging_opportunities 
	, sum(bagging_compliant) as bagging_compliant 
	, sum(temp_opportunities) as temp_opportunities 
	, sum(temp_miss) as temp_miss 
from food_safety_base_store
group by 1,2,3,4
order by 1,2,4
);
--------------------------------------------------------------------------------------- 
--FOOD SAFETY Base Global
drop table if exists food_safety_base_global;
create temp table food_safety_base_global as (
select 
	  weekend_date 
	, 'GL' as region_abbr 
	, 0 as store_id 
	, 'GBL' as store_name_abb 
	, sum(bagging_opportunities) as bagging_opportunities 
	, sum(bagging_compliant) as bagging_compliant 
	, sum(temp_opportunities) as temp_opportunities 
	, sum(temp_miss) as temp_miss 
from food_safety_base_store 
group by 1,2,3,4
order by 1,2,4
);
--------------------------------------------------------------------------------------- 
--FOOD SAFETY Base
drop table if exists food_safety_base;
create temp table food_safety_base as (
select * from food_safety_base_store 
union 
select * from food_safety_base_region 
union 
select * from food_safety_base_global
);
--------------------------------------------------------------------------------------- 
--FOOD SAFETY LW
drop table if exists food_safety_lw;
create temp table food_safety_lw as (
select 
	  weekend_date
	, region_abbr
	, store_id
	, store_name_abb
	, round(sum(bagging_compliant)/(sum(bagging_opportunities)*1.0),4) as bagging_compliance_pct
	, round(1-((sum(temp_miss))/(sum(temp_opportunities)*1.0)),4) as temp_compliance_pct 
from food_safety_base 
where 
	weekend_date  = date(date_add('week',-1,date_trunc('week',GETDATE())+'5 days'::interval)) 
 group by 1,2,3,4
 order by 2,4
);
--------------------------------------------------------------------------------------- 
--FOOD SAFETY TMINUS 2
 drop table if exists food_safety_tminus2;
create temp table food_safety_tminus2 as (
select 
	  weekend_date
	, region_abbr
	, store_id
	, store_name_abb
	, round(sum(bagging_compliant)/(sum(bagging_opportunities)*1.0),4) as bagging_compliance_pct
	, round(1-((sum(temp_miss))/(sum(temp_opportunities)*1.0)),4) as temp_compliance_pct 
from food_safety_base 
where 
	weekend_date  <= date(date_add('week',-2,date_trunc('week',GETDATE())+'5 days'::interval)) 
 group by 1,2,3,4
);
 --------------------------------------------------------------------------------------- 
--FOOD SAFETY WOW
drop table if exists food_safety_wow;
create temp table food_safety_wow as (
select 
	  fl.region_abbr
	, fl.store_id
	, fl.store_name_abb
	, ((sum(fl.bagging_compliance_pct) - sum(ftm.bagging_compliance_pct))*100)*100 as bagging_compliance_pct_wow
	, ((sum(fl.temp_compliance_pct) - sum(ftm.temp_compliance_pct))*100)*100 as temp_compliance_pct_wow
from food_safety_lw fl 
join food_safety_tminus2 ftm on 
	fl.region_abbr = ftm.region_abbr and 
	fl.store_id = ftm.store_id 
group by 1,2,3
order by 1,3
);
 
--------------------------------------------------------------------------------------- 
--FOOD SAFETY T4W
drop table if exists food_safety_t4;
create temp table food_safety_t4 as (
select 
	  region_abbr
	, store_id
	, store_name_abb
	, round(sum(bagging_compliant)/(sum(bagging_opportunities)*1.0),4) as bagging_compliance_pct_t4
	, round(1-((sum(temp_miss))/(sum(temp_opportunities)*1.0)),4) as temp_compliance_pct_t4  
from food_safety_base 
group by 1,2,3
order by 1,3
);
---------------------------------------------------------------------------------------
--FOOD SAFETY Final
drop table if exists food_safety_final;
create temp table food_safety_final as (
select 
	  fl.region_abbr
	, fl.store_id
	, fl.store_name_abb
	, bagging_compliance_pct
	, temp_compliance_pct
	, bagging_compliance_pct_wow
	, temp_compliance_pct_wow
	, bagging_compliance_pct_t4
	, temp_compliance_pct_t4
from food_safety_lw fl 
join food_safety_wow fw on 
	fl.region_abbr = fw.region_abbr and 
	fl.store_id = fw.store_id 
join food_safety_t4 ft on 
	fl.region_abbr = ft.region_abbr and
	fl.store_id = ft.store_id 
order by 1,3
);
--------------------------------------------------------------------------------------- 
--COMBINE QUERY - FINAL
drop table if exists landing_page_base; 
create temp table landing_page_base as (
select 
	  date(date_add('week',-1,date_trunc('week',GETDATE())+'5 days'::interval)) as week_end_date
	, c.store_region as region_abbr
	, c.store_id 
	, c.store_name_abb
	, c.store_name
	, same_day_unavail_pct
	, complete_unavail_pct
	, pe_ooc_pct
	, vcpu
	, uplh
	, uph
	, paid_utilization_old
	, paid_availability_pct
	, paid_availability_pct_old
	, shopper_paid_utilization_hv
	, shopper_paid_utilization_store
	, shopper_paid_availability_pct
	, shopper_paid_availability_store
	, late_slam_pct 
	, sched_fill_rate
	, sun_sched_fill_rate
	, schedule_compliance_pct
	, absent_pct
	, replacement_pct
	, inf_pct
	, forecast_miss
	, forecasted_units
	, picked_units
	, sales
	, orders
	, net_sales_wfmoa_pct
	, basket_size
	, labor_flexibility --auto-flex
	, utr_miss_pct --pdor
	, quality_concession_rate --concessions
	, erm_concession_rate --concessions
	, bagging_compliance_pct --fs 
	, temp_compliance_pct --fs 
	, same_day_unavail_pct_wow_change
	, complete_unavail_pct_wow_change
	, pe_ooc_pct_wow_change
	, vcpu_wow_change
	, uplh_wow_change
	, uph_wow_change
	, paid_utilization_old_wow_change
	, paid_availability_pct_wow_change
	, paid_availability_pct_old_wow_change
	, shopper_paid_utilization_hv_wow_change
	, shopper_paid_utilization_store_wow_change
	, shopper_paid_availability_pct_wow_change
	, shopper_paid_availability_store_wow_change
	, late_slam_wow_change
	, sched_fill_rate_wow_change
	, sun_sched_fill_rate_wow_change
	, schedule_compliance_pct_wow_change
	, absent_pct_wow_change
	, replacement_pct_wow_change
	, inf_pct_wow_change
	, forecast_miss_wow_change
	, forecasted_units_wow_change
	, picked_units_wow_change
	, sales_wow_change
	, orders_wow_change
	, net_sales_wfmoa_pct_wow_change
	, basket_size_wow_change
	, labor_flexibility_wow --auto-flex
	, utr_miss_wow --pdor
	, quality_concession_rate_wow --concessions
	, erm_concession_rate_wow --concessions
	, bagging_compliance_pct_wow --fs 
	, temp_compliance_pct_wow --fs
	, same_day_unavail_pct_t4
	, complete_unavail_pct_t4
	, pe_ooc_pct_t4
	, vcpu_t4
	, uplh_t4
	, uph_t4 
	, paid_utilization_old_t4
	, paid_availability_pct_t4
	, paid_availability_pct_old_t4
	, shopper_paid_utilization_hv_t4
	, shopper_paid_utilization_store_t4
	, shopper_paid_availability_pct_t4
	, shopper_paid_availability_store_t4
	, late_slam_pct_t4
	, sched_fill_rate_t4
	, sun_sched_fill_rate_t4
	, schedule_compliance_pct_t4
	, absent_pct_t4
	, replacement_pct_t4
	, inf_pct_t4
	, forecast_miss_t4
	, forecasted_units_t4
	, picked_units_t4
	, sales_t4
	, orders_t4
	, net_sales_wfmoa_pct_t4
	, basket_size_t4
	, labor_flexibility_t4 --auto-flex
	, utr_miss_pct_t4 --pdor 
	, quality_concession_rate_t4 --concessions
	, erm_concession_rate_t4 --concession
	, bagging_compliance_pct_t4 --fs 
	, temp_compliance_pct_t4 --fs 
from consolidated_table_final c 
left join autoflex_final a on 
	c.store_region = a.region_abbr and 
	c.store_id = a.store_number 
left join pdor_final p on 
	c.store_region = p.region_abbr and 
	c.store_id = p.store_number 
left join quality_concession_final q on 
	c.store_region = q.region_abbr and 
	c.store_id = q.store_code 
left join food_safety_final f on 
	c.store_region = f.region_abbr and 
	c.store_id = f.store_id
order by 2,4
);
--------------------------------------------------------------------------------------- 
--LANDING PAGE FINAL
select
	  * 
	, case when (same_day_unavail_pct_t4 is not null) then (rank () over (order by same_day_unavail_pct_t4)) else null end as same_day_unavail_pct_netrk
	, case when (same_day_unavail_pct_t4 is not null) then (rank() over (partition by region_abbr order by same_day_unavail_pct_t4)) else null end as same_day_unavail_pct_regrk
	, case when (complete_unavail_pct_t4 is not null) then (rank () over (order by complete_unavail_pct_t4)) else null end as complete_unavail_pct_netrk
	, case when (complete_unavail_pct_t4 is not null) then (rank() over (partition by region_abbr order by complete_unavail_pct_t4)) else null end as complete_unavail_pct_regrk
	, case when (pe_ooc_pct_t4 is not null) then (rank () over (order by pe_ooc_pct_t4)) else null end as pe_ooc_pct_netrk
	, case when (pe_ooc_pct_t4 is not null) then (rank() over (partition by region_abbr order by pe_ooc_pct_t4)) else null end as pe_ooc_pct_regrk
	, case when (vcpu_t4 is not null) then (rank () over (order by vcpu_t4)) else null end as vcpu_netrk
	, case when (vcpu_t4 is not null) then (rank() over (partition by region_abbr order by vcpu_t4)) else null end as vcpu_regrk
	, case when (uplh_t4 is not null) then (rank () over (order by uplh_t4 desc)) else null end as uplh_netrk
	, case when (uplh_t4 is not null) then (rank() over (partition by region_abbr order by uplh_t4 desc)) else null end as uplh_regrk
	, case when (uph_t4 is not null) then (rank () over (order by uph_t4 desc)) else null end as uph_netrk
	, case when (uph_t4 is not null) then (rank() over (partition by region_abbr order by uph_t4 desc)) else null end as uph_regrk
	, case when (paid_utilization_old_t4 is not null) then (rank () over (order by paid_utilization_old_t4 desc)) else null end as paid_utilization_old_netrk
	, case when (paid_utilization_old_t4 is not null) then (rank() over (partition by region_abbr order by paid_utilization_old_t4 desc)) else null end as paid_utilization_old_regrk
	, case when (paid_availability_pct_t4 is not null) then (rank () over (order by paid_availability_pct_t4 desc)) else null end as paid_availability_pct_netrk
	, case when (paid_availability_pct_t4 is not null) then (rank() over (partition by region_abbr order by paid_availability_pct_t4 desc)) else null end as paid_availability_pct_regrk
	, case when (paid_availability_pct_old_t4 is not null) then (rank() over(order by paid_availability_pct_old_t4 desc)) else null end as paid_availability_pct_old_netrk
	, case when (paid_availability_pct_old_t4 is not null) then (rank() over (partition by region_abbr order by paid_availability_pct_old_t4 desc)) else null end as paid_availability_pct_old_regrk
	, case when (shopper_paid_utilization_hv_t4 is not null) then (rank () over (order by shopper_paid_utilization_hv_t4 desc)) else null end as shopper_paid_utilization_hv_netrk
	, case when (shopper_paid_utilization_hv_t4 is not null) then (rank() over (partition by region_abbr order by shopper_paid_utilization_hv_t4 desc)) else null end as shopper_paid_utilization_hv_regrk
	, case when (shopper_paid_utilization_store_t4 is not null) then (rank () over (order by shopper_paid_utilization_store_t4 desc)) else null end as shopper_paid_utilization_store_netrk
	, case when (shopper_paid_utilization_store_t4 is not null) then (rank() over (partition by region_abbr order by shopper_paid_utilization_store_t4 desc)) else null end as shopper_paid_utilization_store_regrk
	, case when (shopper_paid_availability_pct_t4 is not null) then (rank () over (order by shopper_paid_availability_pct_t4 desc)) else null end as shopper_paid_availability_pct_netrk
	, case when (shopper_paid_availability_pct_t4 is not null) then (rank() over (partition by region_abbr order by shopper_paid_availability_pct_t4 desc)) else null end as shopper_paid_availability_pct_regrk
	, case when (shopper_paid_availability_store_t4 is not null) then (rank() over (order by shopper_paid_availability_store_t4 desc)) else null end as shopper_paid_availability_store_netrk
	, case when (shopper_paid_availability_store_t4 is not null) then (rank() over (partition by region_abbr order by shopper_paid_availability_store_t4 desc)) else null end as shopper_paid_availability_store_regrk
	, case when (late_slam_pct_t4 is not null) then (rank() over (order by late_slam_pct_t4)) else null end as late_slam_pct_netrk
	, case when (late_slam_pct_t4 is not null) then (rank() over (partition by region_abbr order by late_slam_pct_t4)) else null end as late_slam_pct_regrk
	, case when (sched_fill_rate_t4 is not null) then (rank() over (order by sched_fill_rate_t4 desc)) else null end as sched_fill_rate_netrk
	, case when (sched_fill_rate_t4 is not null) then (rank() over (partition by region_abbr order by sched_fill_rate_t4 desc)) else null end as sched_fill_rate_regrk
	, case when (schedule_compliance_pct_t4 is not null) then (rank() over (order by schedule_compliance_pct_t4)) else null end as schedule_compliance_pct_netrk
	, case when (schedule_compliance_pct_t4 is not null) then (rank() over (partition by region_abbr order by schedule_compliance_pct_t4)) else null end as schedule_compliance_pct_regrk
	, case when (absent_pct_t4 is not null) then (rank() over (order by absent_pct_t4)) else null end as absent_pct_netrk
	, case when (absent_pct_t4 is not null) then (rank() over (partition by region_abbr order by absent_pct_t4)) else null end as absent_pct_regrk
	, case when (replacement_pct_t4 is not null) then (rank() over (order by replacement_pct_t4 desc)) else null end as replacement_pct_netrk
	, case when (replacement_pct_t4 is not null) then (rank() over (partition by region_abbr order by replacement_pct_t4 desc)) else null end as replacement_pct_regrk
	, case when (inf_pct_t4 is not null) then (rank() over (order by inf_pct_t4)) else null end as inf_pct_netrk
	, case when (inf_pct_t4 is not null) then (rank() over (partition by region_abbr order by inf_pct_t4)) else null end as inf_pct_regrk
	, case when (forecast_miss_t4 is not null) then (rank() over (order by forecast_miss_t4)) else null end as forecast_miss_netrk
	, case when (forecast_miss_t4 is not null) then (rank() over (partition by region_abbr order by forecast_miss_t4)) else null end as forecast_miss_regrk
	, case when (forecasted_units_t4 is not null) then (rank() over (order by forecasted_units_t4  desc)) else null end as forecasted_units_netrk
	, case when (forecasted_units_t4 is not null) then (rank() over (partition by region_abbr order by forecasted_units_t4 desc)) else null end as forecasted_units_regrk
	, case when (picked_units_t4 is not null) then (rank() over (order by picked_units_t4 desc)) else null end as picked_units_netrk
	, case when (picked_units_t4 is not null) then (rank() over (partition by region_abbr order by picked_units_t4 desc)) else null end as picked_units_regrk
	, case when (sales_t4 is not null) then (rank() over (order by sales_t4 desc)) else null end as sales_netrk
	, case when (sales_t4 is not null) then (rank() over (partition by region_abbr order by sales_t4 desc)) else null end as sales_regrk
	, case when (orders_t4 is not null) then (rank() over (order by orders_t4 desc)) else null end as orders_netrk
	, case when (orders_t4 is not null) then (rank() over (partition by region_abbr order by orders_t4 desc)) else null end as orders_regrk
	, case when (net_sales_wfmoa_pct_t4 is not null) then (rank() over (order by net_sales_wfmoa_pct_t4 desc)) else null end as net_sales_wfmoa_pct_netrk
	, case when (net_sales_wfmoa_pct_t4 is not null) then (rank() over (partition by region_abbr order by net_sales_wfmoa_pct_t4 desc)) else null end as net_sales_wfmoa_pct_regrk
	, case when (basket_size_t4 is not null) then (rank() over (order by basket_size_t4 desc)) else null end as basket_size_netrk
	, case when (basket_size_t4 is not null) then (rank() over (partition by region_abbr order by basket_size_t4 desc)) else null end as basket_size_regrk
	, case when (labor_flexibility_t4 is not null) then (rank() over (order by labor_flexibility_t4 desc)) else null end as labor_flexibility_netrk
	, case when (labor_flexibility_t4 is not null) then (rank() over (partition by region_abbr order by labor_flexibility_t4 desc)) else null end as labor_flexibility_regrk
	, case when (utr_miss_pct_t4 is not null) then (rank() over (order by utr_miss_pct_t4)) else null end as utr_miss_pct_netrk
	, case when (utr_miss_pct_t4 is not null) then (rank() over (partition by region_abbr order by utr_miss_pct_t4)) else null end as utr_miss_pct_regrk
	, case when (quality_concession_rate_t4 is not null) then (rank() over (order by quality_concession_rate_t4)) else null end as quality_concession_rate_netrk
	, case when (quality_concession_rate_t4 is not null) then (rank() over (partition by region_abbr order by quality_concession_rate_t4)) else null end as quality_concession_rate_regrk
	, case when (erm_concession_rate_t4 is not null) then (rank() over (order by erm_concession_rate_t4)) else null end as erm_concession_rate_netrk
	, case when (erm_concession_rate_t4 is not null) then (rank() over (partition by region_abbr order by erm_concession_rate_t4)) else null end as erm_concession_rate_regrk
	, case when (bagging_compliance_pct_t4 is not null) then (rank() over (order by bagging_compliance_pct_t4 desc)) else null end as bagging_compliance_pct_netrk
	, case when (bagging_compliance_pct_t4 is not null) then (rank() over (partition by region_abbr order by bagging_compliance_pct_t4 desc)) else null end as bagging_compliance_pct_regrk
	, case when (temp_compliance_pct_t4 is not null) then (rank() over (order by temp_compliance_pct_t4 desc)) else null end as temp_compliance_pct_netrk
	, case when (temp_compliance_pct_t4 is not null) then (rank() over (partition by region_abbr order by temp_compliance_pct_t4 desc)) else null end as temp_compliance_pct_regrk
--------------------------------------------------------------------------------------- 
--update score goals below
	, coalesce((pe_ooc_pct_t4-0.15)*100,0) as pe_ooc_score
	, coalesce((((late_slam_pct_t4 - 0.08)*100)*2),0) as late_slam_score
	--REMOVED LABOR FLEXIBILITY BASED ON FEEDBACK FROM KARLA AHL 5/12/2023
	--, (1-labor_flexibility_t4)*100 as labor_flexibility_score 
	, coalesce(((0.7-paid_utilization_old_t4)*100),0) as paid_utilization_old_score
	, coalesce(((0.8-paid_availability_pct_t4)*100),0) as paid_availability_pct_score
	, coalesce(((0.8-paid_availability_pct_old_t4)*100),0) as paid_availability_pct_old_score
	, coalesce(((75.0-uph_t4)*2),0) as uph_score
	, coalesce(((0.9-sched_fill_rate_t4)*100),0) as sched_fill_rate_score
	, coalesce((case when schedule_compliance_pct_t4 < 0.9 then ((0.9 - schedule_compliance_pct_t4)*100)
		   when schedule_compliance_pct_t4 > 1.05 then ((1.05-schedule_compliance_pct_t4)*100)
		   when (schedule_compliance_pct_t4 >= 0.9 and schedule_compliance_pct_t4 <= 1.05) then ((schedule_compliance_pct_t4 - 1.05)*100)
		   else 0 end),0) as schedule_compliance_pct_score
	, coalesce(((erm_concession_rate_t4 - 0.0185)*100),0) as erm_concession_score
	, coalesce((((0.97-bagging_compliance_pct_t4)*100)*2),0) as bagging_compliance_score
	, coalesce((((0.98 - replacement_pct_t4)*100)*2),0) as replacement_score
	, coalesce(((utr_miss_pct_t4 - 0.045)*100),0) as utr_miss_score
	, coalesce(((inf_pct_t4 - 0.034)*100),0) as inf_score
	, (pe_ooc_score + late_slam_score + paid_utilization_old_score + paid_availability_pct_score + uph_score + sched_fill_rate_score + schedule_compliance_pct_score + erm_concession_score +
	  bagging_compliance_score + replacement_score + utr_miss_score + inf_score) as total_score
from landing_page_base

