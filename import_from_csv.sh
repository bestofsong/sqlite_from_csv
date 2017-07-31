#! /usr/bin/env sh

csv=$1
output=`echo $csv | sed -nE "s/\.[^.]+$/\.sqlite3/p"`

sql=".mode csv
.import $csv activate
create view if not exists total  (total_cnt, created_at) as select count(*),created_at from activate  group by created_at;
create view if not exists positive (positive_cnt, created_at) as select count(*),created_at from (select * from activate where status=1)  group by created_at;
create view if not exists negative  (negative_cnt, created_at) as select count(*),created_at from (select * from activate where status!=1)  group by created_at;
create view if not exists signed_up  (user_id_cnt, created_at) as select count(*),created_at from (select * from activate where user_id not null and user_id != 0)  group by created_at;
create view if not exists overview (total_cnt, positive_cnt, negative_cnt, user_id_cnt, created_at) as select total_cnt,positive_cnt,negative_cnt,user_id_cnt,total.created_at from total natural join positive natural join negative natural join signed_up order by total.created_at;
"
echo "$sql" | sqlite3 $output

