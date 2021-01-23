[select *
   from pckwrk_hdr
  where ctnnum = 'CTN5311785']
[update pckwrk_hdr
    set ackdevcod = ''
  where ctnnum = 'CTN5336814']
[select *
   from manfst
  where shpdte like '20141229%'
    and carcod = 'U'
    and srvlvl = 'UPSR']
[update shipment
    set shpsts = 'C'
  where ship_id = 'SID5208598']
[select *
   from shipping_pckwrk_view
  where adddte like ('20141229%')
    and carcod = 'U'
    and srvlvl = 'UPSR'
    and wrktyp = 'P']
[select *
   from manfst
  where mansts = 'M']
[update manfst
    set mansts = 'C'
  where mansts = 'H']