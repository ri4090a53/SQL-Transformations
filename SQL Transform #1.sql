--------------------------------------------------------------------------------------- 
--Consolidated table base store
drop table if exists consolidated_table_base_store;
create temp table consolidated_table_base_store as (
select
	  x.*
	, xx.a
	, xx.b
	, xx.c 
from (
select
	  case when store_region in ('','') then '' else store_region end as store_region
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
	, sum(atc) as atc
	, sum(cv) as cv
	, sum(num_cu) as num_cu
	, sum(ovpe) as ovpe 
	, sum(total_visits) as total_visits
	, sum(num_ls) as num_ls
	, sum(num_orders) as num_orders
	, sum(ph) as ph
	, sum(dh) as dh
	, sum(pah) as pah
	, sum(ru) as ru
	, sum(num_s) as num_s
	, sum(sub_r) as sub_r
	, sum(no_response_s) as no_response_s  
	, sum(num_s) as num_s
	, sum(infd) as infd
	, sum(dnr) as dnr
	, sum(sales) as sales
	, sum(orders) as orders
	, sum(sales_overall) as sales_overall
	, sum(pw) as pw -- VCPU
	, 0.23710000 as bwr
	, sum(picku) as picku
	, sum(ta) as ta
	, sum(case when x = '' then rsah else 0 end) as rshv_hv --network/region l
	, sum(case when x = '' then sph else 0 end) as sph_hv
	, sum(rsah) as rsah --store 
	, sum(sph) as sph --store
	, sum(case when x = '' then rsph else 0 end) as rsph_hv
	, sum(case when x = '' then rsdh else 0 end) as rsdh_hv
	, sum(case when x = '' then oph else 0 end) as oph_hv
	, sum(case when x = '' then pah  else 0 end) as pah_hv
	, sum(case when x = '' then ta  else 0 end) as ah_hv
	, sum(rsph) as rsph --shopper  
	, sum(rsdh) as rsdh --shopper 
	, sum(oph) as oph --shopper 
	, sum(sh) as sh
	, sum(plh) as plh
	, sum(ah) as ah
	, sum(fu) as fu
	, sum(au) as au 
from ##
where 
	week_end_date  >= date(date_add('week',-4,date_trunc('week',GETDATE())+'5 days'::interval)) and 
	week_end_date <= getdate()-3 and
	metric_grain  = 'Daily' 
group by 1,2,3,4,5
order by 1,2) x
left join 
(select 
	  case when store_region in ('','') then '' else store_region end as store_region
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
	, sum(case when plh > 0 and sch >= plh then plh
	            when plh > 0 then sch
	            else null end) as schc  
	, sum(plh) as plh 
	, sum(case when date_part('dow',to_date(data_day,'YYYY-MM-DD')) = 0 then (case when plh > 0 
                                                                               and sch >= plh then plh
															                   when plh > 0 then sch
															                   else null end) else 0 end) as ssch
	, sum(case when date_part('dow',to_date(data_day,'YYYY-MM-DD')) = 0 then plh else 0 end) as splh
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
	, sum(atc) as atc
	, sum(cv) as cv
	, sum(num_cu) as num_cu
	, sum(ovpe) as ovpe
	, sum(total_visits) as total_visits
	, sum(num_ls) as num_ls
	, sum(num_orders) as num_orders
	, sum(ph) as ph
	, sum(dh) as dh
	, sum(pah) as pah
	, sum(ru) as ru
	, sum(num_s) as num_s
	, sum(sub_r) as sub_r
	, sum(no_response_s) as no_response_s
	, sum(infd) as infd
	, sum(dnr) as dnr
	, sum(sales) as sales
	, sum(orders) as orders
	, sum(sales_overall) as sales_overall
	, sum(pw) as pw
	, avg(bwr) as bwr
	, sum(picku) as picku
	, sum(ta) as ta
	, sum(rshv_hv) as rshv_hv
	, sum(sph_hv) as sph_hv
	, sum(rsah) as rsah
	, sum(sph) as sph
	, sum(rsph_hv) as rsph_hv
	, sum(rsdh_hv) as rsdh_hv
	, sum(oph_hv) as oph_hv
	, sum(pah_hv) as pah_hv
	, sum(ah_hv) as ah_hv	
	, sum(rsph) as rsph
	, sum(rsdh) as rsdh
	, sum(oph) as otj_oph
	, sum(sh) as sh	
	, sum(plh) as plh
	, sum(ah) as ah
	, sum(fu) as fu
	, sum(au) as au
	, sum(sch) as sch
	, sum(ssch) as ssch
	, sum(splh) as splh	
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
	, sum(atc) as atc
	, sum(cv) as cv
	, sum(num_cu) as num_cu
	, sum(ovpe) as ovpe
	, sum(total_visits) as total_visits
	, sum(num_ls) as num_ls
	, sum(num_orders) as num_orders
	, sum(ph) as ph
	, sum(dh) as dh
	, sum(pah) as pah
	, sum(ru) as ru
	, sum(num_s) as num_s
	, sum(sub_r) as sub_r
	, sum(no_response_s) as no_response_s
	, sum(infd) as infd
	, sum(dnr) as dnr
	, sum(sales) as sales
	, sum(orders) as orders
	, sum(sales_overall) as sales_overall
	, sum(pw) as pw
	, avg(bwr) as bwr
	, sum(picku) as picku
	, sum(ta) as ta
	, sum(rshv_hv) as rshv_hv
	, sum(sph_hv) as sph_hv
	, sum(rsah) as rsah
	, sum(sph) as sph
	, sum(rsph_hv) as rsph_hv
	, sum(rsdh_hv) as rsdh_hv
	, sum(oph_hv) as oph_hv
	, sum(pah_hv) as pah_hv
	, sum(ah_hv) as ah_hv	
	, sum(rsph) as rsph
	, sum(rsdh) as rsdh
	, sum(oph) as otj_oph
	, sum(sh) as sh	
	, sum(plh) as plh
	, sum(ah) as ah
	, sum(fu) as fu
	, sum(au) as au
	, sum(sch) as sch
	, sum(ssch) as ssch
	, sum(splh) as splh	
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
