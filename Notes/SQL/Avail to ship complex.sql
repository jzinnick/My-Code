[select x.*,
        nvl(invsum.avail_qty, 0) pickable_qty,
        fwi.rstg_qty,
        fwi.untqty - nvl(invsum.avail_qty, 0) - fwi.rstg_qty not_pickable_qty,
        fwi.untqty four_wall_inv_qty,
        decode(sign(x.ordered_qty - nvl(invsum.avail_qty, 0) - fwi.rstg_qty), 1, nvl(invsum.avail_qty, 0) + fwi.rstg_qty, 0, 0, null, 0, x.ordered_qty) we_can_ship_qty,
        pck.pckqty open_pick_qty,
        rpl.pckqty rpl_pick_qty,
        fwi.picked_qty already_picked_inv_qty,
        order_age.entdte oldest_due_date
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
          where exists(select 1
                         from alloc_search_hdr
                        where arecod = invsum.arecod
                          and wh_id = invsum.wh_id)
          group by prtnum,
                prt_client_id) invsum,
        (select prtnum,
                prt_client_id,
                wh_id,
                sum(pckqty) pckqty
           from pckwrk_view
          where wrktyp = 'P'
            and appqty != pckqty
            and exists(select 1
                         from shipment
                        where ship_id = pckwrk_view.ship_id
                          and loddte is null
                          and stgdte is null
                          and shpsts != 'B')
          group by prtnum,
                prt_client_id,
                wh_id) pck,
        (select prtnum,
                prt_client_id,
                wh_id,
                sum(pckqty) pckqty
           from pckwrk_view
          where wrktyp = 'E'
          group by prtnum,
                prt_client_id,
                wh_id) rpl,
        (select invdtl.prtnum,
                invdtl.prt_client_id,
                invlod.wh_id,
                sum(invdtl.untqty) untqty,
                sum(decode(aremst.arecod, 'RSTG', invdtl.untqty, 0)) rstg_qty,
                sum(decode(invdtl.ship_line_id, null, 0, invdtl.untqty)) picked_qty
           from aremst,
                locmst,
                invlod,
                invsub,
                invdtl
          where aremst.arecod = locmst.arecod
            and aremst.wh_id = locmst.wh_id
            and locmst.stoloc = invlod.stoloc
            and locmst.wh_id = invlod.wh_id
            and invlod.lodnum = invsub.lodnum
            and invsub.subnum = invdtl.subnum
            and aremst.fwiflg = 1
          group by invdtl.prtnum,
                invdtl.prt_client_id,
                invlod.wh_id) fwi,
        (select ord_line.prtnum,
                ord_line.prt_client_id,
                min(shipment.entdte) entdte
           from shipment,
                shipment_line,
                ord_line
          where shipment.ship_id = shipment_line.ship_id
            and shipment_line.ordnum = ord_line.ordnum
            and shipment_line.ordlin = ord_line.ordlin
            and shipment_line.ordsln = ord_line.ordsln
            and shipment_line.client_id = ord_line.client_id
            and shipment_line.wh_id = ord_line.wh_id
            and shipment.loddte is null
            and shipment.stgdte is null
            and shipment.shpsts != 'B'
          group by ord_line.prtnum,
                ord_line.prt_client_id) order_age
  where x.prtnum = invsum.prtnum(+)
    and x.prt_client_id = invsum.prt_client_id(+)
    and x.prtnum = pck.prtnum(+)
    and x.prt_client_id = pck.prt_client_id(+)
    and x.prtnum = rpl.prtnum(+)
    and x.prt_client_id = rpl.prt_client_id(+)
    and x.prtnum = order_age.prtnum(+)
    and x.prt_client_id = order_age.prt_client_id(+)
    and x.prtnum = fwi.prtnum
    and x.prt_client_id = fwi.prt_client_id]