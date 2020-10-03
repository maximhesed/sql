use Company;

go

create view UsersSdOnAvg
as
with LeadsCount (uid, lids) as (
    select Users.id, count(Distribution.lid) as lids
        from Users
            left join Distribution
            on Distribution.uid = Users.id
            group by Users.id
)

select Users.id as uid,
        Skills.knowledge,
        Skills.restraint,
        Skills.trade,
        dbo.GetSd(Skills.knowledge, Skills.restraint, Skills.trade) as sd
    from LeadsCount
        join Users
        on Users.id = LeadsCount.uid
        join Skills
        on Skills.id = LeadsCount.uid
        group by Users.id, Skills.knowledge, Skills.restraint, Skills.trade
        having dbo.GetSd(Skills.knowledge, Skills.restraint, Skills.trade) <= (
            select sum(cast(lids as real)) / count(cast(lids as real)) as avg
                from LeadsCount
        ) / 10;
