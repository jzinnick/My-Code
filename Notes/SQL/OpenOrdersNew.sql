[select ord_line.prtnum,
        decode(count(distinct ord.ordnum), 1, to_char(max(ord.adddte), 'YYYY-MM-DD HH24:MI:SS'), 'MULTIPLE') adddte,
        count(distinct ord.ordnum) order_count,
        sum(ord_line.ordqty) ordqty
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
    and shipment.loddte is null
  group by ord_line.prtnum]