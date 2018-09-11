/*==============================================================*/
/* Trigger : log_insert                                         */
/*==============================================================*/
create or replace function log_activity ()
returns trigger as
$BODY$
DECLARE
   
delete_message varchar := ''; --CONCAT('delete of reservation from ', old.start_timestamp, ' to ', old.end_timestamp);
update_message varchar := ''; --CONCAT('change of reservation from ', old.start_timestamp, ' to ', old.end_timestamp, ' is now ',new.start_timestamp, ' to ', new.end_timestamp);
insert_message varchar := ''; --CONCAT('insert of reservation from ', new.start_timestamp, ' to ', new.end_timestamp);

begin
    IF (TG_OP = 'DELETE') THEN
		delete_message := CONCAT('delete of reservation from ', old.start_timestamp, ' to ', old.end_timestamp);
        insert into log (log_id, cip , log_timestamp , log_data) values (DEFAULT,old.cip,now(),delete_message);
       return old;
    ELSIF (TG_OP = 'UPDATE') THEN
	 	update_message := CONCAT('change of reservation : ', old.start_timestamp, ' to ', old.end_timestamp, ' was updated to ',new.start_timestamp, ' to ', new.end_timestamp);
        insert into log (log_id, cip , log_timestamp , log_data) values (DEFAULT,new.cip,now(),update_message);
       return new;
    ELSIF (TG_OP = 'INSERT') THEN
	insert_message := CONCAT('insert of reservation from ', new.start_timestamp, ' to ', new.end_timestamp);
        insert into log (log_id, cip , log_timestamp , log_data) values (DEFAULT,new.cip,now(),insert_message);
       return new;
        
    END IF; 
	
end
$BODY$
language plpgsql;


CREATE TRIGGER new_activity
AFTER INSERT OR UPDATE OR DELETE 
on reservation
for each row
execute procedure log_activity();

/*==============================================================*/
/* Trigger : overlap_timestamp                                 */
/*==============================================================*/
CREATE OR REPLACE FUNCTION overlap_timestamp() RETURNS TRIGGER AS
$BODY$
	DECLARE j reservation%rowtype;
	BEGIN
		FOR j IN 
			SELECT * FROM reservation LEFT JOIN room 
				ON ( reservation.room_id = room.parent_room_id or room.room_id = reservation.room_id   )
				WHERE ( new.room_id = room.room_id  or new.room_id = reservation.room_id or new.room_id = room.parent_room_id)
		LOOP
			IF  (j.start_timestamp, j.end_timestamp) OVERLAPS (new.start_timestamp, new.end_timestamp)  THEN
				RAISE EXCEPTION 'overlap detecter dans la reservation';
			END IF;
		END LOOP;
		RETURN NEW;
	END;
$BODY$ 
LANGUAGE plpgsql;

CREATE TRIGGER new_entry
BEFORE INSERT
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
insert into member_roles (cip, role_id, assignment_timestamp)
VALUES
    ('garp2405', (select role_id from role where role_name = 'student'), now()),
    ('fonj1903', (select role_id from role where role_name = 'student'), now()),
    ('bosa2002', (select role_id from role where role_name = 'student'), now()),
    ('beae2211', (select role_id from role where role_name = 'student'), now()),
    ('asdf1111', (select role_id from role where role_name = 'management'), now()),
    ('asdf2222', (select role_id from role where role_name = 'teacher'), now()),
    ('asdf3333', (select role_id from role where role_name = 'teacher'), now()),
    ('asdf4444', (select role_id from role where role_name = 'tech support'), now());

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
/* Table: UNAVAILABILITY                                        */
/*==============================================================*/
insert into unavailability
VALUES
    (DEFAULT, '2018-09-30 09:00:00', '2018-09-30 10:00:00');

/*==============================================================*/
/* Table: ROOM_UNAVAILABILITIES                                 */
/*==============================================================*/
insert into room_unavailabilities
VALUES
    ((select campus_id from campus where campus_name = 'Campus Principal'), 'C1', '3125', (select unavailability_id from unavailability where unavailability_start_timestamp = '2018-09-30 09:00:00'));
