[select ord_line.ordnum,
        shipment.ship_id,
        shipment.adddte,
        shipment.entdte,
        shipment.shpsts,
        ord_line.prtnum,
        ord_line.prt_client_id,
        prtdsc.lngdsc,
        ord_line.ordqty
   from ord_line,
        shipment_line,
        shipment,
        prtmst_view,
        prtdsc
  where shipment.ship_id = shipment_line.ship_id
    and shipment_line.ordnum = ord_line.ordnum
    and shipment_line.ordlin = ord_line.ordlin
    and shipment_line.ordsln = ord_line.ordsln
    and shipment_line.client_id = ord_line.client_id
    and shipment_line.wh_id = ord_line.wh_id
    and ord_line.prtnum = prtmst_view.prtnum
    and ord_line.prt_client_id = prtmst_view.prt_client_id
    and ord_line.wh_id = prtmst_view.wh_id
    and 'prtnum|prt_client_id|wh_id_tmpl' = prtdsc.colnam(+)
    and prtmst_view.prtnum || '|' || prtmst_view.prt_client_id || '|' || prtmst_view.wh_id_tmpl = prtdsc.colval(+)
    and 'US_ENGLISH' = prtdsc.locale_id(+)
    and shipment.shpsts != 'B'
    and shipment_line.linsts != 'B'
    and ord_line.ordqty > 0
    and shipment.loddte is null
    and shipment.stgdte is null
    and @+prmtst_view.prtnum
    and @+prtmst_view.prt_client_id
    and @+ord_line.wh_id
    and @+ord_line.ordnum
    and @+ord_line.client_id
    and @+shipment.ship_id
    and @+shipment_line.ship_line_id
    and rownum < 120000
  order by shipment.adddte,
        ord_line.ordnum]