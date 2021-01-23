[select count(distinct prtnum),
        count(ordnum)
   from manfst
  where mstdte between to_date('20140629')
    and to_date('20140705')]