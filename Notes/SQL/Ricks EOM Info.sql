[select prtnum,
        sum(trnqty)
   from dlytrn
  where wh_id = 'WMD1'
    and tostol = 'FSTG01'
    and actcod <> 'SSTG'
    and trndte between to_date('20150101000000')
    and to_date('20150131235959')
    group by prtnum]