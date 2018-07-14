
select Q_2017.Round_lat,  Q_2017.Round_long, Q_2016.Y_2016, Q_2017.Y_2017, abs((cast(Q_2017.Y_2017 as decimal)-Q_2016.Y_2016)) as diffrence,
 (cast(Q_2017.Y_2017 as decimal)/Q_2016.Y_2016) as Growth,osm_israel.osm_tags,osm_israel.osm_name,osm_israel.osm_primitive,
case 
WHEN  (cast(Q_2017.Y_2017 as decimal)/(Q_2016.Y_2016))>1 THEN 'Rise'
WHEN (cast(Q_2017.Y_2017 as decimal)/(Q_2016.Y_2016))<1 THEN 'Decline'
else 'No change'
end

from (
-- 2017 column
        (select 
            to_char(longitude,'99D9999') as "round_long",
         to_char(latitude,'99D9999') as "round_lat", 
         count (id) as Y_2017
         from markers
         where date_part ('year', created) = '2017'
         group by round_long, round_lat) as Q_2017
         
         join 
         -- 2016 column
         (select 
             to_char(longitude,'99D9999') as "round_long" ,
         to_char(latitude,'99D9999') as "round_lat", 
         count (id) as Y_2016
         from markers
         where date_part ('year', created) = '2016'
         group by round_long, round_lat)  as Q_2016
         on (Q_2017.round_long =  Q_2016.round_long and Q_2016.round_lat =  Q_2017.round_lat))
-- Geocoding
join osm_israel
on ST_covers (ST_setSRID(osm_israel."geometry",4326)::geography,st_makepoint((cast(Q_2017.round_long as float)), (cast(Q_2017.round_lat as float))))
-- Filter for low results and no change
where Q_2017.Y_2017 + Q_2016.Y_2016 > 25 
and 
((cast(Q_2017.Y_2017 as decimal)/(Q_2016.Y_2016))> 1.3 or (cast(Q_2017.Y_2017 as decimal)/(Q_2016.Y_2016))< 0.7)
order by diffrence desc
