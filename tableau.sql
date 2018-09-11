CREATE OR REPLACE FUNCTION tableau(start_timestamp timestamp, end_timestamp timestamp, room_type_desc text) RETURNS TABLE (datetime timestamp, building_id char, room_id char, description text) AS $$
	SELECT time_series::timestamp, t1.building_id, COALESCE(t1.room_id, parent_room.room_id), reservation.description
		FROM generate_series(start_timestamp, end_timestamp, '15 minute') as time_series
		CROSS JOIN (
			SELECT * from room where room.room_type_id = (
				SELECT room_type_id from room_type where room_type_name = room_type_desc)) t1
		LEFT JOIN room as parent_room ON parent_room.room_id = t1.parent_room_id
		LEFT JOIN reservation ON reservation.building_id = t1.building_id
			AND (reservation.room_id = t1.room_id OR reservation.room_id = parent_room.room_id OR reservation.room_id in (select room.room_id from room where room.parent_room_id = t1.room_id))
			AND reservation.start_timestamp <= time_series
			AND reservation.end_timestamp > time_series
		WHERE (time_series- interval '8:30')::time between '0:00' and '14:15'
		ORDER BY t1.room_id, time_series
$$ LANGUAGE SQL;

SELECT * FROM tableau('2018-08-27', '2018-08-28', 'computer laboratory');