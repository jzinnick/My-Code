[select *
   from manfst
   where ship_id = 'SID5480155']
[select *
   from pckwrk_view
  where ctnnum in ('CTN5630372', 'CTN5630371')]
[select *
   from shipment
  where ship_id = 'SID5555786']
[update shipment
    set srvlvl = 'CASTD'
  where ship_id = 'SID5555786']
[select *
   from ord_line
  where ordnum = '327572464']
  [update manfst
  set mansts = 'M'
  where ship_id = 'SID5480155']