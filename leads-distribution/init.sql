use Company;

create table Users (
    id int primary key,
    login nvarchar(32) not null unique,
    password_hash nvarchar(48) not null,
    name_first nvarchar(32) not null,
    name_last nvarchar(32) not null,
    patronymic nvarchar(32)
);

create table Leads (
    id int primary key,
    name_first nvarchar(32) not null,
    name_last nvarchar(32),
    patronymic nvarchar(32),
    phone nvarchar(16) not null unique
);

/* status is a bit value:
 *   0 - lead is active,
 *   1 - lead is inactive.
 *
 * The status becomes inactive, when the user calling the lead.
 */

create table Distribution (
    id int primary key,
    uid int,
    lid int,
    status tinyint default 0
);

/* result is a bit value:
 *   0 - call is failed (the lead changed his mind),
 *   1 - call is successful (the lead agreed)
 */

create table Calls (
    id int primary key,
    uid int,
    lid int,
    date datetime not null,
    result tinyint not null,
    duration smallint not null
);

/* The Skills and Requirements tables will be compared together
 * for effective distribution of the leads to the users.
 *
 * E. g.:
 *   The lead has a requirements for the knowledge, restraint,
 *   trade: 0.2, 0.6, 0.2, respectively. The Skills table is next:
 *
 *   +------------------------------------------------+
 *   | id    | uid    | knowledge | restraint | trade |
 *   |------------------------------------------------|
 *   | 1     | 1      | 0.25      | 0.25      | 0.5   |
 *   | 2     | 2      | 0.33      | 0.33      | 0.34  |
 *   | 3     | 3      | 0.1       | 0.4       | 0.5   |
 *   | ...   | ...    | ...       | ...       | ...   |
 *   +------------------------------------------------+
 *
 *   The Distribution table is next:
 *
 *   +--------------------------------+
 *   | id    | uid    | lid  | status |
 *   |--------------------------------|
 *   | 1     | 1      | 1    | 1      | <- user1
 *   | 2     | 1      | 2    | 1      |
 *   | 3     | 1      | 3    | 1      |
 *   | 4     | 1      | 4    | 1      |
 *   | 5     | 2      | 5    | 0      | <- user2
 *   | 6     | 2      | 6    | 1      |
 *   | 7     | 2      | 7    | 1      |
 *   | 8     | 2      | 8    | 1      |
 *   | 9     | 2      | 9    | 1      |
 *   | 10    | 3      | 10   | 0      | <- user3
 *   | 11    | 3      | 11   | 1      |
 *   | 12    | 3      | 12   | 1      |
 *   | 13    | 4      | 13   | 0      | <- user4
 *   | 14    | 4      | 14   | 1      |
 *   | 15    | 4      | 15   | 1      |
 *   | 16    | 4      | 16   | 1      |
 *   +--------------------------------+
 *
 *   In this case, only the user with id 1 satisfies L2A
 *   (Lead Allocation Algorithm), because:
 *     1. The standard deviation of its skills is approximately 0.318.
 *        Average of the leads distributed to the users is 4. 0.318 <= 10%(4).
 *     2. This user hasn't the active leads.
 *     3. In the intersection of the Users table and the two conditions above,
 *        only the user with id 1 remains. In this set, the user with id 1
 *        has the best skills.
 */

create table Skills (
    id int primary key,
    uid int,
    knowledge real not null, -- knowledge of the available products and services
    restraint real not null, -- an ability to show the calm, during the lead communication
    trade real not null -- how effective the user can to convince the lead
);

create table Requirements (
    id int primary key,
    lid int,
    knowledge real not null,
    restraint real not null,
    trade real not null
);

alter table Distribution
    add foreign key (uid)
        references Users(id),
        foreign key (lid)
        references Leads(id);

alter table Calls
    add foreign key (uid)
        references Users(id),
        foreign key (lid)
        references Leads(id);

alter table Skills
    add foreign key (uid)
        references Users(id);

alter table Requirements
    add foreign key (lid)
        references Leads(id);
