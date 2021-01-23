[select count(lodnum),
        sum(trnqty)
   from dlytrn
  where wh_id = 'WMD1'
    and tostol = 'FSTG01'
    and actcod <> 'SSTG'
    and trndte between to_date('20141203060000')
    and to_date('20141203160000')]