[select count(prtnum),
        prtnum
   from manfst
  where mstdte between to_date('20141201')
    and to_date('20141231')
  group by prtnum]