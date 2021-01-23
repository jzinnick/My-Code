[select manfst.ordnum,
        manfst.ship_id,
        manfst.prtnum,
        manfst.carcod,
        manfst.srvlvl,
        manfst.traknm,
        manfst.weight,
        prtftp_view.untlen,
        prtftp_view.untwid,
        prtftp_view.unthgt,
        prtftp_view.netwgt,
        pckwrk_view.ctncod,
        ctnmst.ctnlen,
        ctnmst.ctnwid,
        ctnmst.ctnhgt
   from manfst,
        prtftp_view,
        pckwrk_view,
        ctnmst
  where mstdte between to_date('20141101000000')
    and to_date('20141130235900')
    and manfst.prtnum = prtftp_view.prtnum
    and manfst.ordnum = pckwrk_view.ordnum
    and pckwrk_view.wrktyp = 'K'
    and ctnmst.ctncod = pckwrk_view.ctncod
    and rownum < 120000]