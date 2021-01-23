[select tostol,
        count(actcod),
        sum(trnqty)
   from dlytrn
  where actcod = 'IDNTFY'
    and trndte between to_date('20140801')
    and to_date('20140827')
  group by tostol]