[select count(dlytrn.dlytrn_id)
        /*dlytrn.trnqty*/
   from dlytrn
  where dlytrn.wh_id = 'WMD1'
    and (dlytrn.actcod = 'PL_XFR' or dlytrn.actcod = 'PALPCK' or dlytrn.actcod = 'GENMOV' or dlytrn.actcod = 'FL_XFR')
    and dlytrn.trndte between to_date('201408010000')
    and to_date('201408302359')]