[select to_char(sysdate, 'YYYYMMDDHH24MISS') report_timestamp,
        ol.prtnum sku,
        ol.shpqty quantity_shipped,
        to_char(ol.ordqty - ol.shpqty) outstanding_quantity,
        nvl(ol.sales_ordnum, o.ordnum) order_id,
        to_char(o.entdte, 'YYYYMMDD') order_time,
        NULL workable_status,
        o.wh_id warehouse_id,
        decode(supmst.supnum, '000', '', supmst.supnum) owner_code
   from ord o
   join ord_line ol
     on (ol.ordnum = o.ordnum and ol.wh_id = o.wh_id and ol.client_id = o.client_id) left
   join shipment_line sl
     on (sl.ordnum = ol.ordnum and sl.ordlin = ol.ordlin and sl.ordsln = ol.ordsln and sl.client_id = ol.client_id and sl.wh_id = ol.wh_id) left
   join shipment sh
     on (sh.ship_id = sl.ship_id)
   left outer
   join supmst
     on ol.supnum = supmst.supnum
   left outer
   join adrmst
     on supmst.adr_id = adrmst.adr_id
  where ol.cancelled_flg = 0
    and sl.linsts not in ('B', 'C')
    and sh.shpsts not in ('B', 'C')
  group by ol.prtnum,
        ol.shpqty,
        (ol.ordqty - ol.shpqty),
        nvl(ol.sales_ordnum, o.ordnum),
        to_char(o.entdte, 'YYYYMMDD'),
        supmst.supnum,
        adrmst.adrnam,
        o.wh_id]