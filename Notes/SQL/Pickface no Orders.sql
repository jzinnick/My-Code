[select arecod,
        stoloc,
        prtnum,
        untqty,
        comqty,
        pndqty
   from invsum
  where arecod like 'E%'
    and comqty < untqty
    and not exists(select 1
                     from rplwrk
                    where prtnum = invsum.prtnum
                      and prt_client_id = invsum.prt_client_id
                      and wh_id = invsum.wh_id)
  order by arecod,
        stoloc]