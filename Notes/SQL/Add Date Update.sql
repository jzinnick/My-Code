[select x.prtnum,
        prtdsc.lngdsc prtdsc,
        x.adddte,
        x.order_count,
        x.ordqty,
        sum(invsum.untqty) untqty,
        sum(invsum.rstg_qty) rstg_qty,
        sum(pckwrk_view.pckqty) pckqty,
        rcv.supnum,
        rcv.invnum,
        rcv.invtyp,
        rcv.invdte,
        rcv.carcod rcv_carcod,
        prtftp_view.untlen || ' x ' || prtftp_view.untwid || ' x ' || prtftp_view.unthgt dims,
        invloc.stoloc
   from (select ord_line.prtnum,
                ord_line.prt_client_id,
                ord_line.wh_id,
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
          group by ord_line.prtnum,
                ord_line.prt_client_id,
                ord_line.wh_id) x,
        (select invdtl.prtnum,
                invdtl.prt_client_id,
                sum(invdtl.untqty) untqty,
                sum(decode(aremst.arecod, 'RSTG', invdtl.untqty, 0)) rstg_qty
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
            and invdtl.invsts = 'A'
          group by invdtl.prtnum,
                invdtl.prt_client_id) invsum,
        (select prtnum,
                prt_client_id,
                sum(pckqty - appqty) pckqty
           from pckwrk_view
          where wrktyp = 'P'
            and appqty != pckqty
          group by prtnum,
                prt_client_id) pckwrk_view,
        (select rimlin.prtnum,
                rimlin.prt_client_id,
                decode(count(distinct rimhdr.supnum), 1, max(rimhdr.supnum), 'MIXED') supnum,
                decode(count(distinct rimhdr.invnum), 1, max(rimhdr.invnum), 'MIXED') invnum,
                decode(count(distinct rimhdr.invtyp), 1, max(rimhdr.invtyp), 'MIXED') invtyp,
                decode(count(distinct rimhdr.orgref), 0, '', 1, max(rimhdr.orgref), 'MIXED') carcod,
                min(rimhdr.invdte) invdte
           from rimhdr,
                rimlin
          where rimhdr.rimsts = 'OPEN'
            and rimhdr.invnum = rimlin.invnum
            and rimhdr.client_id = rimlin.client_id
            and rimhdr.wh_id = rimlin.wh_id
            and rimlin.expqty > rimlin.idnqty
          group by rimlin.prtnum,
                rimlin.prt_client_id) rcv,
        prtmst_view,
        prtdsc,
        prtftp_view,
        invloc
  where x.prtnum = invsum.prtnum(+)
    and x.prt_client_id = invsum.prt_client_id(+)
    and x.prtnum = pckwrk_view.prtnum(+)
    and x.prt_client_id = rcv.prt_client_id(+)
    and x.prtnum = rcv.prtnum(+)
    and x.prt_client_id = pckwrk_view.prt_client_id(+)
    and x.prtnum = prtmst_view.prtnum
    and x.prt_client_id = prtmst_view.prt_client_id
    and 'prtnum|prt_client_id|wh_id_tmpl' = prtdsc.colnam(+)
    and prtmst_view.prtnum || '|' || prtmst_view.prt_client_id || '|' || prtmst_view.wh_id_tmpl = prtdsc.colval(+)
    and 'US_ENGLISH' = prtdsc.locale_id(+)
    and x.prtnum = prtftp_view.prtnum(+)
    and x.prt_client_id = prtftp_view.prt_client_id(+)
    and x.wh_id = prtftp_view.wh_id(+)
    and 1 = prtftp_view.defftp_flg(+)
    and invloc.prtnum = x.prtnum
  group by x.prtnum,
        prtdsc.lngdsc,
        x.adddte,
        x.order_count,
        x.ordqty,
        rcv.supnum,
        rcv.invnum,
        rcv.invtyp,
        rcv.invdte,
        rcv.carcod,
        prtftp_view.untlen || ' x ' || prtftp_view.untwid || ' x ' || prtftp_view.unthgt,
        invloc.stoloc]