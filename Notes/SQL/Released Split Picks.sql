[select *
   from (select ctnnum,
                ship_id,
                max(prtnum) prtnum,
                sum(pckqty) pckqty,
                sum(appqty) appqty,
                count(*)
           from pckwrk_view
          where wrktyp = 'P'
            and pcksts = 'R'
          group by ctnnum,
                ship_id
         having count(*) > 1)
  where pckqty != appqty
  order by ctnnum asc]
|
{
    {
        [select *
           from pckwrk_view
          where ctnnum = @ctnnum
            and appqty != pckqty]
        |
        cancel pick
         where cancod = 'CANCEL-NO-REALLOC'
    }
    |
    {
        [select rplref,
                wh_id
           from rplwrk
          where prtnum = @prtnum
            and pckqty = 1
            and ship_id != @ship_id
            and rownum = 1]
        |
        allocate emergency replenishment
         where rplref = @rplref
           and wh_id = @wh_id
    } catch(@?)
    |
    commit
} catch(@?)