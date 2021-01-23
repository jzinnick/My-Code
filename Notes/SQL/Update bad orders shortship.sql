[select *
   from shipment_line
  where ordnum = '337830066']
[update shipment_line
    set shpqty = '3'
  where ordnum = '337700143']
[update shipment
    set shpsts = 'C'
  where ship_id = 'SID5681729']
[select *
   from pckwrk_hdr
  where wrkref = 'W0000701ZY']
[update pckwrk_hdr
    set pckqty = '3'
  where wrkref = 'W0000701ZY']
  [update pckwrk_hdr
    set appqty = '0'
  where wrkref = 'W00006YSYA']