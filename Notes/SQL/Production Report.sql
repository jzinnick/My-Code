[select *
   from dlytrn
  where trndte between to_date('20161214000000')
    and to_date('20161214235959')
    and wh_id = 'WMD1'
    and (oprcod = 'UPK' or oprcod = 'URC' or oprcod = 'UTR')
  order by trndte desc]