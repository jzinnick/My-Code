[select x.*
   from (select distinct shipment.ship_id,
                shipment.dstare,
                shipment.dstloc,
                shipment.carcod,
                shipment.srvlvl,
                shipment.wh_id,
                shipment.entdte,
                shipment_line.pckgr1
           from shipment,
                shipment_line,
                ord_line,
                ord
          where shipment.ship_id = shipment_line.ship_id
            and shipment_line.ordnum = ord_line.ordnum
            and shipment_line.client_id = ord_line.client_id
            and shipment_line.wh_id = ord_line.wh_id
            and shipment_line.ordlin = ord_line.ordlin
            and shipment_line.ordsln = ord_line.ordsln
            and shipment_line.pckqty > 0
            and shipment.shpsts not in ('B', 'C')
            and shipment_line.linsts not in ('B', 'C')
            and shipment.loddte is null
            and shipment.stgdte is null
            and shipment.dstare is not null
            and shipment.srvlvl != 'FEXS' or shipment.srvlvl != 'FESO' or shipment.srvlvl != 'F2DY'
         /* 9/29/15 RNS: added uc_valid_addr check below per CR13014 if policy is enabled */
            and exists(select 1
                         from cardtl
                        where cartyp = 'S'
                          and carcod = shipment.carcod
                          and srvlvl = shipment.srvlvl)
            and not exists(select sum(pckqty)
                             from pckwrk_view
                            where ship_line_id = shipment_line.ship_line_id
                              and wrktyp = 'P'
                           having sum(pckqty) > ord_line.ordqty)
            and not exists(select 1
                             from rplwrk
                            where ship_line_id = shipment_line.ship_line_id)
            and exists(select count(1)
                         from shipment
                        where shpsts not in ('B', 'C')
                          and exists(select 1
                                       from pckwrk_view
                                      where ship_id = shipment.ship_id
                                     union
                                     select 1
                                       from rplwrk
                                      where ship_id = shipment.ship_id)
                          and loddte is null
                       having count(1) <= nvl(@max_inprocess_shipments, 100000))
            and ord.ordnum = ord_line.ordnum
            and ord.wh_id = ord_line.wh_id
            and ord.client_id = nvl(@client_ID, 'GRPN')
            and ord.client_id = ord_line.client_id
            and not exists(select distinct 'x'
                             from poldat_view pv
                            where pv.polcod = 'USR-PRINTING'
                              and pv.polvar = 'MULTI-PART-ORD'
                              and pv.polval = 'ORDTYP'
                              and pv.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
                              and pv.rtstr1 = ord.ordtyp
                              and pv.rtnum1 = 1)
            and @+shipment.wh_id
            and @+shipment.ship_id
            and @+shipment.carcod
            and @+shipment.srvlvl
            and @+ord.ordnum
          order by shipment.entdte) x
  where rownum <= nvl(@max_shipments_to_allocate, 1000)] catch(-1403)
|
if (@? = 0)
{
    try
    {
        set savepoint
         where savepoint = 'S_ALLOC_' || @ship_id
        |
        if (@pckgr1 is null)
        {
            generate next number
             where numcod = 'pckgrp'
            |
            assign pick group
             where ship_id = @ship_id
               and pckgr1 = @nxtnum
               and wh_id = @wh_id
            |
            publish data
             where pckgr1 = @nxtnum
        }
        |
        allocate wave
         where pricod = ''
           and only_apply_unassigned_shipments = '1'
           and rrlflg = 0
           and imr_uom_list = 'CS,EA,PA'
           and pcksts_uom = 'L,S,D'
           and consby = 'ship_id'
           and bulk_pck_flg = 0
           and only_use_existing_carriers = '0'
           and pcktyp = 'PICK-N-REPLEN-N-SHIP'
           and ship_id = @ship_id
           and dstare = @dstare
           and dstloc = @dstloc
           and carcod = @carcod
           and srvlvl = @srvlvl
           and wh_id = @wh_id
           and pckgr1 = @pckgr1
        |
        [commit]
    } catch(@?)
    {
        rollback to savepoint
         where savepoint = 'S_ALLOC_' || @ship_id
    }
}