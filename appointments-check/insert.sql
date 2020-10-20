use Company;

insert into Leads select 'Peter', 'Phelps', '', 'peter.phelps@gmail.com', '39885023252', 0, '10-20-2020', '09-08-1987';
insert into Leads select 'Mark', 'Stevens', '', 'mark.stevens@gmail.com', '46181031458', 0, '10-20-2020', '09-01-1998';
insert into Leads select 'Aubrey', 'Tucker', '', 'aubrey.tucker@gmail.com', '719603281922', 0, '10-20-2020', '12-02-1999';
insert into Leads select 'Thomas', 'Logan', '', 'thomas.logan@gmail.com', '82608994321', 0, '10-20-2020', '07-12-1980';
insert into Leads select 'Frank', 'Bridges', '', 'frank.bridges@gmail.com', '070302006337', 0, '10-20-2020', '06-27-1990';

insert into Tags select 'New', 'Light gray';
insert into Tags select 'Regular', 'Light green';
insert into Tags select 'Cold', 'Light blue';
insert into Tags select 'Hot', 'Light red';

insert into LeadTags select 1, 1;
insert into LeadTags select 2, 1;
insert into LeadTags select 2, 3;
insert into LeadTags select 3, 1;
insert into LeadTags select 4, 1;
insert into LeadTags select 5, 1;

insert into Services select 'Cleaning of the apartment', '', 5000, 10, 60;
insert into Services select 'Garbage removal', '', 100, 10, 5;

insert into Appointments select 1, 1, '10-27-2020 15:00:00', '';
insert into Appointments select 3, 1, '10-21-2020 16:30:00', '';
insert into Appointments select 3, 1, '11-18-2020 16:30:00', '';
insert into Appointments select 5, 2, '10-21-2020 14:00:00', '';
