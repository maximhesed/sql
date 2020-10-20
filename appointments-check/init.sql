use Company;

create table Leads (
    id int primary key identity,
    name_first nvarchar(32) not null,
    name_last nvarchar(32) not null,
    patronymic nvarchar(32),
    email nvarchar(256),
    phone nvarchar(16) not null,
    gender bit not null, -- 0 is male, 1 is female
    reg_date date not null,
    birth_date date not null
);

create table Tags (
    id int primary key identity,
    name nvarchar(32) not null,
    color nvarchar(32) not null
);

create table LeadTags (
    id int primary key identity,
    cid int,
    tid int
);

create table Services (
    id int primary key identity,
    name nvarchar(128) not null,
    description nvarchar(max),
    price decimal(8, 2) not null,
    discount tinyint,
    duration int not null -- in minutes
);

create table Appointments (
    id int primary key identity,
    cid int,
    sid int,
    date smalldatetime not null,
    comment nvarchar(max)
);

alter table LeadTags
    add foreign key (cid)
        references Leads(id),
        foreign key (tid)
        references Tags(id);

alter table Appointments
    add foreign key (cid)
        references Leads(id),
        foreign key (sid)
        references Services(id);

go

create view LeadDetails
as
select cast(Leads.name_last + ' ' + Leads.name_first + ' '
            + Leads.patronymic as nvarchar(32)) as name_full,
        Leads.birth_date,
        datediff(year, Leads.birth_date, current_timestamp) as age,
        count(LeadTags.tid) as tags_count,
        case Leads.gender
            when 0 then 'Male'
            when 1 then 'Female'
        end as gender,
        Appointments.date as appointment_last
    from Leads
        left join Appointments
        on Appointments.cid = Leads.id and Appointments.date = (
            select max(date)
                from Appointments
                    where Appointments.cid = Leads.id
        )
        join LeadTags
        on LeadTags.cid = leads.id
        group by Leads.name_last, Leads.name_first, Leads.patronymic,
            Leads.birth_date, Leads.gender, Appointments.date;

go

create trigger AppointmentUpdate
    on Appointments
    after insert
    not for replication -- disable the trigger, when modifying an its table
as
begin
    declare @insTimeStart smalldatetime = (
        select date
            from inserted
    );

    if exists(
        select Appointments.date
            from Appointments
                join inserted
                on inserted.cid = Appointments.cid
                where Appointments.id != inserted.id
                    and @insTimeStart < (
                        select dateadd(minute, Services.duration, Appointments.date)
                            from Appointments as Appointments_copy
                                join Services
                                on Services.id = Appointments.sid
                                where Appointments_copy.id = Appointments.id
                    )
    ) begin
        declare @cid int = (
            select cid
                from inserted
        );

        raiserror('Attempting to insert the cross appointment for the lead with id %d.', 16, 1, @cid);

        rollback tran;
    end;
end;
