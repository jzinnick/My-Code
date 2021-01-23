[select wrkref,
        ship_id,
        prtnum,
        prt_client_id,
        wh_id
   from pckwrk_view
  where pcksts = 'P'
    and exists(select 1
                 from rplwrk
                where ship_id = pckwrk_view.ship_id)
    and exists(select 1
                 from rplwrk
                where prtnum = pckwrk_view.prtnum
                  and prt_client_id = pckwrk_view.prt_client_id
                  and ship_id != pckwrk_view.ship_id)]
|
{
    cancel pick
     where cancod = 'CANCEL-NO-REALLOC'
}
|
{
    [select *
       from rplwrk
      where ship_id = @ship_id]
    |
    cancel replenishment
} catch(-1403)
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