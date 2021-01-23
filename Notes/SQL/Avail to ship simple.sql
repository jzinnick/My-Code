[select *
        /* sum(ship_qty) */
   from (select x.*,
                i.avail_qty,
                decode(sign(x.ordered_qty - i.avail_qty), 1, i.avail_qty, x.ordered_qty) ship_qty
           from (select ord_line.prtnum,
                        ord_line.prt_client_id,
                        count(distinct ord_line.ordnum) order_count,
                        sum(ord_line.ordqty) ordered_qty
                   from ord_line,
                        shipment_line,
                        shipment
                  where shipment.ship_id = shipment_line.ship_id
                    and shipment_line.ordnum = ord_line.ordnum
                    and shipment_line.ordlin = ord_line.ordlin
                    and shipment_line.ordsln = ord_line.ordsln
                    and shipment_line.client_id = ord_line.client_id
                    and shipment_line.wh_id = ord_line.wh_id
                    and shipment.shpsts != 'B'
                    and shipment_line.linsts != 'B'
                    and ord_line.ordqty > 0
                    and shipment.loddte is null
                    and shipment.stgdte is null
                  group by ord_line.prtnum,
                        ord_line.prt_client_id) x,
                (select prtnum,
                        prt_client_id,
                        sum(untqty) avail_qty
                   from invsum
                  group by prtnum,
                        prt_client_id) i
          where x.prtnum = i.prtnum
            and x.prt_client_id = i.prt_client_id) y]