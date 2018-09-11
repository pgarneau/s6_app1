/*==============================================================*/
/* Trigger : log_insert                                         */
/*==============================================================*/
create or replace function log_insert()
returns trigger as
$BODY$
begin
insert into log (log_id, cip, log_timestamp, log_data) values (DEFAULT, new.cip, now(), concat('insert of reservation from ', new.start_timestamp, ' to ', new.start_timestamp));
return new;
end;
$BODY$
language plpgsql;

create trigger new_entry
after insert
on reservation
for each row
execute procedure log_insert();

/*==============================================================*/
/* Trigger : log_delete                                   */
/*==============================================================*/
create or replace function log_delete()
returns trigger as
$BODY$
begin
insert into log (log_id, cip , log_timestamp , log_data) values (DEFAULT, new.cip, now(), concat('deletion of reservation from ', new.start_timestamp, ' to ', new.start_timestamp));
return new;
end;
$BODY$
language plpgsql;

create trigger new_delete
after delete
on reservation
for each row
execute procedure log_delete();

/*==============================================================*/
/* Trigger : overlap_timestamp                                 */
/*==============================================================*/

CREATE OR REPLACE FUNCTION overlap_timestamp() RETURNS TRIGGER AS
$check_reservation$
	DECLARE i reservation%rowtype;
	BEGIN
		FOR i IN 
			SELECT * FROM reservation LEFT JOIN room 
				ON (room.room_id = reservation.room_id or  reservation.room_id = room.parent_room_id)
				WHERE (new.room_id = reservation.room_id or new.room_id = room.room_id or new.room_id = room.parent_room_id)
		LOOP
			IF (new.start_timestamp, new.end_timestamp) OVERLAPS (i.start_timestamp, i.end_timestamp) THEN
				RAISE EXCEPTION 'La plage horraire nest pas disponible';
			END IF;
		END LOOP;
		RETURN NEW;
	END;
$check_reservation$ 
LANGUAGE plpgsql;

create trigger verify_overlap
before insert
on reservation
for each row
execute procedure overlap_timestamp();

/*==============================================================*/
/* Table: CAMPUS                                                */
/*==============================================================*/
INSERT INTO campus
VALUES
    (DEFAULT, 'Campus de Longueuil'),
    (DEFAULT, 'Campus Principal'),
    (DEFAULT, 'Campus de la Sante');

/*==============================================================*/
/* Table: BUILDING                                              */
/*==============================================================*/
INSERT INTO building (building_id, campus_id, building_name)
VALUES
    ('A8', (select campus_id from campus where campus_name = 'Campus Principal'), 'Albert-Leblanc'),
    ('A9', (select campus_id from campus where campus_name = 'Campus Principal'), 'Albert-Leblanc'),
    ('J1', (select campus_id from campus where campus_name = 'Campus Principal'), 'Centre sportif'),
    ('J2', (select campus_id from campus where campus_name = 'Campus Principal'), 'Centre sportif'),
    ('B1', (select campus_id from campus where campus_name = 'Campus Principal'), 'Georges-Cabana'),
    ('B2', (select campus_id from campus where campus_name = 'Campus Principal'), 'Georges-Cabana'),
    ('B6', (select campus_id from campus where campus_name = 'Campus Principal'), 'Irenee-Pinard'),
    ('C1', (select campus_id from campus where campus_name = 'Campus Principal'), 'J.-Armand-Bombardier'),
    ('C2', (select campus_id from campus where campus_name = 'Campus Principal'), 'J.-Armand-Bombardier'),
    ('F1', (select campus_id from campus where campus_name = 'Campus Principal'), 'John-S.-Bourque'),
    ('D6', (select campus_id from campus where campus_name = 'Campus Principal'), 'Marie-Victorin'),
    ('D7', (select campus_id from campus where campus_name = 'Campus Principal'), 'Marie-Victorin'),
    ('B5', (select campus_id from campus where campus_name = 'Campus Principal'), 'Multifonctionnel'),
    ('A10', (select campus_id from campus where campus_name = 'Campus Principal'), 'Recherche en sciences humaines et sociales'),
    ('D8', (select campus_id from campus where campus_name = 'Campus Principal'), 'Sciences de la vie'),
    ('E1', (select campus_id from campus where campus_name = 'Campus Principal'), 'Vie etudiante'),
    ('X8', (select campus_id from campus where campus_name = 'Campus de la Sante'), 'Centre de recherche du CHUS');

/*==============================================================*/
/* Table: CHARACTERISTIC                                        */
/*==============================================================*/
insert into characteristic
VALUES
    (DEFAULT, 'internet connection'),
    (DEFAULT, 'capacity'),
    (DEFAULT, 'chairs'),
    (DEFAULT, 'windows');

/*==============================================================*/
/* Table: FACULTY                                               */
/*==============================================================*/
insert into faculty
VALUES
    (DEFAULT, 'engineering');

