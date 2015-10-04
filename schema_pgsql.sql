CREATE TABLE Stations (
    id SERIAL NOT NULL,
    name VARCHAR(255) NOT NULL,
    CONSTRAINT Station_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE Customers (
    id SERIAL NOT NULL,
    name VARCHAR(255) NOT NULL,
    default_document_creds VARCHAR(255) NOT NULL,
    CONSTRAINT Customer_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE Tickets (
    id SERIAL NOT NULL,
    customer_id integer NOT NULL,
    status VARCHAR(255) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    user_doc_creds VARCHAR(255) NOT NULL,
    trip_id integer NOT NULL,
    coach_ref integer NOT NULL,
    seat integer NOT NULL,
    cost integer NOT NULL,
    order_date TIMESTAMPTZ NOT NULL,
    routeitem_start integer NOT NULL,
    routeitem_last integer NOT NULL,
    CONSTRAINT Ticket_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE Routes (
    id SERIAL NOT NULL,
    name VARCHAR(255) NOT NULL,
    departure_station integer NOT NULL,
    status VARCHAR(255) NOT NULL,
    active_since TIMESTAMPTZ NOT NULL,
    active_until TIMESTAMPTZ NOT NULL,
    CONSTRAINT Route_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE Coaches (
    id SERIAL NOT NULL,
    type integer NOT NULL,
    CONSTRAINT Coach_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE CoachTypes (
    id SERIAL NOT NULL,
    name VARCHAR(255) NOT NULL,
    base_price integer NOT NULL DEFAULT '1',
    seats integer NOT NULL,
    CONSTRAINT CoachType_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE TrainCoaches (
    id SERIAL NOT NULL,
    train_id integer NOT NULL,
    coach_id integer NOT NULL,
    coach_pos integer NOT NULL,
    CONSTRAINT TrainCoach_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE RouteItems (
    id SERIAL NOT NULL,
    route_id integer NOT NULL,
    station_id integer NOT NULL,
    route_position integer NOT NULL,
    price_score integer NOT NULL,
    stop_time integer NOT NULL,
    travel_time integer NOT NULL,
    CONSTRAINT RouteItem_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE Trains (
    id SERIAL NOT NULL,
    price_score integer NOT NULL,
    CONSTRAINT Train_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);



CREATE TABLE ScheduledTrains (
    id SERIAL NOT NULL,
    route_id integer NOT NULL,
    train_id integer NOT NULL,
    departure_time TIMESTAMPTZ NOT NULL,
    CONSTRAINT ScheduledTrain_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);


ALTER TABLE Tickets ADD CONSTRAINT Ticket_fk1 FOREIGN KEY (customer_id) REFERENCES Customers(id);
ALTER TABLE Tickets ADD CONSTRAINT Ticket_fk2 FOREIGN KEY (trip_id) REFERENCES ScheduledTrains(id);
ALTER TABLE Tickets ADD CONSTRAINT Ticket_fk3 FOREIGN KEY (coach_ref) REFERENCES TrainCoaches(id);
ALTER TABLE Tickets ADD CONSTRAINT Ticket_fk4 FOREIGN KEY (routeitem_start) REFERENCES RouteItems(id);
ALTER TABLE Tickets ADD CONSTRAINT Ticket_fk5 FOREIGN KEY (routeitem_last) REFERENCES RouteItems(id);

ALTER TABLE Routes ADD CONSTRAINT Route_fk0 FOREIGN KEY (departure_station) REFERENCES Stations(id);

ALTER TABLE Coaches ADD CONSTRAINT Coach_fk0 FOREIGN KEY (type) REFERENCES CoachTypes(id);


ALTER TABLE TrainCoaches ADD CONSTRAINT TrainCoach_fk0 FOREIGN KEY (train_id) REFERENCES Trains(id);
ALTER TABLE TrainCoaches ADD CONSTRAINT TrainCoach_fk1 FOREIGN KEY (coach_id) REFERENCES Coaches(id);

ALTER TABLE RouteItems ADD CONSTRAINT RouteItem_fk0 FOREIGN KEY (route_id) REFERENCES Routes(id);
ALTER TABLE RouteItems ADD CONSTRAINT RouteItem_fk1 FOREIGN KEY (station_id) REFERENCES Stations(id);


ALTER TABLE ScheduledTrains ADD CONSTRAINT ScheduledTrain_fk0 FOREIGN KEY (route_id) REFERENCES Routes(id);
ALTER TABLE ScheduledTrains ADD CONSTRAINT ScheduledTrain_fk1 FOREIGN KEY (train_id) REFERENCES Trains(id);

CREATE OR REPLACE FUNCTION getStation (text) RETURNS integer AS $$
  DECLARE
    station_name ALIAS FOR $1;
    s_id INTEGER;
  BEGIN
    select into s_id id from Stations where name=station_name limit 1;
    return s_id;
  END
$$
LANGUAGE plpgsql;
