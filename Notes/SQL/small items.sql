[select prtftp_view.prtnum,
        prtftp_view.untlen,
        prtftp_view.untwid,
        prtftp_view.unthgt,
        prtftp_view.grswgt,
        prtmst.untcst,
        inventory_view.stoloc
   from prtftp_view,
        prtmst,
        inventory_view
  where (prtftp_view.prtnum = prtmst.prtnum)
    and (prtmst.untcst > '10.00' and prtmst.untcst < '89.99')
    and (prtftp_view.untlen <= '2' and prtftp_view.untwid <= '2' and prtftp_view.untwid <= '2')
    and inventory_view.prtnum = prtmst.prtnum]