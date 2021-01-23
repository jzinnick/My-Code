[select count(ctncod),
        ctncod
   from shipping_pckwrk_view
  where shpsts = 'C'
    and wrktyp = 'K'
    and ctncod like 'P%'
    and prtdte between to_date('20170101000000')
    and to_date('20170131235959')
  group by ctncod]