/*==============================================================*/
/* Table: DEPARTMENT                                            */
/*==============================================================*/
insert into department
VALUES
    (DEFAULT, (select faculty_id from faculty where faculty_name = 'engineering'), 'computer engineering'),
    (DEFAULT, (select faculty_id from faculty where faculty_name = 'engineering'), 'electrical engineering'),
    (DEFAULT, (select faculty_id from faculty where faculty_name = 'engineering'), 'mechanical engineering'),
    (DEFAULT, (select faculty_id from faculty where faculty_name = 'engineering'), 'civil engineering');

/*==============================================================*/
/* Table: MEMBER                                                */
/*==============================================================*/
insert into member
VALUES
    ('garp2405', 'Garneau', 'Philippe', 'philippe.garneau@usherbrooke.ca'),
    ('fonj1903', 'Fontaine', 'Jacob', 'jacob.fontaine@usherbrooke.ca'),
    ('bosa2002', 'Bosco', 'Axel', 'axel.bosco@usherbrooke.ca'),
    ('beae2211', 'Beaudoin', 'Eric', 'eric.d.beaudoin@usherbrooke.ca'),
    ('asdf1111', 'Mailhot', 'Frederick', 'frederick.mailhot@usherbrooke.ca'),
    ('asdf2222', 'Beaulieu', 'Bernard', 'bernard.beaulieu@usherbrooke.ca'),
    ('asdf3333', 'Palao Munoz', 'Domingo', 'domingo.palao.munoz@usherbrooke.ca'),
    ('asdf4444', 'Gouin', 'Jean-Philippe', 'jean-philippe.gouin@usherbrooke.ca');

/*==============================================================*/
/* Table: DEPARTMENT_MEMBERS                                    */
/*==============================================================*/
insert into DEPARTMENT_MEMBERS (department_id, cip)
VALUES
    ((select department_id from department where department_name = 'computer engineering'), 'garp2405'),
    ((select department_id from department where department_name = 'computer engineering'), 'fonj1903'),
    ((select department_id from department where department_name = 'computer engineering'), 'bosa2002'),
    ((select department_id from department where department_name = 'computer engineering'), 'beae2211'),
    ((select department_id from department where department_name = 'computer engineering'), 'asdf1111'),
    ((select department_id from department where department_name = 'electrical engineering'), 'asdf1111'),
    ((select department_id from department where department_name = 'computer engineering'), 'asdf2222'),
    ((select department_id from department where department_name = 'computer engineering'), 'asdf3333'),
    ((select department_id from department where department_name = 'electrical engineering'), 'asdf4444');

/*==============================================================*/
/* Table: ROLE                                                  */
/*==============================================================*/
insert into role
VALUES
    (DEFAULT, 'teacher'),
    (DEFAULT, 'student'),
    (DEFAULT, 'tech support'),
    (DEFAULT, 'management');

/*==============================================================*/
/* Table: MEMBER_ROLES                                          */
/*==============================================================*/
insert into member_roles
VALUES
    ('garp2405', (select role_id from role where role_name = 'student')),
    ('fonj1903', (select role_id from role where role_name = 'student')),
    ('bosa2002', (select role_id from role where role_name = 'student')),
    ('beae2211', (select role_id from role where role_name = 'student')),
    ('asdf1111', (select role_id from role where role_name = 'management')),
    ('asdf2222', (select role_id from role where role_name = 'teacher')),
    ('asdf3333', (select role_id from role where role_name = 'teacher')),
    ('asdf4444', (select role_id from role where role_name = 'tech support'));

/*==============================================================*/
/* Table: PERMISSION                                            */
/*==============================================================*/
insert into permission
VALUES
    (DEFAULT, 'write'),
    (DEFAULT, 'read'),
    (DEFAULT, 'write-24'),
    (DEFAULT, 'write-12'),
    (DEFAULT, 'write-4'),
    (DEFAULT, 'delete');

/*==============================================================*/
/* Table: ROOM_TYPE                                             */
/*==============================================================*/
insert into room_type VALUES
    (DEFAULT, 'classroom'),
    (DEFAULT, 'laboratory'),
    (DEFAULT, 'recording studio'),
    (DEFAULT, 'computer laboratory');

/*==============================================================*/
/* Table: PRIVELEGES                                            */
/*==============================================================*/
insert into privileges
VALUES
    ((select role_id from role where role_name = 'teacher'),
     (select room_type_id from room_type where room_type_name = 'computer laboratory'),
     (select permission_id from permission where permission_name = 'write-24'),
     (select department_id from department where department_name = 'computer engineering')),
    ((select role_id from role where role_name = 'teacher'),
     (select room_type_id from room_type where room_type_name = 'computer laboratory'),
     (select permission_id from permission where permission_name = 'delete'),
     (select department_id from department where department_name = 'computer engineering')),
    ((select role_id from role where role_name = 'student'),
     (select room_type_id from room_type where room_type_name = 'classroom'),
     (select permission_id from permission where permission_name = 'write-4'),
     (select department_id from department where department_name = 'computer engineering'));

