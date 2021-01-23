[select invsum.prtnum,
        prtdsc.lngdsc,
        prtftp_view.untlen,
        prtftp_view.untwid,
        prtftp_view.unthgt,
        prtftp_view.netwgt,
        shipping_pckwrk_view.ctnnum
   from invsum,
        prtdsc,
        prtftp_view,
        shipping_pckwrk_view
  where invsum.prtnum = prtftp_view.prtnum
    and invsum.prtnum || '|GRPN|WMD1' = prtdsc.colval
    and shipping_pckwrk_view.prtnum = invsum.prtnum
  group by invsum.prtnum,
        prtdsc.lngdsc,
        prtftp_view.untlen,
        prtftp_view.untwid,
        prtftp_view.unthgt,
        prtftp_view.netwgt,
        shipping_pckwrk_view.ctnnum]