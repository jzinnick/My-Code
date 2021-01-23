[select ord.ordnum,
        ord_line.prtnum,
        ord.adddte,
        ord.cpodte,
        ord_line.ordqty
   from ord,
        ord_line,
        shipment_line,
        shipment
  where ord.ordnum = ord_line.ordnum
    and ord.wh_id = ord_line.wh_id
    and ord.client_id = ord_line.client_id
    and ord_line.ordnum = shipment_line.ordnum
    and ord_line.client_id = shipment_line.client_id
    and ord_line.wh_id = shipment_line.wh_id
    and ord_line.ordlin = shipment_line.ordlin
    and ord_line.ordsln = shipment_line.ordsln
    and shipment_line.ship_id = shipment.ship_id
    and shipment.shpsts != 'B'
    and shipment.loddte is null]