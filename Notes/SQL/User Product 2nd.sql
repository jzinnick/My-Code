[select dlytrn.usr_id,
        dlytrn.trnqty,
        dlytrn.devcod,
        dlytrn.prtnum,
        prtftp_view.pallen,
        prtftp_view.palwid,
        prtftp_view.palhgt,
        prtftp_view.grswgt
   from dlytrn,
        prtftp_view
  where dlytrn.prtnum = prtftp_view.prtnum
    and dlytrn.wh_id = 'WMD1'
    and (dlytrn.actcod = 'PCEPCK' or dlytrn.actcod = 'CASPCK')
    and dlytrn.to_arecod = 'RDTS'
    and dlytrn.trndte between to_date('201408101600')
    and to_date('201408110100')]