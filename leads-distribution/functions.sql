use Company;

go

create function GetSd(@knowledge real, @restraint real, @trade real) returns real
begin
    declare @avg real = (@knowledge + @restraint + @trade) / 3;
    declare @p1 real = power(@knowledge - @avg, 2.0);
    declare @p2 real = power(@restraint - @avg, 2.0);
    declare @p3 real = power(@trade - @avg, 2.0);
    declare @sd real = sqrt((@p1 + @p2 + @p3) / 3);

    return @sd;
end;

go

create proc GetPriorityUsers
    @lid int
as
begin
    declare @users as table (
        uid int primary key,
        knowledge real,
        restraint real,
        trade real
    );

    insert into @users
        select UsersSdOnAvg.uid,
                UsersSdOnAvg.knowledge,
                UsersSdOnAvg.restraint,
                UsersSdOnAvg.trade
            from UsersSdOnAvg
                where exists (
                    select UsersSdOnAvg.uid
                        from UsersSdOnAvg
                            left join Distribution
                            on Distribution.uid = UsersSdOnAvg.uid
                            where Distribution.status = 0
                );

    if (
        select count(uid)
            from @users
    ) = 0 begin
        /* No one user has the active lead. I. e., the
         * Distribution table is next:
         *
         * +--------------------------------+
         * | id   | uid   | lead   | status |
         * |--------------------------------|
         * | 1    | 1     | 1      | 1      |
         * | 2    | 1     | 2      | 1      |
         * | 3    | 1     | 3      | 1      |
         * | 4    | 2     | 4      | 1      |
         * | 5    | 2     | 5      | 1      |
         * | 6    | 3     | 6      | 1      |
         * | 7    | 3     | 7      | 1      |
         * | ...  | ...   | ...    | ...    |
         * +--------------------------------+
         */

        insert into @users
            select Users.id, Skills.knowledge, Skills.restraint, Skills.trade
                from Users
                    join Skills
                    on Skills.id = Users.id;
    end;

    with UsersDeltas (uid, lid, dk, dr, dt) as (
        select [@users].uid,
                Requirements.lid,
                [@users].knowledge - Requirements.knowledge as dk,
                [@users].restraint - Requirements.restraint as dr,
                [@users].trade - Requirements.trade as dt
            from @users
                join Skills
                on Skills.id = [@users].uid
                cross join Requirements
    ), UsersTas (uid, lid, ta) as (
        select uid, lid, sum(cast(dk + dr + dt as decimal(8, 2))) as ta
            from UsersDeltas
                group by uid, lid
    )

    select UsersTas.lid, UsersTas.uid, UsersTas.ta
        from UsersTas
            where UsersTas.lid = @lid
            group by UsersTas.lid, UsersTas.uid, UsersTas.ta
            having UsersTas.ta = (
                select max(T.ta)
                    from UsersTas as T
                        where T.lid = @lid
            );
end;

go

/* Selects the user, which beneficial to distribute the @lid.
 *
 * It can select more than one user for the lead. If so, then
 * the user with less leads count is selected. If leads count
 * is the same, then the first received user is selected. */

create proc GetOptimalDistribution
    @lid int
as
begin
    declare @priority_users table (
        id int primary key identity,
        lid int,
        uid int,
        ta real
    );
    declare @pq int;

    insert into @priority_users
        exec GetPriorityUsers @lid;

    set @pq = (
        select count(1)
            from @priority_users
    );

    if @pq > 1 begin
        select top 1 [@priority_users].lid, [@priority_users].uid
            from @priority_users
                left join Distribution
                on Distribution.uid = [@priority_users].uid
                group by [@priority_users].lid, [@priority_users].uid, [@priority_users].ta
                order by count(Distribution.lid);
    end;
    else if @pq = 0 begin
        print('No one user can''t participate in distribution.');
    end;
    else begin
        select lid, uid
            from @priority_users;
    end;
end;
