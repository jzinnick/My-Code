[select dlytrn.usr_id,
        count(dlytrn.trnqty)
   from dlytrn
  where dlytrn.wh_id = 'WMD1'
    and (dlytrn.actcod = 'PCEPCK' or dlytrn.actcod = 'CASPCK')
    and dlytrn.to_arecod = 'RDTS'
    and dlytrn.trndte between to_date('201501010500')
    and to_date('201501151500')
  group by dlytrn.usr_id]