[update ord_line
    set shpqty = '2'
  where ordnum = '216539321']
[update shipment_line
    set inpqty = '0'
  where ordnum = '216539321']
[update shipment_line
    set pckqty = '2'
  where ordnum = '216539321']
[update shipment_line
    set shpqty = '2'
  where ordnum = '216539321']
[update shipment_line
    set linsts = 'C'
  where ordnum = '216539321']
[update invlod
    set stoloc = 'FSTG01'
  where lodnum = 'L00017265341']
[update pckwrk_dtl
    set appqty = '0'
  where wrkref = 'W0000ISQQU']
[update pckwrk_dtl
    set cur_cas = '2'
  where wrkref = 'W0000ISQQF']
[update shipment
    set shpsts = 'C'
  where ship_id = 'SHD5350530']