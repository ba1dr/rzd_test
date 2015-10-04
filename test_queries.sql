
-- Отсортировать по возрастанию стоимости маршруты из Владимира в Казань на 1 октября

with myconst as (select getStation('Владимир') as startstation,
                        getStation('Казань') as endstation,
                        DATE '2015-10-01' as dep_day)

select CoachTypes.name, Routes.id, Routes.name, sum(ri.price_score)*CoachTypes.base_price*Trains.price_score/1000/100 price, ScheduledTrains.departure_time
from Routes

inner join RouteItems ri on ri.route_id=Routes.id
  and ri.route_position > (select route_position 
                             from RouteItems ri_start
                             where ri_start.route_id=Routes.id and ri_start.station_id = (select startstation from myconst))
  and ri.route_position <= (select route_position
                              from RouteItems ri_end
                              where ri_end.route_id=Routes.id and ri_end.station_id = (select endstation from myconst))

inner join ScheduledTrains on ScheduledTrains.route_id=Routes.id
  and date_trunc('day', ScheduledTrains.departure_time) =
    (select (select dep_day from myconst) - (sum(ri_time.travel_time) + sum(stop_time))::integer minutes
       from RouteItems ri_time
       where ri_time.route_id=Routes.id
         and ri_time.route_position < (select route_position
                                         from RouteItems ri_start
                                         where ri_start.route_id=Routes.id and ri_start.station_id = (select startstation from myconst)))

inner join Trains on Trains.id=ScheduledTrains.train_id
inner join CoachTypes on CoachTypes.id in (select distinct(type)
                                           from Coaches, TrainCoaches
                                           where Coaches.id=TrainCoaches.coach_id and TrainCoaches.train_id=ScheduledTrains.train_id)

where Routes.status not in ('Archived') and (select dep_day from myconst) between Routes.active_since and Routes.active_until
group by Routes.id, Routes.name, ScheduledTrains.departure_time, CoachTypes.name, CoachTypes.base_price, Trains.price_score
order by price asc
;

--    name   | id |         name         | price |     departure_time     
-- ----------+----+----------------------+-------+------------------------
--  Сидячий  |  3 | Москва - Владивосток |  2717 | 2015-10-01 16:20:00+03
--  Плацкарт |  5 | Москва - Казань      |  5000 | 2015-10-01 11:44:00+03
--  Плацкарт |  3 | Москва - Владивосток |  5434 | 2015-10-01 16:20:00+03
--  Купе     |  3 | Москва - Владивосток | 10868 | 2015-10-01 16:20:00+03
--  СВ       |  3 | Москва - Владивосток | 21736 | 2015-10-01 16:20:00+03
-- (5 rows)



-- Вывести все доступные места на станции отправления на поезд N 4 (маршрут 4) Владивосток-Москва, отправляющийся 2015-10-20 10:15:05

with myconst as (
  select 6 as my_sctrain_id),
  reserved_seats as (select TrainCoaches.coach_pos, Tickets.seat
                       from Tickets
                       inner join ScheduledTrains on ScheduledTrains.id=(select my_sctrain_id from myconst)
                       inner join TrainCoaches on TrainCoaches.id=Tickets.coach_ref
                       where Tickets.trip_id=(select my_sctrain_id from myconst) and Tickets.status not in ('Cancelled'))

select * from (select TrainCoaches.coach_pos, generate_series(1, CoachTypes.seats) seat, CoachTypes.name as type
                 from TrainCoaches
                 inner join Coaches on Coaches.id=TrainCoaches.coach_id
                 inner join CoachTypes on CoachTypes.id=Coaches.type
                 inner join Scheduledtrains on ScheduledTrains.id=(select my_sctrain_id from myconst) and Scheduledtrains.train_id=TrainCoaches.train_id
                ) as allseats
where not exists (select *
                    from reserved_seats
                    where reserved_seats.coach_pos=allseats.coach_pos and reserved_seats.seat=allseats.seat)
;

--  coach_pos | seat |   type   
-- -----------+------+----------
--          1 |    1 | Плацкарт
--          1 |    2 | Плацкарт
-- ... skipped rows ...
--          6 |   71 | Сидячий
--          6 |   72 | Сидячий
-- (264 rows)
