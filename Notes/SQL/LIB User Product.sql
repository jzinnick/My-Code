[select /*dlytrn.usr_id,*/
        count(dlytrn.trnqty),
        sum(dlytrn.trnqty)
        /*dlytrn.devcod,
           dlytrn.prtnu*/
   from dlytrn
  where dlytrn.wh_id = 'WMD1'
    and (dlytrn.actcod = 'PCEPCK' or dlytrn.actcod = 'CASPCK')
    and (dlytrn.fr_arecod = 'LB01' or dlytrn.to_arecod = 'LB02')
    and dlytrn.trndte between to_date('201408160001')
    and to_date('201408162359')]