[select *
   from prtftp_dtl
  where prt_client_id = 'GRPN'
    and wh_id = 'WMD1'
    and uomcod = 'EA'
    and ftpcod = 'DEFAULT'
    and rownum < 120000]