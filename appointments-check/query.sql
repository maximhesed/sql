use Company;

select name_full, birth_date, age, tags_count, gender, appointment_last
    from LeadDetails;

/*
select id, cid, sid, date
    from Appointments;
--*/

/* The valid appointments. */
insert into Appointments select 1, 2, '10-27-2020 16:00:00', '';
insert into Appointments select 2, 1, '10-25-2020 14:30:00', '';
insert into Appointments select 3, 2, '11-18-2020 17:30:00', '';
insert into Appointments select 5, 1, '10-21-2020 14:05:00', '';

/* The cross appointments. */
insert into Appointments select 1, 2, '10-27-2020 15:59:59', '';
insert into Appointments select 3, 2, '11-18-2020 16:20:00', '';
insert into Appointments select 5, 1, '10-21-2020 14:04:59', '';
