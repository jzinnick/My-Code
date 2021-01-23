[select prtnum,
        trnqty
   from dlytrn
  where trndte between to_date('20140805115902')
    and to_date('20140829115902')
  group by trnqty,
        prtnum]