/*==============================================================*/
/* Table: ROOM                                                  */
/*==============================================================*/
insert into room (room_id, parent_room_id, room_type_id, building_id, campus_id, parent_building_id, parent_campus_id)
VALUES
    ('3125', null, (select room_type_id from room_type where room_type_name = 'computer laboratory'), 'C1', (select campus_id from campus where campus_name = 'Campus Principal'), null, null),
    ('3125-1', '3125', (select room_type_id from room_type where room_type_name = 'computer laboratory'), 'C1', (select campus_id from campus where campus_name = 'Campus Principal'), 'C1', (select campus_id from campus where campus_name = 'Campus Principal')),
    ('3125-2', '3125', (select room_type_id from room_type where room_type_name = 'computer laboratory'), 'C1', (select campus_id from campus where campus_name = 'Campus Principal'), 'C1', (select campus_id from campus where campus_name = 'Campus Principal')),
    ('4103', null, (select room_type_id from room_type where room_type_name = 'computer laboratory'), 'C2', (select campus_id from campus where campus_name = 'Campus Principal'), null, null),
    ('4103-1', '4103', (select room_type_id from room_type where room_type_name = 'computer laboratory'), 'C2', (select campus_id from campus where campus_name = 'Campus Principal'), 'C2', (select campus_id from campus where campus_name = 'Campus Principal')),
    ('3035', null, (select room_type_id from room_type where room_type_name = 'classroom'), 'C1', (select campus_id from campus where campus_name = 'Campus Principal'), null, null),
    ('5029', null, (select room_type_id from room_type where room_type_name = 'classroom'), 'C1', (select campus_id from campus where campus_name = 'Campus Principal'), null, null); 

/*==============================================================*/
/* Table: RESERVATION                                           */
/*==============================================================*/
insert into reservation
values 
    ('garp2405', (select campus_id from campus where campus_name = 'Campus Principal'), 'C1', '3125', '2018-08-27 08:30:00', '2018-08-27 09:30:00', 'Res local 1'),
    ('garp2405', (select campus_id from campus where campus_name = 'Campus Principal'), 'C1', '3125-1', '2018-08-27 10:00:00', '2018-08-27 10:30:00', 'Res sous-local 1'),
    ('garp2405', (select campus_id from campus where campus_name = 'Campus Principal'), 'C2', '4103-1', '2018-08-27 11:00:00', '2018-08-27 11:30:00', 'Res sous-local 2'),
    ('garp2405', (select campus_id from campus where campus_name = 'Campus Principal'), 'C1', '3125', '2018-08-27 13:30:00', '2018-08-27 14:30:00', 'Res local 3');

/*==============================================================*/
/* Table: ROOM_CHARACTERISTICS                                  */
/*==============================================================*/
insert into room_characteristics (room_id, characteristic_id, quantity, campus_id, building_id)
VALUES
    ('3125', (select characteristic_id from characteristic where characteristic_name = 'capacity'), 32, (select campus_id from campus where campus_name = 'Campus Principal'), 'C1'),
    ('3125', (select characteristic_id from characteristic where characteristic_name = 'internet connection'), 12, (select campus_id from campus where campus_name = 'Campus Principal'), 'C1'),
    ('3035', (select characteristic_id from characteristic where characteristic_name = 'capacity'), 25, (select campus_id from campus where campus_name = 'Campus Principal'), 'C1'),
    ('5029', (select characteristic_id from characteristic where characteristic_name = 'capacity'), 12, (select campus_id from campus where campus_name = 'Campus Principal'), 'C1');

/*==============================================================*/
/* Table: ROOM_UNAVAILABILITIES                                 */
/*==============================================================*/

create table ROOM_UNAVAILABILITIES (
   CAMPUS_ID            INT4                 not null,
   BUILDING_ID          CHAR(8)              not null,
   ROOM_ID              CHAR(8)              not null,
   UNAVAILABILITY_ID    INT4                 not null,
   constraint PK_ROOM_UNAVAILABILITIES primary key (CAMPUS_ID, BUILDING_ID, ROOM_ID, UNAVAILABILITY_ID)
);

/*==============================================================*/
/* Table: UNAVAILABILITY                                        */
/*==============================================================*/
create table UNAVAILABILITY (
   UNAVAILABILITY_ID    SERIAL               not null,
   UNAVAILABILITY_START_TIMESTAMP TIMESTAMP            not null,
   UNAVAILABILITY_END_TIMESTAMP TIMESTAMP            not null,
   constraint PK_UNAVAILABILITY primary key (UNAVAILABILITY_ID)
);