if (@rpt_id = 0)
{
    /* RMA Work-In-Returns (WIR) Billing Report */
    execute usr sql
     where sqlcmd =
    [
     [select trunc(rcvdte) rcvdte,
             prt_client_id,
             rmatyp,
             count(1) count
        from usr_wir
       where (rcvdte between @flddte:raw)
         and rmatyp is not null
       group by trunc(rcvdte),
             prt_client_id,
             rmatyp]]
}
else if (@rpt_id = 1)
{
    /* RTS Warranty Exchange Shipping */
    execute usr sql
     where sqlcmd =
    [
     [select o.vc_reacod,
             o.vc_sranum,
             dh.make,
             trunc(s.loddte) shpdte,
             sl.ordnum,
             ol.prtnum,
             ol.prt_client_id,
             dh.model,
             sl.shpqty
        from usr_dvlhdr dh,
             ord_line ol,
             ord o,
             shipment_line sl,
             shipment s
       where dh.prtnum = ol.prtnum
         and dh.prt_client_id = ol.prt_client_id
         and ol.client_id = sl.client_id
         and ol.ordnum = sl.ordnum
         and ol.ordlin = sl.ordlin
         and ol.ordsln = sl.ordsln
         and o.wh_id = ol.wh_id
         and o.client_id = sl.client_id
         and o.ordnum = sl.ordnum
         and o.ordtyp = 'V'
         and sl.ship_id = s.ship_id
         and (s.loddte between @flddte:raw)
         and @+vc_reacod
         and @+dh.make
         and @+o.wh_id
       order by o.vc_reacod,
             dh.make,
             sl.ordnum]]
}
else if (@rpt_id = 2)
{
    /* WE and DF Interface Today */
    publish data
     where frstol_cre = nvl(@frstol_cre, 'PERM-CRE-LOC')
       and movref = nvl(@movref, "('RMA-WORK', 'RMA-UNDLIV','RMA-AGNT')")
       and frstol_adj = nvl(@frstol_adj, 'PERM-ADJ-LOC')
    |
    execute usr sql
     where sqlcmd =
    [
     [select tmp.trndte,
             tmp.hour,
             nvl(dm.lngdsc, nvl(dm.short_dsc, rh.uc_ordtyp)) ordtyp,
             tmp.prt_client_id,
             sum(tmp.trnqty) count
        from dscmst dm,
             rimhdr rh,
             (select d.tostol,
                     trunc(d.trndte) trndte,
                     to_char(d.trndte, 'HH24') hour,
                     d.prt_client_id,
                     d.wh_id,
                     sum(d.trnqty) trnqty
                from dlytrn d
               where @+d.wh_id
                 and d.frstol || '' = @frstol_cre
                 and (d.trndte between @flddte:raw)
               group by trunc(d.trndte),
                     to_char(d.trndte, 'HH24'),
                     d.prt_client_id,
                     d.tostol,
                     d.wh_id) tmp
       where dm.colnam(+) = 'ordtyp'
         and dm.colval(+) = rh.uc_ordtyp
         and dm.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
         and rh.invnum = tmp.tostol
         and rh.wh_id = tmp.wh_id
         and rh.invtyp = 'R'
       group by tmp.trndte,
             tmp.hour,
             rh.uc_ordtyp,
             tmp.prt_client_id,
             dm.short_dsc,
             dm.lngdsc
      union
      select tmp.trndte,
             tmp.hour,
             nvl(dm.lngdsc, nvl(dm.short_dsc, tmp.ordtyp)) ordtyp,
             tmp.prt_client_id,
             sum(tmp.trnqty) count
        from dscmst dm,
             (select trunc(d.trndte) trndte,
                     to_char(d.trndte, 'HH24') hour,
                     decode(d.movref, 'RMA-AGNT', 'Agent Return', d.oprcod) ordtyp,
                     d.prt_client_id,
                     sum(d.trnqty) trnqty
                from dlytrn d
               where @+d.wh_id
                 and d.movref in @movref:raw
                 and d.frstol || '' = @frstol_adj
                 and (d.trndte between @flddte:raw)
               group by trunc(d.trndte),
                     to_char(d.trndte, 'HH24'),
                     decode(d.movref, 'RMA-AGNT', 'Agent Return', d.oprcod),
                     d.prt_client_id) tmp
       where dm.colnam(+) = 'rmatyp'
         and dm.colval(+) = tmp.ordtyp
         and dm.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
       group by tmp.trndte,
             tmp.hour,
             tmp.ordtyp,
             tmp.prt_client_id,
             dm.short_dsc,
             dm.lngdsc]]
}
else if (@rpt_id = 3)
{
    /* RMA Returns Productivity */
    publish data
     where movref = nvl(@movref, "('RMA-WORK', 'RMA-UNDLIV', 'RMA-AGNT')")
       and frstol_adj = nvl(@frstol_adj, 'PERM-ADJ-LOC')
       and movref_err = nvl(@movref_err, 'RETURN-ERR-LABEL')
    |
    execute usr sql
     where sqlcmd =
    [
     [select trndte,
             usr_id,
             type,
             rmatyp,
             prt_client_id,
             prtfam,
             uc_make,
             lodlvl,
             sum(count) count
        from (select /*+ index(pm prtmst_pk) index(ura usr_rmaact_rcvdte) */
                     trunc(ura.rcvdte) trndte,
                     ura.mod_usr_id usr_id,
                     'Receipt' type,
                     ura.rmatyp,
                     ura.prt_client_id,
                     decode(pm.lodlvl, 'D', 'Serialized', 'L', 'NonSerialized', 'unknown') lodlvl,
                     pm.prtfam,
                     pm.uc_make,
                     sum(ura.rcvqty) count
                from prtmst_view pm,
                     usr_rmaact ura
               where pm.prtnum = ura.rcvprt
                 and pm.prt_client_id = ura.prt_client_id
                 and pm.wh_id = nvl(@wh_id, '----')
                 and ura.rcvqty != 0
                 and ura.rcvdte between @flddte:raw
                 and @+ura.prt_client_id
               group by trunc(ura.rcvdte),
                     ura.prt_client_id,
                     ura.mod_usr_id,
                     ura.rmatyp,
                     pm.prtfam,
                     pm.uc_make,
                     pm.lodlvl
              union all
              select /*+ index(pm prtmst_pk) index(urs usr_rma_shipment_shpdte_idx) */
                     trunc(urs.adddte) trndte,
                     urs.ins_usr_id usr_id,
                     'Reship' || decode(urs.rma_shptyp, 'S', ' Special', '') type,
                     urs.rmatyp,
                     urs.prt_client_id,
                     decode(pm.lodlvl, 'D', 'Serialized', 'L', 'NonSerialized', 'unknown') lodlvl,
                     pm.prtfam,
                     pm.uc_make,
                     sum(urs.shpqty) count
                from prtmst_view pm,
                     usr_rma_shipment urs
               where pm.prtnum = urs.prtnum
                 and pm.prt_client_id = urs.prt_client_id
                 and pm.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
                 and urs.rma_shptyp in ('R', 'S')
                 and urs.shpdte between @flddte:raw
                 and @+urs.prt_client_id
               group by trunc(urs.adddte),
                     urs.prt_client_id,
                     urs.ins_usr_id,
                     urs.rmatyp,
                     decode(urs.rma_shptyp, 'S', ' Special', ''),
                     pm.prtfam,
                     pm.uc_make,
                     pm.lodlvl
              union all
              select /*+ index(pm prtmst_pk) index(ura usr_rmaact_rcvdte) */
                     trunc(ura.rcvdte) trndte,
                     ura.mod_usr_id usr_id,
                     'Receipt' type,
                     ura.rmatyp rmatyp,
                     ura.prt_client_id,
                     'NonSerialized' lodlvl,
                     pm.prtfam,
                     pm.uc_make,
                     sum(ura.manacc_cnt) count
                from prtmst_view pm,
                     usr_rmaact ura
               where pm.prtnum = ura.rcvprt
                 and pm.prt_client_id = ura.prt_client_id
                 and pm.wh_id = nvl(@wh_id, '----')
                 and pm.lodlvl = 'D'
                 and ura.manacc_cnt > 0
                 and ura.rcvdte between @flddte:raw
                 and @+ura.prt_client_id
               group by trunc(ura.rcvdte),
                     ura.prt_client_id,
                     ura.mod_usr_id,
                     ura.rmatyp,
                     pm.prtfam,
                     pm.uc_make,
                     pm.lodlvl)
       group by trndte,
             usr_id,
             type,
             rmatyp,
             prt_client_id,
             prtfam,
             uc_make,
             lodlvl
      union
      select trunc(tmp.trndte) trndte,
             tmp.usr_id,
             'Receipt (WIR)' type,
             nvl(dm.lngdsc, nvl(dm.short_dsc, tmp.rmatyp)) rmatyp,
             tmp.prt_client_id,
             decode(p.lodlvl, 'D', 'Serial', 'Non-Serial') lodlvl,
             p.prtfam,
             p.uc_make,
             sum(tmp.trnqty) count
        from dscmst dm,
             prtmst_view p,
             (select d.usr_id,
                     decode(d.movref, 'RMA-AGNT', 'Agent Return', d.oprcod) rmatyp,
                     d.prtnum,
                     d.prt_client_id,
                     trunc(d.trndte) trndte,
                     d.wh_id,
                     sum(d.trnqty) trnqty
                from dlytrn d
               where @+d.wh_id
                 and d.movref in @movref:raw
                 and d.frstol || '' = @frstol_adj
                 and (d.trndte between @flddte:raw)
               group by trunc(d.trndte),
                     to_char(d.trndte, 'HH24'),
                     d.usr_id,
                     decode(d.movref, 'RMA-AGNT', 'Agent Return', d.oprcod),
                     d.prtnum,
                     d.prt_client_id,
                     d.wh_id) tmp
       where dm.colnam(+) = 'rmatyp'
         and dm.colval(+) = tmp.rmatyp
         and dm.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
         and p.prtnum = tmp.prtnum
         and p.prt_client_id = tmp.prt_client_id
         and p.wh_id = tmp.wh_id
         and @+p.prt_client_id
       group by trunc(tmp.trndte),
             tmp.usr_id,
             tmp.prt_client_id,
             p.lodlvl,
             p.prtfam,
             p.uc_make,
             tmp.rmatyp,
             dm.short_dsc,
             dm.lngdsc
      union
      select trunc(tmp.trndte) trndte,
             tmp.usr_id,
             'Exception (Error)' type,
             '' rmatyp,
             tmp.prt_client_id,
             decode(p.lodlvl, 'D', 'Serial', '', 'No Part', 'Non-Serial') lodlvl,
             p.prtfam,
             p.uc_make,
             sum(tmp.trnqty) count
        from prtmst_view p,
             (select d.usr_id,
                     d.prtnum,
                     d.prt_client_id,
                     trunc(d.trndte) trndte,
                     d.wh_id,
                     count(d.trndte) trnqty
                from dlytrn d
               where @+d.wh_id
                 and d.movref = @movref_err
                 and (d.trndte between @flddte:raw)
               group by trunc(d.trndte),
                     to_char(d.trndte, 'HH24'),
                     d.usr_id,
                     d.prtnum,
                     d.prt_client_id,
                     d.wh_id) tmp
       where p.prtnum(+) = tmp.prtnum
         and p.prt_client_id(+) = tmp.prt_client_id
         and p.wh_id(+) = tmp.wh_id
         and @+p.prt_client_id
       group by trunc(tmp.trndte),
             tmp.usr_id,
             tmp.prt_client_id,
             p.prtfam,
             p.uc_make,
             p.lodlvl
       order by trndte,
             usr_id,
             type,
             rmatyp,
             lodlvl]]
}
else if (@rpt_id = 4)
{
    [select 'dt.prtnum like ' || '''' || rtstr1 || '''' include_prtnum
       from usr_poldat_view
      where polcod = 'USR-REPORTS'
        and polvar = 'REBOX-ACTIVITY'
        and polval = 'EXCLUDE-NEW-PARTS'
        and rtnum1 = 1
        and wh_id = nvl(@wh_id, '----')
        and uc_client_id = nvl(@prt_client_id, '----')] catch(-1403)
    |
    if (@include_prtnum = '')
    {
        publish data
         where include_prtnum = '1=1'
    }
    |
    if (int(@show_duplicates) = 0)
    {
        /* Rebox Devalue Activity
           -  added part description */
        execute usr sql
         where sqlcmd =
        [list usr prod with arch
          where cmd =
         [
          [select to_char(tmp.trndte, 'MM/DD/YYYY') trndte,
                  substr(tmp.movref, 1, instr(tmp.movref, '-ESN') - 1) type,
                  tmp.to_arecod arecod,
                  dh.make,
                  dh.model,
                  dh.devcol,
                  dh.devsiz,
                  dh.uc_alca_pkgtyp,
                  tmp.prtnum,
                  tmp.prtdsc,
                  tmp.prt_client_id,
                  tmp.org_prtnum,
                  tmp.frinvs,
                  tmp.qty
             from usr_dvlhdr dh,
                  (select trunc(dt.trndte) trndte,
                          dt.movref,
                          dt.prtnum,
                          pd.lngdsc prtdsc,
                          dt.prt_client_id,
                          dt.to_arecod,
                          dt.fr_age_pflnam org_prtnum,
                          dt.frinvs,
                          sum(dt.trnqty) qty
                     from dlytrn dt,
                          prtdsc pd
                    where pd.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
                      and pd.colval(+) = dt.prtnum || '|' || dt.prt_client_id || '|' || nvl(dt.wh_id, '----')
                      and pd.colnam(+) = 'prtnum|prt_client_id|wh_id_tmpl'
                      and dt.movref || '' like nvl(@movref_esn, '%-ESN')
                      and dt.frstol || '' = nvl(@frstol_adj, 'PERM-ADJ-LOC')
                      and dt.trndte between @flddte:raw
                      and @+dt.movref
                      and @+dt.wh_id
                      and @+dt.prt_client_id
                      and @+dt.prtnum
                      and @+dt.to_arecod^arecod
                      and @include_prtnum:raw
                    group by trunc(dt.trndte),
                          dt.movref,
                          dt.prtnum,
                          pd.lngdsc,
                          dt.prt_client_id,
                          dt.to_arecod,
                          dt.fr_age_pflnam,
                          dt.frinvs) tmp
            where dh.prt_client_id = tmp.prt_client_id
              and dh.prtnum = tmp.prtnum
              and @+dh.make
              and @+dh.model]]]
    }
    else
    {
        /* List All duplicates based on Piece Identifier */
        execute usr sql
         where sqlcmd =
        [list usr prod with arch
          where cmd =
         [
          [select dtlnum
             from dlytrn
            where movref || '' like nvl(@movref_esn, '%-ESN')
              and frstol || '' = nvl(@frstol_adj, 'PERM-ADJ-LOC')
              and trndte between @flddte:raw
              and @+movref
              and @+wh_id
              and @+prt_client_id
              and @+prtnum
            group by dtlnum
           having count(dtlnum) > 1]]
         |
         [select dt.trndte,
                 dt.dtlnum,
                 dt.prtnum,
                 pd.lngdsc prtdsc,
                 dt.prt_client_id,
                 dt.movref,
                 dt.reacod,
                 dt.trnqty,
                 dt.to_arecod arecod,
                 dt.frstol,
                 dt.frinvs,
                 dt.fr_age_pflnam,
                 dt.tostol,
                 dt.toinvs,
                 dt.usr_id,
                 dt.devcod
            from dlytrn dt,
                 prtdsc pd
           where pd.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
             and pd.colval(+) = dt.prtnum || '|' || dt.prt_client_id || '|' || nvl(dt.wh_id, '----')
             and pd.colnam(+) = 'prtnum|prt_client_id|wh_id_tmpl'
             and dt.dtlnum = @dtlnum
             and dt.movref || '' like nvl(@movref_esn, '%-ESN')
             and dt.frstol || '' = nvl(@frstol_adj, 'PERM-ADJ-LOC')
             and dt.trndte between @flddte:raw]] catch(510)
    }
}
else if (@rpt_id = 5)
{
    /* Test and Repair Billing Report */
    publish data
     where fld1 = decode(nvl(@show_detail, 0), '0', '', 'urh.dtlnum,urh.prtnum,dh.make,dh.model,urh.trbcod,urh.trbfnd,urh.rmanum,urh.uc_repsts,')
    |
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select to_char(trunc(urh.repdte), 'MM/DD/RRRR') repdte,
              @fld1:raw urh.uc_repprv,
              urh.prt_client_id,
              dh.uc_billing_group,
              urh.reboxflg,
              dh.lte_dvce,
              dh.embed_bat,
              decode(p.rtnum1, 1, decode(nvl(urh.cosrep, 0), '0', 'Pass (w/o part)', 'Pass (w/ part)'), 2, 'Fail', 3, 'RUR', 'Other') status,
              count(1) cnt,
              sum(decode(nvl(urh.rftest, nvl(functst, 0)), '0', 0, 1)) rf_func_test,
              sum(decode(nvl(urh.rftest, 0), '0', 0, 1)) rf_test,
              sum(decode(nvl(urh.flshrst, 0), '0', 0, 1)) flash,
              sum(decode(nvl(urh.polbuf, 0), '0', 0, 1)) polish,
              sum(decode(nvl(urh.cosrep, 0), '0', 0, 1)) cosmetic,
              sum(decode(nvl(p.rtnum1, 0), '3', 1, 0)) returned_unrepairable,
              nvl(sum((select sum(urd.prtcst*urd.used)
                         from usr_repdtl urd
                        where urd.dtlnum = urh.dtlnum
                          and urd.fifdte = urh.fifdte
                          and urd.uc_repprv = urh.uc_repprv
                          and urd.used != 0)), 0) test_part_cost
         from usr_poldat_view p,
              usr_dvlhdr dh,
              usr_rephdr urh
        where p.polcod = 'USR-TEST-REPAIR'
          and p.polvar = urh.uc_repprv
          and p.polval = 'FINAL-REPSTS'
          and p.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
          and p.uc_client_id = urh.prt_client_id
          and p.rtstr1 = urh.uc_repsts
          and dh.prtnum = urh.prtnum
          and dh.prt_client_id = urh.prt_client_id
          and (urh.repdte between @flddte:raw)
          and @+urh.uc_repprv
          and @+urh.prt_client_id
          and @+dh.uc_billing_group
          and @+urh.reboxflg
        group by trunc(urh.repdte),
              urh.uc_repprv,
              dh.uc_billing_group,
              urh.prt_client_id,
              urh.reboxflg,
              dh.lte_dvce,
              dh.embed_bat,
              @fld1:raw decode(p.rtnum1, 1, decode(nvl(urh.cosrep, 0), '0', 'Pass (w/o part)', 'Pass (w/ part)'), 2, 'Fail', 3, 'RUR', 'Other')]]]
    |
    if (@show_detail = 1)
    {
        [select (select sales_channel
                   from usr_rmahdr
                  where rmanum = @rmanum
                    and client_id = @prt_client_id
                    and rownum < 2) sales_channel
           from dual]
        |
        filter data
         where moca_filter_level = 3
           and sales_channel = @sales_channel
    }
    else
    {
        filter data
         where moca_filter_level = 2
    }
}
else if (@rpt_id = 6)
{
    /* Test Activity (Summary [default] or Detail) */
    publish data
     where fld1 = decode(nvl(@show_detail, 0), '0', 'urh.uc_repprv,urh.prt_client_id,dh.make,dh.model,urh.trbcod,urh.uc_repsts', '1', 'urh.uc_repprv,urh.prt_client_id,urh.dtlnum,urh.prtnum,urh.rcvkey,' || decode(@show_prtdsc, '1', 'pd.lngdsc,', '') || 'dh.make,dh.model,dh.devcol,dh.devsiz,urh.trbcod,urh.trbfnd,urh.rmanum, urh.comment1, urh.comment2,urh.uc_repsts', @show_detail)
    |
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select to_char(trunc(urh.repdte), 'MM/DD/RRRR') repdte,
              @fld1:raw,
              decode(p.rtnum1, 1, decode(nvl(urh.cosrep, 0), '0', 'Pass (w/o part)', 'Pass (w/ part)'), 2, 'Fail', 3, 'RUR', 'Other') status,
              sum(decode(nvl(p.rtstr1, 0), '0', 0, 1)) completed,
              sum(decode(nvl(urh.rftest, nvl(functst, 0)), '0', 0, 1)) rf_func_test,
              sum(decode(nvl(urh.rftest, 0), '0', 0, 1)) rf_test,
              sum(decode(nvl(functst, 0), '0', 0, 1)) func_test,
              sum(decode(nvl(urh.flshrst, 0), '0', 0, 1)) flash,
              sum(decode(nvl(urh.polbuf, 0), '0', 0, 1)) polish,
              sum(decode(nvl(urh.cosrep, 0), '0', 0, 1)) cosmetic,
              sum(decode(nvl(urh.funrep, 0), '0', 0, 1)) funrep,
              sum(decode(nvl(urh.finqa, 0), '0', 0, 1)) finqa,
              sum(decode(nvl(urh.pass_cpi, 0), '0', 0, 1)) pass_cpi,
              nvl(sum((select sum(urd.prtcst*urd.used)
                         from usr_repdtl urd
                        where urd.dtlnum = urh.dtlnum
                          and urd.fifdte = urh.fifdte
                          and urd.uc_repprv = urh.uc_repprv
                          and urd.used != 0)), 0) test_part_cost
         from prtdsc pd,
              usr_dvlhdr dh,
              usr_poldat_view p,
              usr_rephdr urh
        where pd.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
          and pd.colval(+) = dh.prtnum || '|' || dh.prt_client_id || '|' || nvl(@wh_id, '----')
          and pd.colnam(+) = 'prtnum|prt_client_id|wh_id_tmpl'
          and dh.prtnum = urh.prtnum
          and dh.prt_client_id = urh.prt_client_id
          and p.polcod = 'USR-TEST-REPAIR'
          and p.polvar = urh.uc_repprv
          and p.polval = 'FINAL-REPSTS'
          and p.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
          and p.uc_client_id = urh.prt_client_id
          and p.rtstr1 = urh.uc_repsts
          and (urh.repdte between @flddte:raw)
          and @+urh.uc_repprv
          and @+urh.prt_client_id
          and @+dh.make
          and @+dh.model
          and @+urh.uc_repsts
        group by trunc(urh.repdte),
              decode(p.rtnum1, 1, decode(nvl(urh.cosrep, 0), '0', 'Pass (w/o part)', 'Pass (w/ part)'), 2, 'Fail', 3, 'RUR', 'Other'),
              @fld1:raw]]]
    |
    if (@show_detail = 1)
    {
        [select (select sales_channel
                   from usr_rmahdr
                  where rmanum = @rmanum
                    and client_id = @prt_client_id
                    and rownum < 2) sales_channel,
                (select rl.invnum
                   from rcvlin rl
                  where rl.rcvkey = @rcvkey
                    and rl.client_id = @prt_client_id
                    and rownum < 2) invnum
           from dual]
        |
        filter data
         where moca_filter_level = 3
           and sales_channel = @sales_channel
           and ponum = @invnum
    }
    else
    {
        filter data
         where moca_filter_level = 2
    }
}
else if (@rpt_id = 7)
{
    /* Test Daily Status */
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select to_char(urh.moddte, decode(nvl(@show_by_hour, 0), 0, 'MM/DD/RRRR', 1, 'MM/DD/YYYY-HH24', @show_by_hour)) moddte,
              urh.uc_repprv,
              urh.prt_client_id,
              sum(decode(urh.uc_repsts, 'X', 1, 0)) exception,
              sum(decode(urh.uc_repsts, 'H', 1, 0)) hold,
              sum(decode(urh.uc_repsts, 'J', 1, 0)) project,
              sum(decode(urh.uc_repsts, 'W', 1, 0)) waiting,
              sum(decode(urh.uc_repsts, 'I', 1, 0)) in_process,
              sum(decode(urh.uc_repsts, 'H', 0, 'I', 0, 'J', 0, 'W', 0, 'X', 0, decode(nvl(p.rtnum1, 0), '1', 0, '2', 0, '3', 0, 1))) other,
              count(urh.dtlnum) total_processed,
              sum(decode(nvl(p.rtnum1, 0), '1', 1, '2', 1, '3', 1, 0)) completed,
              sum(decode(nvl(p.rtnum1, 0), '1', 1, 0)) passed,
              sum(decode(nvl(p.rtnum1, 0), '2', 1, 0)) failed,
              sum(decode(nvl(p.rtnum1, 0), '3', 1, 0)) returned_unrepairable,
              sum(decode(nvl(urh.rftest, nvl(functst, 0)), '0', 0, 1)) rf_func_test,
              sum(decode(nvl(urh.flshrst, 0), '0', 0, 1)) flash,
              sum(decode(nvl(urh.polbuf, 0), '0', 0, 1)) polish,
              sum(decode(nvl(urh.cosrep, 0), '0', 0, 1)) cosmetic
         from usr_poldat_view p,
              usr_rephdr urh
        where p.polcod(+) = 'USR-TEST-REPAIR'
          and p.polvar(+) = urh.uc_repprv
          and p.polval(+) = 'FINAL-REPSTS'
          and p.wh_id(+) = nvl(@wh_id, nvl(@@wh_id, '----'))
          and p.uc_client_id(+) = urh.prt_client_id
          and p.rtstr1(+) = urh.uc_repsts
          and (urh.moddte between @flddte:raw)
          and @+urh.uc_repprv
          and @+urh.prt_client_id
        group by to_char(urh.moddte, decode(nvl(@show_by_hour, 0), 0, 'MM/DD/RRRR', 1, 'MM/DD/YYYY-HH24', @show_by_hour)),
              urh.uc_repprv,
              urh.prt_client_id]]]
}
else if (@rpt_id = 8)
{
    /* Test Work-In-Process */
    execute usr sql
     where sqlcmd =
    [
     [select sysdate,
             tmp.uc_repprv,
             dh.prtnum,
             dh.prt_client_id,
             dh.make,
             dh.model,
             dh.uc_repprv conf_repprv,
             tmp.uc_repsts,
             tmp.invsts,
             tmp.count
        from usr_dvlhdr dh,
             usr_poldat_view p,
             (select a.uc_repprv,
                     d.prtnum,
                     d.prt_client_id,
                     d.uc_repsts,
                     d.invsts,
                     a.wh_id,
                     count(1) count
                from invdtl d,
                     invsub s,
                     invlod l,
                     locmst lm,
                     aremst a
               where l.wh_id = lm.wh_id
                 and d.subnum = s.subnum
                 and s.lodnum = l.lodnum
                 and l.stoloc = lm.stoloc
                 and lm.wh_id = a.wh_id
                 and lm.arecod = a.arecod
                 and a.uc_repprv is not null
                 and @+a.wh_id
                 and @+a.uc_repprv
                 and @+d.prt_client_id
                 and @+d.prtnum
               group by a.uc_repprv,
                     d.prtnum,
                     d.prt_client_id,
                     d.uc_repsts,
                     d.invsts,
                     a.wh_id) tmp
       where dh.prtnum = tmp.prtnum
         and dh.prt_client_id = tmp.prt_client_id
         and p.polcod = 'USR-TEST-REPAIR'
         and p.polvar = tmp.uc_repprv
         and p.polval = 'VALID-PRT-CLIENT-ID'
         and p.wh_id = tmp.wh_id
         and p.uc_client_id = tmp.prt_client_id]]
}
else if (@rpt_id = 9)
{
    /* Test Damage Found */
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select to_char(trunc(urh.repdte), 'MM/DD/RRRR') repdte,
              urh.uc_repprv,
              dh.make,
              dh.model,
              urh.prtnum,
              urh.prt_client_id,
              count(urh.abuse) customer_damage_detected,
              sum(decode(nvl(p.rtnum1, 0), '1', 1, 0)) repaired,
              sum(decode(nvl(p.rtnum1, 0), '1', 0, 1)) non_repairable
         from usr_dvlhdr dh,
              usr_poldat_view p,
              usr_rephdr urh
        where dh.prt_client_id = urh.prt_client_id
          and dh.prtnum = urh.prtnum
          and p.polcod = 'USR-TEST-REPAIR'
          and p.polvar = urh.uc_repprv
          and p.polval = 'FINAL-REPSTS'
          and p.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
          and p.uc_client_id = urh.prt_client_id
          and p.rtstr1 = urh.uc_repsts
          and urh.abuse = 1
          and (urh.repdte between @flddte:raw)
          and @+urh.uc_repprv
          and @+dh.make
          and @+dh.model
          and @+urh.prtnum
          and @+urh.prt_client_id
        group by trunc(urh.repdte),
              urh.uc_repprv,
              dh.make,
              dh.model,
              urh.prtnum,
              urh.prt_client_id]]]
}
else if (@rpt_id = 10)
{
    /* Test Trouble Accuracy */
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select to_char(trunc(urh.repdte), 'MM/DD/RRRR') repdte,
              urh.uc_repprv,
              dh.make,
              dh.model,
              urh.prtnum,
              urh.prt_client_id,
              count(1) completed,
              sum(nvl(urh.match, 0)) trouble_matched,
              round((sum(nvl(urh.match, 0)) / count(1)) * 100, 1) accuracy
         from usr_dvlhdr dh,
              usr_poldat_view p,
              usr_rephdr urh
        where dh.prt_client_id = urh.prt_client_id
          and dh.prtnum = urh.prtnum
          and p.polcod = 'USR-TEST-REPAIR'
          and p.polvar = urh.uc_repprv
          and p.polval = 'FINAL-REPSTS'
          and p.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
          and p.uc_client_id = urh.prt_client_id
          and p.rtstr1 = urh.uc_repsts
          and (urh.repdte between @flddte:raw)
          and @+urh.uc_repprv
          and @+dh.make
          and @+dh.model
          and @+urh.prtnum
          and @+urh.prt_client_id
        group by trunc(urh.repdte),
              urh.uc_repprv,
              dh.make,
              dh.model,
              urh.prtnum,
              urh.prt_client_id]]]
}
else if (@rpt_id = 11)
{
    /* Test Component Usage summary or detail */
    publish data
     where fld1 = decode(nvl(@show_detail, 0), '0', 'urd.repprt, urd.prtdsc, pd.lngdsc', '1', 'urd.dtlnum,urh.cosrep,urd.repprt,urd.prtdsc,pd.lngdsc', @show_detail)
    |
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select /*+ RULE */
              to_char(trunc(urh.repdte), 'MM/DD/RRRR') repdte,
              urh.uc_repprv,
              urh.prt_client_id,
              dh.make,
              dh.model,
              dh.devcol,
              dh.devsiz,
              @fld1:raw,
              urh.prtnum,
              sum(nvl(urd.used, 0)) usage,
              round(urd.prtcst, 2) part_cost,
              sum(nvl(urd.used, 0) * round(urd.prtcst, 2)) total,
              sum(nvl(urd.scrap, 0)) scrap,
              sum(nvl(urd.scrap, 0) * round(urd.prtcst, 2)) scrap_cost,
              sum(nvl(urd.used, 0) + nvl(urd.scrap, 0)) total_usage,
              sum((nvl(urd.used, 0) + nvl(urd.scrap, 0)) * round(urd.prtcst, 2)) total_cost
         from usr_dvlhdr dh,
              usr_repdtl urd,
              usr_poldat_view p,
              usr_rephdr urh,
              prtdsc pd
        where dh.prt_client_id = urh.prt_client_id
          and dh.prtnum = urh.prtnum
          and urd.dtlnum = urh.dtlnum
          and urd.fifdte = urh.fifdte
          and urd.uc_repprv = urh.uc_repprv
          and (urd.used != 0 or urd.scrap != 0)
          and pd.colval(+) = urh.prtnum || '|' || urh.prt_client_id || '|' || nvl(@wh_id, '----')
          and pd.colnam(+) = 'prtnum|prt_client_id|wh_id_tmpl'
          and pd.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
          and p.polcod = 'USR-TEST-REPAIR'
          and p.polvar = urh.uc_repprv
          and p.polval = 'FINAL-REPSTS'
          and p.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
          and p.uc_client_id = urh.prt_client_id
          and p.rtstr1 = urh.uc_repsts
          and (urh.repdte between @flddte:raw)
          and @+urh.uc_repprv
          and @+urh.prtnum
          and @+urh.prt_client_id
          and @+urh.dtlnum
          and @+urd.repprt
          and @+dh.make
          and @+dh.model
          and @+p.wh_id
        group by trunc(urh.repdte),
              urh.uc_repprv,
              urh.prt_client_id,
              dh.make,
              dh.model,
              dh.devcol,
              dh.devsiz,
              @fld1:raw,
              urh.prtnum,
              prtcst]]]
}
else if (@rpt_id = 12)
{
    /* Test Recondition Activity */
    execute usr sql
     where sqlcmd =
    [publish data
      where fld1 = decode(nvl(@dtlnum, ''), '', ' (urh.repdte between ' || @flddte || ')', " urh.dtlnum = '" || @dtlnum || "' ")
        and fld2 = decode(nvl(@dtlnum, ''), '', ', usr_rephdr urh where urd.dtlnum = urh.dtlnum and urd.fifdte = urd.fifdte and urd.uc_repprv = urd.uc_repprv and (urh.repdte between ' || @flddte || ')', " where urd.dtlnum = '" || @dtlnum || "' ")
     |
     list usr prod with arch
      where cmd =
     [
      [select 'HEADER' type,
              urh.*
         from usr_rephdr urh
        where @fld1:raw]] &
     list usr prod with arch
      where cmd =
     [
      [select 'DETAIL' type,
              urd.*
         from usr_repdtl urd @fld2:raw]] catch(510)]
}
else if (@rpt_id = 13)
{
    /* Repair Provider Employee Productivity Report */
    publish data
     where fld1 = 'pv.' || decode(nvl(@show_detail, 0), '0', 'uc_rep_usr_id', @show_detail)
       and fld2 = decode(nvl(@show_detail, 0), '0', 'uc_rep_usr_id', @show_detail)
       and fld3 = 'urh.' || decode(nvl(@show_detail, 0), '0', 'uc_rep_usr_id', @show_detail)
    |
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select trunc(pv.adddte) adddte,
              pv.uc_repprv,
              pv.prt_client_id,
              @fld1:raw,
              sum(pv.rftest) rf,
              sum(pv.functst) function,
              sum(pv.flshrst) flash,
              sum(pv.cosrep) cosmestic,
              sum(pv.polbuf) polish,
              sum(pv.checkout) checkout,
              sum(pv.rftest) + sum(pv.functst) + sum(pv.flshrst) + sum(pv.cosrep) + sum(pv.polbuf) + sum(pv.checkout) pcs_processed
         from (select trunc(urh.adddte) adddte,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      urh.rftest @fld2:raw,
                      count(urh.rftest) rftest,
                      0 functst,
                      0 flshrst,
                      0 cosrep,
                      0 polbuf,
                      0 checkout
                 from usr_rephdr urh
                where (urh.adddte between @flddte:raw)
                  and urh.rftest is not null
                group by urh.rftest,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      trunc(urh.adddte)
               union
               select trunc(urh.adddte) adddte,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      urh.functst @fld2:raw,
                      0 rftest,
                      count(urh.functst) functst,
                      0 flshrst,
                      0 cosrep,
                      0 polbuf,
                      0 checkout
                 from usr_rephdr urh
                where (urh.adddte between @flddte:raw)
                  and urh.functst is not null
                group by urh.functst,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      trunc(urh.adddte)
               union
               select trunc(urh.adddte) adddte,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      urh.flshrst @fld2:raw,
                      0 rftest,
                      0 functst,
                      count(urh.flshrst) flshrst,
                      0 cosrep,
                      0 polbuf,
                      0 checkout
                 from usr_rephdr urh
                where (urh.adddte between @flddte:raw)
                  and urh.flshrst is not null
                group by urh.flshrst,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      trunc(urh.adddte)
               union
               select trunc(urh.adddte) adddte,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      urh.polbuf @fld2:raw,
                      0 rftest,
                      0 functst,
                      0 flshrst,
                      0 cosrep,
                      count(urh.polbuf) polbuf,
                      0 checkout
                 from usr_rephdr urh
                where (urh.adddte between @flddte:raw)
                  and urh.polbuf is not null
                group by urh.polbuf,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      trunc(urh.adddte)
               union
               select trunc(urh.adddte) adddte,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      urh.cosrep @fld2:raw,
                      0 rftest,
                      0 functst,
                      0 flshrst,
                      count(urh.cosrep) cosrep,
                      0 polbuf,
                      0 checkout
                 from usr_rephdr urh
                where (urh.adddte between @flddte:raw)
                  and urh.cosrep is not null
                group by urh.cosrep,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      trunc(urh.adddte)
               union
               select trunc(urh.adddte) adddte,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      @fld3:raw,
                      0 rftest,
                      0 functst,
                      0 flshrst,
                      0 cosrep,
                      0 polbuf,
                      count(1) checkout
                 from usr_rephdr urh
                where (urh.adddte between @flddte:raw)
                  and urh.repdte is not null
                group by @fld3:raw,
                      urh.uc_repprv,
                      urh.prt_client_id,
                      trunc(urh.adddte)) pv
        group by trunc(pv.adddte),
              pv.uc_repprv,
              pv.prt_client_id,
              @fld1:raw]]]
}
else if (@rpt_id = 14)
{
    /* NTF Summary Report */
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select trunc(urh.repdte) repdte,
              urh.uc_repprv,
              dh.make,
              dh.model,
              pm.prtnum,
              pm.uc_carrier,
              urh.prt_client_id,
              round((sum(decode(nvl(p.rtnum1, 0), '1', 1, 0)) / count(1)) * 100, 2) avg_ntf,
              sum(decode(nvl(p.rtnum1, 0), '1', 1, 0)) passed,
              sum(decode(nvl(p.rtnum1, 0), '2', 1, 0)) failed,
              sum(decode(nvl(p.rtnum1, 0), '3', 1, 0)) returned_unrepairable,
              count(1) completed
         from usr_poldat_view p,
              prtmst_view pm,
              usr_dvlhdr dh,
              usr_rephdr urh
        where p.polcod(+) = 'USR-TEST-REPAIR'
          and p.polvar(+) = urh.uc_repprv
          and p.polval(+) = 'FINAL-REPSTS'
          and p.wh_id(+) = nvl(@wh_id, '----')
          and p.rtstr1(+) = urh.uc_repsts
          and pm.prtnum = urh.prtnum
          and pm.prt_client_id = urh.prt_client_id
          and p.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
          and p.uc_client_id = urh.prt_client_id
          and dh.prtnum = urh.prtnum
          and dh.prt_client_id = urh.prt_client_id
          and (urh.repdte between @flddte:raw)
          and @+urh.uc_repprv
          and @+dh.make
          and @+dh.model
          and @+urh.prtnum
          and @+urh.prt_client_id
          and @+pm.wh_id
        group by trunc(urh.repdte),
              urh.uc_repprv,
              dh.make,
              dh.model,
              pm.prtnum,
              pm.uc_carrier,
              urh.prt_client_id]]]
}
else if (@rpt_id = 15)
{
    /* Trouble Found and Comments input
     * - begdte (required)
     * - enddte (required)
     * - ordertyp (optional)
     * - partnum (optional)
     * - client_id (required)
     */
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select trunc(urh.repdte) repdte,
              urh.dtlnum,
              urh.uc_repprv,
              urh.fifdte,
              urh.prtnum,
              urh.prt_client_id,
              urh.retcod,
              urh.trbfnd,
              urh.trbcod,
              urh.abuse,
              nvl(urh.calltimer_hour, '0') || ':' || rpad(nvl(urh.calltimer_min, '0'), 2, '0') calltimer,
              urh.comment1,
              urh.comment2
         from usr_rephdr urh
        where (urh.repdte between @flddte:raw)
          and @+urh.prt_client_id
          and @+urh.uc_repprv
        order by trunc(urh.adddte),
              urh.dtlnum,
              urh.uc_repprv]]]
}
else if (@rpt_id = 16)
{
    /* Test Waiting Product Summary */
    /* Select does not need to check data in archive because repsts W is not a
     * final desposition */
    publish data
     where fld1 = decode(nvl(@show_prtdsc, 0), '0', '', '1', 'urd.prtdsc,pd.lngdsc,', @show_prtdsc)
    |
    execute usr sql
     where sqlcmd =
    [
     [select sysdate curdte,
             trunc(urh.adddte) adddte,
             urh.prtnum,
             urh.prt_client_id,
             urd.make,
             urd.model,
             urd.repprt,
             @fld1:raw sum(nvl(urd.wait, 0)) wait,
             sum(nvl(urd.used, 0)) used
        from usr_repdtl urd,
             usr_rephdr urh,
             prtdsc pd
       where urd.dtlnum = urh.dtlnum
         and urd.fifdte = urh.fifdte
         and urd.uc_repprv = urh.uc_repprv
         and pd.colval(+) = urh.prtnum || '|' || urh.prt_client_id || '|' || nvl(@wh_id, '----')
         and pd.colnam(+) = 'prtnum|prt_client_id|wh_id_tmpl'
         and pd.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
         and urh.uc_repsts = 'W'
         and (urd.used = 1 or urd.wait = 1)
         and @+urh.uc_repprv
         and @+urh.prtnum
         and @+urh.prt_client_id
         and @+urh.dtlnum
         and @+urd.repprt
         and @+dh.make
         and @+dh.model
       group by trunc(urh.adddte),
             urh.prtnum,
             urh.prt_client_id,
             urd.make,
             urd.model,
             @fld1:raw urd.repprt]]
}
else if (@rpt_id = 17)
{
    /* Test Waiting Product Detail
       -  added wait_start and wait_end columns */
    /* Select does not need to check data in archive because repsts W is not a
     * final desposition */
    publish data
     where fld1 = decode(nvl(@show_prtdsc, 0), '0', '', '1', 'urd.prtdsc, pd.lngdsc,', @show_prtdsc)
    |
    execute usr sql
     where sqlcmd =
    [
     [select sysdate curdte,
             trunc(urh.adddte) adddte,
             urh.prtnum,
             urh.prt_client_id,
             urd.make,
             urd.model,
             urd.repprt,
             @fld1:raw urd.wait,
             urd.used,
             urd.dtlnum,
             urd.serial,
             l.stoloc,
             l.lodnum,
             urd.wait_start,
             urd.wait_end
        from invlod l,
             invsub s,
             invdtl d,
             usr_repdtl urd,
             usr_rephdr urh,
             prtdsc pd
       where l.lodnum = s.lodnum
         and s.subnum = d.subnum
         and d.dtlnum = urd.dtlnum
         and pd.colval(+) = urh.prtnum || '|' || urh.prt_client_id || '|' || nvl(@wh_id, '----')
         and pd.colnam(+) = 'prtnum|prt_client_id|wh_id_tmpl'
         and pd.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
         and urd.dtlnum = urh.dtlnum
         and urd.fifdte = urh.fifdte
         and urd.uc_repprv = urh.uc_repprv
         and urh.uc_repsts = 'W'
         and (urd.used = 1 or urd.wait = 1)
         and @+urh.uc_repprv
         and @+urh.prtnum
         and @+urh.prt_client_id
         and @+urh.dtlnum
         and @+urd.repprt
         and @+dh.make
         and @+dh.model
       order by trunc(urh.adddte),
             urh.dtlnum,
             urh.uc_repprv]]
}
else if (@rpt_id = 18)
{
    /* Repair Provider Cell Productivity Report */
    publish data
     where fld1 = decode(nvl(@show_detail, 0), '0', ' urh.uc_rep_cell', '1', ' urh.uc_rep_cell, urh.uc_repsts', @show_detail)
    |
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select trunc(urh.adddte) adddte,
              urh.uc_repprv,
              urh.prt_client_id,
              @fld1:raw,
              sum(decode(nvl(urh.rftest, '0'), '0', 0, 1)) rftest,
              sum(decode(nvl(urh.functst, '0'), '0', 0, 1)) functst,
              sum(decode(nvl(urh.flshrst, '0'), '0', 0, 1)) flshrst,
              sum(decode(nvl(urh.cosrep, '0'), '0', 0, 1)) cosrep,
              sum(decode(nvl(urh.polbuf, '0'), '0', 0, 1)) polbuf,
              sum(decode(nvl(to_char(urh.repdte, 'YYYYMMDD'), '0'), '0', 0, 1)) checkout
         from usr_rephdr urh
        where (urh.adddte between @flddte:raw)
        group by trunc(urh.adddte),
              urh.uc_repprv,
              @fld1:raw,
              urh.prt_client_id]]]
}
else if (@rpt_id = 19)
{
    /* Rebox Work-In-Process */
    execute usr sql
     where sqlcmd =
    [
     [select sysdate curdte,
             tmp.arecod,
             dh.prtnum,
             dh.prt_client_id,
             nvl(pd.lngdsc, pd.short_dsc) prtdsc,
             dh.make,
             dh.model,
             tmp.invsts,
             tmp.uc_repsts,
             tmp.count
        from prtdsc pd,
             usr_dvlhdr dh,
             (select a.arecod,
                     d.prtnum,
                     d.prt_client_id,
                     d.invsts,
                     d.uc_repsts,
                     count(1) count
                from invdtl d,
                     invsub s,
                     invlod l,
                     locmst lm,
                     aremst a
               where l.wh_id = lm.wh_id
                 and d.subnum = s.subnum
                 and s.lodnum = l.lodnum
                 and l.stoloc = lm.stoloc
                 and lm.wh_id = a.wh_id
                 and lm.arecod = a.arecod
                 and a.arecod in (select rtstr1
                                    from usr_poldat_view p
                                   where p.polcod = 'USR-REPORTS'
                                     and p.polvar = 'WORK-IN-PROCESS'
                                     and p.polval = nvl(@report_type, 'REBOX') || '-ARECOD-LIST'
                                     and p.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
                                     and p.uc_client_id = d.prt_client_id)
                 and @+a.wh_id
               group by a.arecod,
                     d.prtnum,
                     d.prt_client_id,
                     d.invsts,
                     d.uc_repsts) tmp
       where pd.colval(+) = dh.prtnum || '|' || dh.prt_client_id || '|' || nvl(@wh_id, '----')
         and pd.colnam(+) = 'prtnum|prt_client_id|wh_id_tmpl'
         and pd.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
         and dh.prtnum = tmp.prtnum
         and dh.prt_client_id = tmp.prt_client_id]]
}
else if (@rpt_id = 21)
{
    /* NDC Daily Receiving */
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select distinct rt.trknum,
              tr.arrdte,
              rt.clsdte,
              ri.client_id,
              rl.prtnum,
              pd.lngdsc prtdsc,
              dm.lngdsc uc_supplier,
              pm.uc_make,
              pm.uc_model,
              ri.invnum,
              rl.invlin,
              rl.invsln,
              sum(rl.expqty) expqty,
              sum(rl.idnqty) idnqty
         from dscmst dm,
              prtdsc pd,
              prtmst_view pm,
              rcvlin rl,
              rcvinv ri,
              trlr tr,
              rcvtrk rt
        where pd.colnam(+) = 'prtnum|prt_client_id|wh_id_tmpl'
          and pd.colval(+) = rl.prtnum || '|' || rl.client_id || '|' || nvl(rl.wh_id, '----')
          and pd.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
          and dm.colnam(+) = 'uc_supplier'
          and dm.colval(+) = pm.uc_supplier
          and dm.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
          and pm.prtnum = rl.prtnum
          and pm.prt_client_id = rl.client_id
          and pm.wh_id = rl.wh_id
          and rl.trknum = ri.trknum
          and rl.client_id = ri.client_id
          and rl.supnum = ri.supnum
          and rl.invnum = ri.invnum
          and rl.wh_id = ri.wh_id
          and tr.trlr_id = rt.trlr_id
          and ri.trknum = rt.trknum
          and ri.wh_id = rt.wh_id
          and ri.invtyp = 'P'
          and rt.clsdte is not null
          and (rt.clsdte between @flddte:raw)
          and @+rt.wh_id
          and @+rl.invnum
          and @+rl.prtnum
          and @+rl.trknum
        group by rt.trknum,
              rt.clsdte,
              tr.arrdte,
              ri.client_id,
              rl.prtnum,
              pd.lngdsc,
              dm.lngdsc,
              pm.uc_make,
              pm.uc_model,
              ri.invnum,
              rl.invlin,
              rl.invsln] catch(-1403)] catch(510)]
}
else if (@rpt_id = 22)
{
    /* number of cartons shipped by carrier */
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select user,
              trunc(s.loddte) loddte,
              o.client_id,
              o.ordtyp,
              s.carcod,
              s.srvlvl,
              count(distinct m.subnum) case_count,
              count(distinct o.ordnum) order_count
         from ord o,
              shipment_line sl,
              manfst m,
              shipment s
        where o.ordnum = sl.ordnum
          and o.client_id = sl.client_id
          and o.wh_id = sl.wh_id
          and sl.ship_id = s.ship_id
          and @+sl.client_id
          and @+o.wh_id
          and m.ship_id = s.ship_id
          and (s.loddte between @flddte:raw)
        group by user,
              trunc(s.loddte),
              o.ordtyp,
              o.client_id,
              s.carcod,
              s.srvlvl] catch(-1430)]]
}
else if (@rpt_id = 23)
{
    /* Inventory Stock Status by Area Bin */
    execute usr sql
     where sqlcmd =
    [
     [select a.bldg_id,
             pm.prt_client_id,
             a.arecod,
             lm.stoloc,
             pm.vc_product_code product_code,
             d.prtnum,
             pd.lngdsc prt_desc,
             dm.lngdsc inv_sts,
             sum(d.untqty) unit_qty,
             pm.untcst unit_cost,
             sum(d.untqty * pm.untcst) total_cost,
             pm.vc_phase phase
        from usr_dvlhdr dh,
             prtdsc pd,
             prtmst_view pm,
             dscmst dm,
             invdtl d,
             invsub s,
             invlod l,
             locmst lm,
             aremst a
       where dh.prtnum = d.prtnum
         and dh.prt_client_id = d.prt_client_id
         and pd.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
         and pd.colval = d.prtnum || '|' || d.prt_client_id || '|' || nvl(pm.wh_id, '----')
         and pd.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
         and pm.prtnum = d.prtnum
         and pm.prt_client_id = d.prt_client_id
         and pm.wh_id = l.wh_id
         and dm.colnam = 'invsts'
         and dm.colval = d.invsts
         and dm.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
         and d.subnum = s.subnum
         and @+d.prt_client_id
         and s.lodnum = l.lodnum
         and l.stoloc = lm.stoloc
         and lm.wh_id = a.wh_id
         and lm.arecod = a.arecod
         and @+a.bldg_id
         and @+a.wh_id
       group by a.bldg_id,
             pm.prt_client_id,
             a.arecod,
             lm.stoloc,
             pm.vc_product_code,
             d.prtnum,
             pd.lngdsc,
             dm.lngdsc,
             pm.untcst,
             pm.vc_phase]]
}
else if (@rpt_id = 24)
{
    /* Returned Phones Receipt Summary LENS version
       Returned Phones Receipt Summary FTP version
       is in generate usr att ftp reports where rpt_id = 6 */
    publish data
     where movref = nvl(@movref, "('RMA-WORK', 'RMA-UNDLIV', 'RMA-AGNT')")
       and frstol_adj = nvl(@frstol_adj, 'PERM-ADJ-LOC')
       and frstol_cre = nvl(@frstol_cre, 'PERM-CRE-LOC')
       and prt_client_id_in = nvl(@prt_client_id_in, "('RLO', 'CNG','AWS')")
    |
    execute usr sql
     where sqlcmd =
    [
     [select tmp.trndte,
             tmp.ordtyp,
             tmp.prtnum,
             tmp.prt_client_id,
             dh.model,
             nvl(dm.lngdsc, nvl(dm.short_dsc, dh.make)) uc_supplier,
             sum(tmp.trnqty) count,
             tmp.progtyp
        from dscmst dm,
             usr_dvlhdr dh,
             prtmst_view p,
             (select trunc(d.trndte) trndte,
                     (case when d.oprcod = pd.rtstr1 then 'Over-30'
                           else 'Under-30'
                      end) ordtyp,
                     pd.rtstr2 progtyp,
                     d.prtnum,
                     d.prt_client_id,
                     sum(d.trnqty) trnqty
                from dlytrn d,
                     usr_poldat_view pd
               where pd.polcod(+) = 'USR-REPORTS'
                 and pd.polvar(+) = 'RETURN-RECEIPTS-RPT'
                 and pd.polval(+) = 'OPRCOD'
                 and pd.wh_id(+) = nvl(@wh_id, nvl(@@wh_id, '----'))
                 and pd.rtnum1(+) = 1
                 and pd.uc_client_id(+) = nvl(d.prt_client_id, '----')
                 and pd.rtstr1(+) = d.oprcod
                 and d.movref || '' in @movref:raw
                 and d.frstol || '' = @frstol_adj
                 and d.prt_client_id in @prt_client_id_in:raw
                 and (d.trndte between @flddte:raw)
                 and @+d.wh_id
               group by trunc(d.trndte),
                     (case when d.oprcod = pd.rtstr1 then 'Over-30'
                           else 'Under-30'
                      end),
                     pd.rtstr2,
                     d.prtnum,
                     d.prt_client_id
              union all
              select tmp1.trndte,
                     (case when urh.sales_channel = pd.rtstr1 then 'Over-30'
                           else 'Under-30'
                      end) ordtyp,
                     pd.rtstr2 progtyp,
                     tmp1.prtnum,
                     tmp1.prt_client_id,
                     sum(tmp1.trnqty) trnqty
                from usr_rmahdr urh,
                     (select rmanum vc_invnum,
                             trunc(rcvdte) trndte,
                             rcvprt prtnum,
                             prt_client_id,
                             count(1) trnqty
                        from usr_rmaact
                       where (rcvdte between @flddte:raw)
                         and prt_client_id in @prt_client_id_in:raw
                       group by rmanum,
                             trunc(rcvdte),
                             rcvprt,
                             prt_client_id) tmp1,
                     usr_poldat_view pd
               where pd.polcod(+) = 'USR-REPORTS'
                 and pd.polvar(+) = 'RETURN-RECEIPTS-RPT'
                 and pd.polval(+) = 'SALES-CHANNEL'
                 and pd.wh_id(+) = nvl(@wh_id, nvl(@@wh_id, '----'))
                 and pd.rtnum1(+) = 1
                 and pd.uc_client_id(+) = nvl(urh.client_id, '----')
                 and pd.rtstr1(+) = urh.sales_channel
                 and urh.rmanum = tmp1.vc_invnum
                 and urh.client_id = tmp1.prt_client_id
               group by tmp1.trndte,
                     (case when urh.sales_channel = pd.rtstr1 then 'Over-30'
                           else 'Under-30'
                      end),
                     pd.rtstr2,
                     tmp1.prtnum,
                     tmp1.prt_client_id) tmp
       where dm.colnam(+) = 'uc_supplier'
         and dm.colval(+) = p.uc_supplier
         and dm.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
         and dh.prtnum = tmp.prtnum
         and dh.prt_client_id = tmp.prt_client_id
         and p.prtnum = tmp.prtnum
         and p.prt_client_id = tmp.prt_client_id
         and p.wh_id = nvl(@wh_id, '----')
       group by tmp.trndte,
             tmp.ordtyp,
             tmp.progtyp,
             tmp.prt_client_id,
             nvl(dm.lngdsc, nvl(dm.short_dsc, dh.make)),
             dh.model,
             tmp.prtnum]]
}
else if (@rpt_id = 25)
{
    /* Rebox Usage Activity */
    execute usr sql
     where sqlcmd =
    [publish data
      where fld1 = decode(nvl(@dtlnum, ''), '', ' (urd.moddte between ' || @flddte || ')', " dtlnum = '" || @dtlnum || "' ")
     |
     [select 'DETAIL' type,
             urd.*
        from usr_rbxdtl urd
       where @fld1:raw] catch(-1403)]
}
else if (@rpt_id = 26)
{
    /* Rebox Attach Rate */
    publish data
     where movref_esn = nvl(@movref_esn, '%-ESN')
       and frstol_adj = nvl(@frstol_adj, 'PERM-ADJ-LOC')
    |
    execute usr sql
     where sqlcmd =
    [
     [select tmp.prtnum,
             tmp.prt_client_id,
             rd.rbxprt,
             tmp.cnt total_reboxed_units,
             count(distinct rd.dtlnum || rd.fifdte) units_with_part_used,
             round(decode(tmp.cnt, 0, 0, count(distinct rd.dtlnum || rd.fifdte) / tmp.cnt) * 100, 2) attach_rate
        from usr_rbxdtl rd,
             (select min(trndte) mindte,
                     max(trndte) maxdte,
                     prtnum,
                     prt_client_id,
                     count(1) cnt
                from dlytrn dt
               where dt.movref like @movref_esn
                 and dt.frstol || '' = @frstol_adj
                 and (dt.trndte between @flddte:raw)
                 and @+dt.movref
                 and @+dt.wh_id
               group by prtnum,
                     prt_client_id) tmp
       where rd.dstprt(+) = tmp.prtnum
         and rd.prt_client_id( +) = tmp.prt_client_id
         and rd.used != 0
       group by tmp.prtnum,
             tmp.prt_client_id,
             tmp.cnt,
             rd.rbxprt]]
}
else if (@rpt_id = 27)
{
    /*Key Repair Data.*/
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select h.dtlnum,
              h.trbfnd,
              h.fifdte,
              h.repdte,
              h.uc_repsts,
              h.comment1,
              h.comment2,
              h.prtnum,
              h.prt_client_id,
              d.repprt,
              d.model,
              d.prtdsc,
              d.keyrep,
              d.symcod,
              d.fault_code
         from usr_rephdr h,
              usr_repdtl d
        where h.fifdte = d.fifdte
          and h.uc_repprv = d.uc_repprv
          and h.dtlnum = d.dtlnum
          and h.repdte between @flddte:raw
          and @+h.prt_client_id
          and @+h.uc_repprv]]]
}
else if (@rpt_id = 28)
{
    /* Repair BOM cost evaluation */
    execute usr sql
     where sqlcmd =
    [
     [select rp.repprt,
             p.prt_client_id,
             rp.uc_repprv,
             rp.model,
             rp.make,
             rp.devcol,
             rp.prtdsc,
             rp.prtcst,
             p.untcst
        from prtmst_view p,
             usr_repprt rp
       where p.prtnum(+) = rp.repprt
         and p.wh_id(+) = nvl(@wh_id, '----')
         and @+rp.uc_repprv
         and @+p.prt_client_id]]
}
else if (@rpt_id = 29)
    /* UNDER 30 DAY RTS Warranty Exchange Shipping */
{
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select o.vc_supnum,
              o.vc_reacod,
              to_char(s.loddte, 'YYYY/MM/DD') shpdte,
              to_char(o.cpodte, 'YYYY/MM/DD') poddte,
              o.ordnum,
              o.client_id,
              o.vc_sranum,
              dh.prtnum,
              dh.model,
              sl.shpqty
         from usr_poldat_view p,
              usr_dvlhdr dh,
              ord_line ol,
              ord o,
              shipment_line sl,
              shipment s
              /* add policy driven code here for DOA and EXCH */
        where p.polcod = 'USR-REPORTS'
          and p.polvar = 'UNDER-30-OEM-SHIPPING-REPORT'
          and p.polval = 'REASON-CODE'
          and p.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
          and p.uc_client_id = ol.client_id
          and o.vc_reacod = p.rtstr1
          and dh.prtnum = ol.prtnum
          and dh.prt_client_id = ol.prt_client_id
          and ol.client_id = sl.client_id
          and ol.ordnum = sl.ordnum
          and ol.ordlin = sl.ordlin
          and ol.ordsln = sl.ordsln
          and o.wh_id = ol.wh_id
          and o.client_id = sl.client_id
          and o.ordnum = sl.ordnum
          and sl.ship_id = s.ship_id
          and (s.loddte between @flddte:raw)
          and sl.shpqty > 0
          and @+o.wh_id
        order by s.loddte]]]
}
/* rpt_id = 30:ATC Raw Material Inventory WMS Report is replace by
   rpt_id = 8:(THL ATC Inventory Report) in generate usr thl reports */
else if (@rpt_id = 31)
{
    /*ATC Raw Material Inventory LENS Report*/
    execute usr sql
     where sqlcmd =
    [/* Get All repair parts for ATC */
     [select pm.prtnum,
             pm.untcst,
             pm.prt_client_id,
             pd.lngdsc
        from prtdsc pd,
             prtmst_view pm
       where pd.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
         and pd.colval = pm.prtnum || '|' || pm.prt_client_id || '|' || pm.wh_id
         and pd.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
         and pm.wh_id = nvl(@wh_id, '----')
         and pm.prt_client_id = @client_id]
     |
     /* Find All Inventory for these repair parts */
     [select dm.lngdsc invsts,
             lm.arecod,
             lm.stoloc,
             sum(id.untqty) qty
        from dscmst dm,
             locmst lm,
             invsub ib,
             invlod il,
             invdtl id
       where dm.colnam = 'invsts'
         and dm.colval = id.invsts
         and dm.locale_id = nvl(@locale_id, nvl(@@locale_id, ' US_ENGLISH '))
         and il.stoloc = lm.stoloc
         and il.wh_id = lm.wh_id
         and ib.subnum = id.subnum
         and il.lodnum = ib.lodnum
         and id.prt_client_id = @client_id
         and id.prtnum = @prtnum
       group by dm.lngdsc,
             lm.arecod,
             lm.stoloc] catch(-1403)
     |
     [select to_char(cnsdte, 'MM/DD/YYYY HH24:MI:SS') repdte
        from usr_repprt_usage
       where repprt = @prtnum] catch(-1403)
     |
     publish data
      where prt_client_id = @prt_client_id
        and prtnum = @prtnum
        and invsts = @invsts
        and lngdsc = @lngdsc
        and arecod = @arecod
        and stoloc = @stoloc
        and qty = @qty
        and untcst = @untcst
        and repdte = @repdte]
}
else if (@rpt_id = 32)
{
    /*THL Test and Repair Billing Report
       Input
     * - begdte (Required)
     * - enddte (Required)
     * - Client_id (Required)
     * - Repair Provider(Optional)*/
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select 'HEADER' type,
              urh.*
         from usr_rephdr urh
        where (urh.repdte between @flddte:raw)
          and urh.prt_client_id = @client_id
          and @+urh.uc_repprv] catch(-1403) &
      [select 'DETAIL' type,
              urd.*
         from usr_repdtl urd,
              usr_rephdr urh
        where urd.fifdte = urh.fifdte
          and urd.dtlnum = urh.dtlnum
          and urd.uc_repprv = urh.uc_repprv
          and (urh.repdte between @flddte:raw)
          and urh.prt_client_id = @client_id
          and @+urd.uc_repprv]]]
}
else if (@rpt_id = 33)
{
    if (@case_exception = 1)
    {
        publish data
         where fld4 = '(sum(t_main.case_short) > 0 or sum(t_main.case_over) > 0) '
           and fld2 =
        [sum(t_main.case_cnt) case_cnt,
                t_main.untcas,
                sum(t_main.case_short) case_short,
                sum(t_main.case_full) case_full,
                sum(t_main.case_over) case_over,
                max(t_main.max_slstdte) mod_case_date,]
    }
    else
    {
        publish data
         where fld4 = '1=1'
           and fld2 = ''
    }
    |
    if (@load_exception = 1)
    {
        publish data
         where fld3 = '(sum(t_main.pal_short) > 0 or sum(t_main.pal_over) > 0) '
           and fld1 =
        [sum(t_main.pal_cnt) pal_cnt,
                t_main.untpal,
                sum(t_main.pal_short) pal_short,
                sum(t_main.pal_full) pal_full,
                sum(t_main.pal_over) pal_over,
                max(t_main.max_llstdte) mod_load_date,]
    }
    else
    {
        publish data
         where fld3 = '1=1'
           and fld1 = ''
    }
    |
    [select t_main.prt_client_id,
            t_main.prtnum,
            t_main.lodlvl,
            t_main.stoloc,
            t_main.arecod,
            t_main.bldg_id,
            t_main.wh_id,
            @fld2:raw @fld1:raw sum(t_main. tot_qty) tot_qty,
            t_main.abccod,
            t_main.untcst,
            sum(t_main.value) value,
            max(t_main.max_lstmov) max_lstmov,
            min(t_main.min_fifdte) min_fifdte,
            max(t_main.max_fifdte) max_fifdte,
            min(t_main.min_untcas) min_untcas,
            max(t_main.max_untcas) max_untcas
       from (select t_load.prt_client_id,
                    t_load.prtnum,
                    t_load.lodlvl,
                    t_load.stoloc,
                    t_load.arecod,
                    t_load.bldg_id,
                    t_load.wh_id,
                    t_load.lodnum,
                    sum(t_load.case_qty) tot_qty,
                    max(t_load.lstmov) max_lstmov,
                    max(t_load.slstdte) max_slstdte,
                    max(t_load.llstdte) max_llstdte,
                    t_load.pal_cnt,
                    t_load.untpal,
                    decode(sign((t_load.untpal / sum(t_load.case_qty)) -1), 1, 1, -1, 0, 0, 0) pal_short,
                    decode(sign((t_load.untpal / sum(t_load.case_qty)) -1), 1, 0, -1, 0, 0, 1) pal_full,
                    decode(sign((t_load.untpal / sum(t_load.case_qty)) -1), 1, 0, -1, 1, 0, 0) pal_over,
                    sum(decode(sign((t_load.runtcas / t_load.case_qty) -1), 1, 1, -1, 0, 0, 0)) case_short,
                    sum(decode(sign((t_load.runtcas / t_load.case_qty) -1), 1, 0, -1, 0, 0, 1)) case_full,
                    sum(decode(sign((t_load.runtcas / t_load.case_qty) -1), 1, 0, -1, 1, 0, 0)) case_over,
                    sum(t_load.case_cnt) case_cnt,
                    t_load.untcas,
                    t_load.abccod,
                    t_load.untcst,
                    sum(t_load.case_qty) * t_load.untcst value,
                    min(t_load.min_fifdte) min_fifdte,
                    max(t_load.max_fifdte) max_fifdte,
                    min(t_load.min_untcas) min_untcas,
                    max(t_load.max_untcas) max_untcas
               from (select d.prt_client_id,
                            d.prtnum,
                            lm.arecod,
                            a.bldg_id,
                            l.wh_id,
                            lm.stoloc,
                            l.lodnum,
                            s.subnum,
                            pm.untcas,
                            pm.untpal,
                            max(d.lstmov) lstmov,
                            max(s.lstdte) slstdte,
                            max(l.lstdte) llstdte,
                            d.untcas runtcas,
                            count(distinct (s.subnum)) case_cnt,
                            count(distinct (l.lodnum)) pal_cnt,
                            sum(d.untqty) case_qty,
                            min(d.untcas) min_untcas,
                            max(d.untcas) max_untcas,
                            min(d.fifdte) min_fifdte,
                            max(d.fifdte) max_fifdte,
                            pm.untcst,
                            pm.abccod,
                            pm.lodlvl
                       from invdtl d,
                            invsub s,
                            invlod l,
                            locmst lm,
                            prtmst_view pm,
                            aremst a
                      where a.arecod = lm.arecod
                        and lm.stoloc = l.stoloc
                        and pm.prtnum = d.prtnum
                        and pm.prt_client_id = d.prt_client_id
                        and pm.wh_id = l.wh_id
                        and l.lodnum = s.lodnum
                        and s.subnum = d.subnum
                        and @+pm.lodlvl
                        and @+d.prtnum
                        and @+d.prt_client_id
                        and @+l.lodnum
                        and @+lm.stoloc
                        and @+lm.wh_id
                        and @+a.arecod
                        and @+a.bldg_id
                      group by s.subnum,
                            d.prt_client_id,
                            d.prtnum,
                            lm.arecod,
                            a.bldg_id,
                            l.wh_id,
                            lm.stoloc,
                            l.lodnum,
                            pm.untcas,
                            pm.untpal,
                            pm.untcst,
                            d.untcas,
                            pm.abccod,
                            pm.lodlvl) t_load
              group by t_load.prt_client_id,
                    t_load.prtnum,
                    t_load.arecod,
                    t_load.bldg_id,
                    t_load.wh_id,
                    t_load.stoloc,
                    t_load.lodnum,
                    t_load.untcas,
                    t_load.untpal,
                    t_load.pal_cnt,
                    t_load.untcst,
                    t_load.abccod,
                    t_load.lodlvl) t_main
      group by t_main.prt_client_id,
            t_main.prtnum,
            t_main.lodlvl,
            t_main.stoloc,
            t_main.arecod,
            t_main.bldg_id,
            t_main.wh_id,
            t_main.untpal,
            t_main.untcas,
            t_main.abccod,
            t_main.untcst
     having @fld3:raw
        and @fld4:raw
      order by t_main.prt_client_id,
            t_main.prtnum,
            t_main.lodlvl,
            t_main.stoloc,
            t_main.arecod,
            t_main.bldg_id,
            t_main.wh_id]
}
else if (@rpt_id = 34)
{
    /* Detail report for inventory aging*/
    [select /*+ RULE */
            (select bldg_id
               from aremst
              where arecod = d.lst_arecod
                and wh_id = l.wh_id) bldg_id,
            d.prt_client_id,
            d.prtnum,
            dh.model,
            dh.make,
            dh.devcol,
            dh.devsiz,
            d.dtlnum,
            d.invsts,
            d.lst_arecod arecod,
            l.stoloc,
            l.lodnum,
            pm.untcst,
            pm.lodlvl,
            d.untqty,
            (pm.untcst * d.untqty) cost,
            d.fifdte date_added,
            nvl(greatest(d.lstmov, l.lstdte), d.lstmov) last_move_date,
            decode((case when d.lstmov > l.lstdte or l.lstdte is null then d.lstmov
                         when d.lstmov < l.lstdte or d.lstmov is null then l.lstdte
                         when d.lstmov = l.lstdte then d.lstmov
                    end), d.lstmov, d.lst_usr_id, l.lst_usr_id) usr_id,
            d.uc_repsts
       from usr_dvlhdr dh,
            prtmst_view pm,
            invlod l,
            invsub s,
            invdtl d
      where dh.prtnum = d.prtnum
        and dh.prt_client_id = d.prt_client_id
        and pm.prtnum = d.prtnum
        and pm.prt_client_id = d.prt_client_id
        and pm.wh_id = l.wh_id
        and l.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
        and l.lodnum = s.lodnum
        and s.subnum = d.subnum
        and @+lst_arecod^arecod
        and @+l.stoloc
        and @+d.prt_client_id
        and @+pm.lodlvl
        and @+l.lodnum
        and @+d.prtnum
        and @+dh.model
        and @+dh.make
      order by d.lst_arecod,
            l.stoloc,
            d.fifdte]
    |
    if (nvl(@uc_show_additional_flds, 0) = 1)
    {
        [select *
           from (select flshdte,
                        swname,
                        swver,
                        data_source,
                        flshsts
                   from usr_reflash
                  where dtlnum = @dtlnum
                  order by flshdte desc)
          where rownum < 2] catch(-1403)
    }
    |
    if (nvl(@uc_show_additional_flds, 0) = 1)
    {
        filter data
         where moca_filter_level = 3
           and flshdte = to_char(@flshdte, 'MM/DD/YYYY HH12:MI PM')
           and swname = @swname
           and swver = @swver
           and data_source = @data_source
           and flshsts = @flshsts
           and date_added = to_char(@date_added, 'MM/DD/YYYY HH12:MI PM')
           and last_move_date = to_char(@last_move_date, 'MM/DD/YYYY HH12:MI PM')
    }
    else
    {
        filter data
         where moca_filter_level = 3
           and date_added = to_char(@date_added, 'MM/DD/YYYY HH12:MI PM')
           and last_move_date = to_char(@last_move_date, 'MM/DD/YYYY HH12:MI PM')
    }
}
else if (@rpt_id = 35)
{
    /*Summary report for inventory aging*/
    [select (select bldg_id
               from aremst
              where arecod = d.lst_arecod
                and wh_id = l.wh_id) bldg_id,
            d.prt_client_id,
            d.prtnum,
            d.lst_arecod arecod,
            l.stoloc,
            dh.model,
            dh.make,
            dh.devcol,
            dh.devsiz,
            pm.untcst,
            sum(d.untqty) untqty,
            sum(pm.untcst * d.untqty) tot_cost,
            min(d.fifdte) date_added,
            min(decode(l.lstmov, '', d.lstmov, l.lstmov)) last_move_date,
            nvl((select dm.lngdsc
                   from dscmst dm
                  where dm.colnam = 'invsts'
                    and dm.colval = d.invsts
                    and dm.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))), d.invsts) Invsts
       from usr_dvlhdr dh,
            prtmst_view pm,
            invlod l,
            invsub s,
            invdtl d
      where dh.prtnum = d.prtnum
        and dh.prt_client_id = d.prt_client_id
        and pm.prtnum = d.prtnum
        and pm.prt_client_id = d.prt_client_id
        and pm.wh_id = l.wh_id
        and l.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
        and l.lodnum = s.lodnum
        and s.subnum = d.subnum
        and @+lst_arecod^arecod
        and @+l.stoloc
        and @+d.prt_client_id
        and @+d.prtnum
      group by l.wh_id,
            d.prt_client_id,
            d.lst_arecod,
            l.stoloc,
            d.prtnum,
            dh.model,
            dh.make,
            dh.devcol,
            dh.devsiz,
            pm.untcst,
            d.invsts]
}
else if (@rpt_id = 36)
{
    /*Liquidation Report
       Input
     * - begdte (Required)
     * - enddte (Required)
     * - ordtyp (optional)*/
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select ol.prtnum,
              dm.lngdsc ordtyp,
              pm.wh_id,
              o.client_id,
              pd.lngdsc,
              pm.untcst,
              sum(sl.shpqty) shpqty,
              sum(pm.untcst * sl.shpqty) value,
              max(s.loddte) last_shp_dte
         from prtmst_view pm,
              ord_line ol,
              ord o,
              prtdsc pd,
              shipment_line sl,
              shipment s,
              dscmst dm
        where s.wh_id = sl.wh_id
          and s.ship_id = sl.ship_id
          and s.shpsts = 'C'
          and (s.loddte between @flddte:raw)
          and ol.ordnum = sl.ordnum
          and ol.ordsln = sl.ordsln
          and ol.client_id = sl.client_id
          and ol.ordlin = sl.ordlin
          and ol.wh_id = sl.wh_id
          and o.ordnum = ol.ordnum
          and o.client_id = ol.client_id
          and o.wh_id = ol.wh_id
          and @+ordtyp
          and pm.prtnum = ol.prtnum
          and pm.prt_client_id = ol.prt_client_id
          and pm.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
          and pd.colval = ol.prtnum || '|' || ol.prt_client_id || '|' || ol.wh_id
          and pd.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
          and pd.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
          and dm.colnam = 'ordtyp'
          and dm.colval = o.ordtyp
          and dm.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
        group by ol.prtnum,
              dm.lngdsc,
              pm.wh_id,
              pm.untcst,
              o.client_id,
              pd.lngdsc]]]
}
else if (@rpt_id = 37)
{
    /* Build Summary Table for ATC Raw Material Inventory Report
     * Needs to run on a daily basis.
     * Input
     * client_id - required
     * begdte - required */
    execute usr sql
     where sqlcmd =
    [/* Get last repair date for every ATC repair part*/
     /* The insert/update logic handles potential duplicates from the max() "with arch"
      * so in this case the max() is ok */
     list usr prod with arch
      where cmd =
     [
      [select max(repdte) repdte,
              repprt
         from usr_rephdr urh,
              usr_repdtl urd
        where urd.uc_repprv = urh.uc_repprv
          and urd.fifdte = urh.fifdte
          and urd.dtlnum = urh.dtlnum
          and urh.repdte between @flddte:raw
        group by repprt]]
     |
     [select prtnum,
             prt_client_id
        from prtmst_view
       where prt_client_id = @client_id
         and prtnum = @repprt
         and wh_id = nvl(@wh_id, '----')] catch(-1403)
     |
     /* Get last repai date,last unit repaired, last user etc... for every ATC repair part
        (Date Range +.0001 and -.0001 is used for performance purposes) */
     if (@prtnum != '')
     {
         list usr prod then arch
          where cmd =
         [
          [select repprt,
                  repdte,
                  dtlnum,
                  fifdte,
                  uc_repprv,
                  moddte,
                  mod_usr_id
             from (select urd.repprt,
                          urh.repdte,
                          urh.dtlnum,
                          urh.fifdte,
                          urh.uc_repprv,
                          urh.moddte,
                          urh.mod_usr_id
                     from usr_rephdr urh,
                          usr_repdtl urd
                    where urd.uc_repprv = urh.uc_repprv
                      and urd.fifdte = urh.fifdte
                      and urd.dtlnum = urh.dtlnum
                      and urd.repprt || '' = @prtnum
                      and (urh.repdte between @repdte:date - .0001 and @repdte:date + .0001)
                    order by urh.repdte desc)
            where rownum < 2]] catch(-1403)
         |
         /* Scan Summary Usage Table for existing repair parts */
         [select repprt repprt_usage,
                 cnsdte repdte_usage
            from usr_repprt_usage
           where repprt = @repprt] catch(-1403)
         |
         /* If Repair Part does not exist in Summary table then Insert data otherwise update existing data*/
         if (@repprt_usage is null)
         {
             [insert
                into usr_repprt_usage(repprt, cnsdte, dtlnum, fifdte, uc_repprv, moddte, mod_usr_id)
              values (@repprt, @repdte, @dtlnum, @fifdte, @uc_repprv, @moddte, @mod_usr_id)] catch(@?)
         }
         else if (@repdte > @repdte_usage)
         {
             [update usr_repprt_usage
                 set cnsdte = @repdte,
                     dtlnum = @dtlnum,
                     fifdte = @fifdte,
                     uc_repprv = @uc_repprv,
                     moddte = @moddte,
                     mod_usr_id = @mod_usr_id
               where repprt = @repprt] catch(@?)
         }
     }]
}
else if (@rpt_id = 38)
{
    /* Generate OEM ASN Files.
       1- Under 30 Days : Reason code DOA
       2- Over 30 days : All Reason Codes other than DOA
       Input:
       - Path : required ex.: '/opt/mchugh/DEV/les/log'
       - begdte - required
       - enddte - required
       - uc_repprv_list = optional ex.: "('2','4','9')"
     */
    publish data
     where todays_date = to_char(sysdate, 'YYYYMMDDHH24MI')
       and repsts_repprv = nvl(@repsts_repprv, 'F4')
       and frstol_adj = nvl(@frstol_adj, 'PERM-ADJ-LOC')
       and frstol_cre = nvl(@frstol_cre, 'PERM-CRE-LOC')
       and movref_list = nvl(@movref_list, "('RMA-WORK','RMA-UNDLIV','RMA-AGNT', 'RMA-RCV')")
       and ext = nvl(@ext, 'csv')
       and path = @path
       and uc_repprv_list = nvl(@uc_repprv_list, "('2','4','3')")
    |
    if (@path = '')
    {
        /* needs a client id */
        [select min(rtstr1) path
           from usr_poldat_view
          where polcod = 'USR-ASN'
            and polvar = 'OEM-FILE-GENERATION'
            and polval = 'FILE-PATH'
            and wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
            and uc_client_id = nvl(@prt_client_id, @client_id)
            and rtnum1 = 1
            and rownum < 2]
    }
    |
    if (int(@display_data) = 0 and @path = '')
    {
        /* File Path is not defined. */
        set return status
         where status = 80697
    }
    |
    if (@path != '')
    {
        fix usr file path
         where path = @path
    }
    |
    /* get order and shipment data */
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select o.client_id,
              substr(translate(trim(o.vc_reacod), ' ', '-'), 1, 3) vc_reacod,
              o.vc_supnum,
              o.ordnum,
              o.vc_sranum,
              s.loddte,
              s.ship_id,
              pd.rtstr2,
              sum(sl.shpqty) shpqty
         from usr_poldat_view pd,
              ord o,
              shipment_line sl,
              shipment s
        where pd.polcod = 'USR-RECEIVING'
          and pd.polvar = 'RTSASN'
          and pd.polval = 'INCLUDE-SUPPLIERS'
          and pd.rtstr1 = o.vc_supnum
          and pd.wh_id = o.wh_id
          and pd.uc_client_id = o.client_id
          and pd.rtnum1 = 1
          and sl.client_id = o.client_id
          and sl.ordnum = o.ordnum
          and sl.wh_id = s.wh_id
          and sl.ship_id = s.ship_id
          and s.shpsts != 'B'
          and s.loddte between @flddte:raw
          and o.vc_supnum is not null
          and @+o.vc_sranum
          and @+o.wh_id
          and @+o.client_id
          and @+o.ordnum
          and @+s.ship_id
        group by o.client_id,
              pd.rtstr2,
              o.vc_reacod,
              o.vc_supnum,
              o.ordnum,
              o.vc_sranum,
              s.loddte,
              s.ship_id] catch(-1403)] catch(510)]
    |
    execute os command
     where cmd = 'rm ' || @path || '/' || @ordnum || '_' || @shpqty || '_' || @todays_date || "*" catch(2)
    |
    /* get dtlnum data */
    list usr prod then arch
     where cmd =
    [
     [select d.dtlnum,
             d.prtnum,
             substr((select pd.lngdsc
                       from prtdsc pd
                      where pd.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
                        and pd.colval = d.prtnum || '|' || @client_id || '|' || nvl(@wh_id, '----')
                        and pd.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))), 1, 20) prtdsc,
             d.trnqty
        from dlytrn d
       where d.ship_id = @ship_id
         and d.ordnum = @ordnum
         and d.prt_client_id = @client_id
         and d.oprcod = 'LOAD']] catch(510)
    |
    /* get receive date */
    list usr prod then arch
     where cmd =
    [
     [select *
        from (select trunc(rcvdte) rcvdte
                from usr_rmaact
               where dtlnum = @dtlnum
                 and rcvdte <= @loddte:date
               order by rcvdte desc)
       where rownum < 2]] catch(510)
    |
    if (@vc_reacod != 'DOA')
    {
        /* Get complain information */
        list usr prod then arch
         where cmd =
        [
         [select *
            from (select d.hltcode catcod,
                         regexp_replace(d.trbcmt, '[|"]', '') freeform,
                         substr(d.lltcode, 1, instr(d.lltcode, '|') -1) numcod,
                         substr(d.lltcode, instr(d.lltcode, '|') + 1) commnt
                    from usr_rmadtl d,
                         usr_rmaact a
                   where d.rmanum = a.rmanum
                     and d.client_id = a.client_id
                     and d.rmalin = a.rmalin
                     and a.dtlnum = @dtlnum
                     and a.client_id = @client_id
                     and trunc(a.rcvdte) = @rcvdte:date
                   order by a.adddte desc)
           where rownum < 2]] catch(510)
    }
    |
    execute usr sql
     where show_header = 0
       and sep = 124
       and sqlcmd =
    [if (@vc_reacod = 'DOA')
     {
         /*get repair data */
         list usr prod with arch
          where cmd =
         [
          [select *
             from (select distinct dtlnum,
                          r.uc_repprv,
                          r.uc_repsts,
                          (case when @rtstr2 = 'RIM' and r.uc_repprv = '4' and r.uc_repsts is not null then 'HTA'
                                else null
                           end) htaflg,
                          (select nvl(d.lngdsc, r.uc_repsts)
                             from dscmst d
                            where d.colnam = 'uc_repsts'
                              and d.colval = r.uc_repsts
                              and d.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))) repair_sts,
                          nvl(r.comment1, r.comment2) cmt,
                          r.trbcod,
                          (select nvl(d.lngdsc, r.trbcod)
                             from dscmst d
                            where d.colnam = 'trbcod'
                              and d.colval = r.trbcod
                              and d.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))) trbcod_description,
                          r.fifdte
                     from usr_rephdr r
                    where r.uc_repprv in @uc_repprv_list:raw
                      and r.dtlnum = @dtlnum
                      and (r.repdte between @rcvdte:date and @loddte:date)
                    order by r.repdte desc)
            where rownum < 2] catch(-1403)] catch(510)
         |
         if (@trbcod = '')
         {
             /* Get data from Workflow */
             [select *
                from (select ta.trndte loddte,
                             ta.repnum,
                             taa.argval trbcod,
                             nvl((select d.lngdsc
                                    from dscmst d
                                   where d.colnam(+) = taa.argnam
                                     and d.colval(+) = taa.argval
                                     and d.locale_id = nvl(@local_id, nvl(@@locale_id, 'US_ENGLISH'))
                                     and rownum < 2), taa.argval) trbcod_description,
                             (select min(sd.dspcat)
                                from usr_tr_act ta1,
                                     usr_tr_step_config sc,
                                     usr_tr_section_disp sd
                               where sd.secdsp = sc.secdsp
                                 and sc.repstp = ta1.repstp
                                 and ta1.repnum = ta.repnum
                                 and ta1.flwsec = ta.flwsec
                                 and ta1.olddte is null) repair_sts
                        from usr_tr_act ta,
                             usr_tr_actarg taa,
                             usr_tr_step_argument tsa
                       where tsa.repstp = ta.repstp
                         and tsa.argnam = taa.argnam
                         and tsa.stparg_hstfld = 'dgl_repair_items_fail'
                         and taa.repnum = ta.repnum
                         and ta.dtlnum = @dtlnum
                         and ta.olddte is null
                         and (ta.trndte between nvl(@rcvdte:date, @loddte:date - 365) and @loddte:date)
                       order by ta.trndte desc)
               where rownum < 2] catch(-1403)
         }
         |
         publish data
          where ordnum = @ordnum
            and prtdsc = @prtdsc
            and dtlnum = @dtlnum
            and loddte = to_char(@loddte, 'YYYYMMDD')
            and ra_num = @vc_sranum
            and repair_sts = @repair_sts
            and repcmt = @cmt
            and trouble_code = @trbcod
            and description = @trbcod_description
     }
     else if (@rtstr2 = 'RIM')
     {
         publish data
          where ordnum = @ordnum
            and prtdsc = @prtdsc
            and prtnum = @prtnum
            and dtlnum = @dtlnum
            and loddte = to_char(@loddte, 'YYYYMMDD')
            and ordtyp = 'IW'
            and cmt = @commnt
            and catcod = @catcod
            and freeform = @freeform
            and numcod = @numcod
            and htaflg = @htaflg
     }
     else
     {
         publish data
          where ordnum = @ordnum
            and prtdsc = @prtdsc
            and prtnum = @prtnum
            and dtlnum = @dtlnum
            and loddte = to_char(@loddte, 'YYYYMMDD')
            and ordtyp = 'IW'
            and cmt = @commnt
            and catcod = @catcod
            and freeform = @freeform
            and numcod = @numcod
     }]
    |
    publish data
     where filnam = @ordnum || '_' || @shpqty || '_' || @todays_date || '.' || @rtstr2 || '.' || @vc_reacod || '.' || @ext
    |
    write output file
     where filnam = @filnam
       and path = @path
       and mode = 'A'
       and data = @data || chr(10)
}
else if (@rpt_id = 39)
{
    /* TTOM 2 Day Shipping Report */
    execute usr sql
     where sqlcmd =
    [list usr arch
      where cmd =
     [
      [select to_char(s.loddte, 'YYYY-MM-DD HH24:MI:SS') "loddte",
              o.ordnum,
              o.ordtyp,
              s.ship_id,
              ol.prtnum,
              ol.ordqty,
              ol.shpqty,
              o.stcust,
              a.adrnam,
              a.adrcty,
              a.adrstc,
              a.adrpsz
         from ord o,
              ord_line ol,
              shipment_line sl,
              shipment s,
              adrmst a
        where a.adr_id = o.st_adr_id
          and o.ordnum = ol.ordnum
          and o.client_id = ol.client_id
          and o.wh_id = ol.wh_id
          and @+o.ordtyp
          and ol.ordsln = sl.ordsln
          and ol.ordlin = sl.ordlin
          and ol.ordnum = sl.ordnum
          and ol.client_id = sl.client_id
          and ol.wh_id = sl.wh_id
          and sl.ship_id = s.ship_id
          and sl.client_id = @client_id
          and s.shpsts <> 'B'
          and (s.loddte between @flddte:raw)]]
     |
     [select distinct to_char(dt.trndte, 'YYYY-MM-DD HH24:MI:SS') trndte,
             @loddte "loddte",
             @ordnum "ordnum",
             @ordtyp "ordtyp",
             @ship_id "ship_id",
             @prtnum "prtnum",
             @ordqty "ordqty",
             @shpqty "shpqty",
             @stcust "stcust",
             @adrnam "adrnam",
             dt.usr_id
        from dlytrn dt
       where dt.trndte = (select max(trndte) trndte
                            from dlytrn
                           where prt_client_id = @client_id
                             and ordnum = @ordnum
                             and usr_id <> 'NOUSER')
         and dt.prt_client_id = @client_id
         and dt.ordnum = @ordnum]]
}
else if (@rpt_id = 40)
{
    /* Test Waiting Product report (AWP)
     * Input
     * begdte - required
     * enddte - required
     * Repair Provider - optional
     * prt_client_id - required
     */
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select urh.prt_client_id,
              urh.adddte,
              urd.wait_start,
              urd.wait_end,
              urh.prtnum,
              urd.model,
              urd.repprt,
              urd.prtdsc,
              urh.dtlnum,
              1 qty
         from usr_repdtl urd,
              usr_rephdr urh
        where urd.dtlnum = urh.dtlnum
          and urd.fifdte = urh.fifdte
          and urd.uc_repprv = urh.uc_repprv
          and urh.uc_repsts = nvl(@uc_repsts, 'W')
          and urd.wait_end between @flddte:raw
          and @+urh.uc_repprv
          and @+urh.prtnum
          and @+urh.prt_client_id
          and @+urh.dtlnum
          and @+urd.repprt
          and @+dh.make
          and @+dh.model
          and @+urh.uc_repsts
        order by urd.wait_end]]]
}
else if (@rpt_id = 41)
{
    /* Inventory Summary for Apple iPhone Matrix
     *  wh_id - Warehouse ID (Required)
     *  prt_client_id  - prt_client_id (optional)
     *  prtnum - prtnum (Optional)
     */
    publish data
     where trbfnd_codes = "('790','791','792','793','794')"
    |
    [select d.prtnum,
            d.prt_client_id,
            d.invsts,
            (case when urh.trbfnd in @trbfnd_codes:raw then urh.trbfnd
                  else 'other'
             end) trbfnd,
            (case when pd2.polvar is null and urh.uc_repsts is null then ''
                  when pd2.polvar = urh.uc_repprv then urh.uc_repsts
                  else 'other'
             end) repsts,
            pd.polval usr_lbl,
            sum(d.untqty) qty
       from usr_poldat_view pd2,
            usr_rephdr urh,
            usr_poldat_view pd,
            invlod l,
            invsub s,
            invdtl d,
            prtmst_view pm
      where pd2.polcod(+) = 'USR-TEST-REPAIR'
        and pd2.polval(+) = 'FINAL-REPSTS'
        and pd2.wh_id(+) = nvl(@wh_id, @@wh_id)
        and pd2.uc_client_id(+) = urh.prt_client_id
        and pd2.polvar(+) = urh.uc_repprv
        and pd2.rtstr1(+) = urh.uc_repsts
        and urh.dtlnum(+) = d.dtlnum
        and urh.prtnum(+) = d.prtnum
        and urh.prt_client_id(+) = d.prt_client_id
        and urh.fifdte(+) = d.fifdte
        and pd.polcod(+) = 'USR-REPORTS'
        and pd.polvar(+) = 'IPHONE-STOLOC'
        and pd.rtnum1(+) = 1
        and pd.rtstr1(+) = l.stoloc
        and pd.wh_id(+) = l.wh_id
        and pd.uc_client_id(+) = nvl(@prt_client_id, '----')
        and l.lodnum = s.lodnum
        and s.subnum = d.subnum
        and d.prtnum = pm.prtnum
        and d.prt_client_id = pm.prt_client_id
        and d.ship_line_id is null
        and upper(pm.typcod) like '%IPHONE%'
        and pm.wh_id = nvl(@wh_id, @@wh_id)
        and @+pm.prtnum
        and @+pm.prt_client_id
      group by d.prtnum,
            d.prt_client_id,
            d.invsts,
            (case when urh.trbfnd in @trbfnd_codes:raw then urh.trbfnd
                  else 'other'
             end),
            (case when pd2.polvar is null and urh.uc_repsts is null then ''
                  when pd2.polvar = urh.uc_repprv then urh.uc_repsts
                  else 'other'
             end),
            pd.polval] catch(-1403)
    |
    [select dm.lngdsc trbfnd_dsc
       from dscmst dm
      where dm.colnam = 'trbfnd'
        and dm.colval = @trbfnd
        and dm.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))] catch(-1403)
    |
    [select dm.lngdsc repsts_dsc
       from dscmst dm
      where dm.colnam = 'uc_repsts'
        and dm.colval = @repsts
        and dm.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))] catch(-1403)
    |
    publish data
     where prtnum = @prtnum
       and prt_client_id = @prt_client_id
       and invsts = @invsts
       and trbfnd = @trbfnd
       and trbfnd_dsc = @trbfnd_dsc
       and repsts = @repsts
       and repsts_dsc = @repsts_dsc
       and usr_lbl = @usr_lbl
       and qty = @qty
}
else if (@rpt_id = 42)
{
    /* Repair Detail for Apple iPhone Matrix
     *  wh_id - Warehouse ID (Required)
     *  begdte  - begin date (Required)
     *  enddte - end date (Required)
     */
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select trunc(rh.repdte) repdte,
              rh.uc_repprv,
              rh.prt_client_id,
              rh.prtnum,
              rh.uc_repsts,
              dm2.lngdsc,
              rh.fifdte,
              rh.dtlnum,
              rh.flshrst,
              rh.rftest,
              rh.functst,
              rh.comment1,
              rh.comment2,
              (case when rh.trbfnd in (select p1.rtstr1
                                         from usr_poldat_view p1
                                        where p1.polcod = 'USR-REPORTS'
                                          and p1.polvar = 'ACME'
                                          and p1.polval = 'IPHONE-TRBFND'
                                          and p1.rtnum1 = 1
                                          and p1.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
                                          and p1.uc_client_id = nvl(@prt_client_id, '----')) then rh.trbfnd
                    else 'other'
               end) trbfnd,
              (case when rh.trbfnd in (select p1.rtstr1
                                         from usr_poldat_view p1
                                        where p1.polcod = 'USR-REPORTS'
                                          and p1.polvar = 'ACME'
                                          and p1.polval = 'IPHONE-TRBFND'
                                          and p1.rtnum1 = 1
                                          and p1.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
                                          and p1.uc_client_id = nvl(@prt_client_id, '----')) then dm1.lngdsc
                    else 'other'
               end) trbfnd_dsc
         from dscmst dm2,
              dscmst dm1,
              usr_poldat_view p,
              usr_rephdr rh,
              prtmst_view pm
        where dm2.colnam(+) = 'uc_repsts'
          and dm2.colval(+) = rh.uc_repsts
          and dm2.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
          and dm1.colnam(+) = 'trbfnd'
          and dm1.colval(+) = rh.trbfnd
          and dm1.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
          and p.polcod = 'USR-TEST-REPAIR'
          and p.polvar = rh.uc_repprv
          and p.polval = 'FINAL-REPSTS'
          and p.uc_client_id = rh.prt_client_id
          and p.rtstr1 = rh.uc_repsts
          and p.wh_id = pm.wh_id
          and rh.prtnum = pm.prtnum
          and rh.prt_client_id = pm.prt_client_id
          and upper(pm.typcod) like '%IPHONE%'
          and pm.wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
          and (rh.repdte between @flddte:raw)
          and @+pm.prt_client_id
        order by trunc(rh.repdte),
              rh.uc_repprv,
              rh.prt_client_id,
              rh.prtnum,
              rh.uc_repsts,
              rh.fifdte,
              rh.dtlnum]]
     |
     list usr prod then arch
      where cmd =
     [
      [select mod_usr_id
         from (select urh1.mod_usr_id
                 from usr_rephdr urh1
                where urh1.prtnum = @prtnum
                  and urh1.prt_client_id = @prt_client_id
                  and urh1.dtlnum = @dtlnum
                  and urh1.fifdte = @fifdte
                  and urh1.uc_repprv = @uc_repprv
                  and urh1.repdte between @flddte:raw
                order by urh1.repdte desc)
        where rownum < 2]] catch(-1403)
     |
     publish data
      where repdte = @repdte
        and uc_repprv = @uc_repprv
        and prt_client_id = @prt_client_id
        and prtnum = @prtnum
        and trbfnd = @trbfnd
        and trbfnd_dsc = @trbfnd_dsc
        and uc_repsts = @uc_repsts
        and lngdsc = @lngdsc
        and fifdte = @fifdte
        and dtlnum = @dtlnum
        and flshrst = @flshrst
        and rftest = @rftest
        and functst = @functst
        and comment1 = @comment1
        and comment2 = @comment2
        and check_out = @mod_usr_id]
}
else if (@rpt_id = 43)
{
    /* Daily Receiving Summary for Apple iPhone Matrix
     *  wh_id - Warehouse ID (Required)
     *  begdte  - begin date (Required)
     *  enddte - end date (Required)
     */
    publish data
     where frstol = nvl(@frstol, 'PERM-CRE-LOC')
    |
    list usr prod with arch
     where cmd =
    [
     [select trunc(dt.trndte) trndte,
             dt.prtnum,
             dt.prt_client_id,
             count(*) received_qty
        from dlytrn dt,
             prtmst pm
       where (dt.frstol = @frstol and dt.tostol = dt.vc_invnum)
         and (dt.trndte >= @begdte:date and dt.trndte < @enddte:date)
         and dt.prtnum = pm.prtnum
         and dt.prt_client_id = pm.prt_client_id
         and upper(pm.typcod) like '%IPHONE%'
         and pm.wh_id_tmpl = nvl(@wh_id, nvl(@@wh_id, '----'))
       group by trunc(dt.trndte),
             dt.prtnum,
             dt.prt_client_id
       order by trunc(dt.trndte),
             dt.prtnum,
             dt.prt_client_id]]
}
else if (@rpt_id = 44)
{
    /* Daily Shipment Summary for Apple iPhone Matrix
     *  wh_id - Warehouse ID (Required)
     *  begdte  - begin date (Required)
     *  enddte - end date (Required)
     */
    list usr prod with arch
     where cmd =
    [
     [select trunc(s.loddte) loddte,
             pm.prtnum,
             pm.prt_client_id,
             o.ordtyp,
             o.stcust,
             sum(sl.shpqty) ship_qty
        from prtmst pm,
             ord_line ol,
             ord o,
             shipment_line sl,
             shipment s
       where s.wh_id = sl.wh_id
         and s.ship_id = sl.ship_id
         and s.shpsts = 'C'
         and (s.loddte >= @begdte:date)
         and (s.loddte < @enddte:date)
         and ol.ordnum = sl.ordnum
         and ol.ordsln = sl.ordsln
         and ol.client_id = sl.client_id
         and ol.ordlin = sl.ordlin
         and ol.wh_id = sl.wh_id
         and o.ordnum = ol.ordnum
         and o.client_id = ol.client_id
         and o.wh_id = ol.wh_id
         and ol.prtnum = pm.prtnum
         and pm.wh_id_tmpl = ol.wh_id
         and ol.prt_client_id = pm.prt_client_id
         and upper(pm.typcod) like '%IPHONE%'
         and pm.wh_id_tmpl = nvl(@wh_id, nvl(@@wh_id, '----'))
       group by trunc(s.loddte),
             pm.prtnum,
             pm.prt_client_id,
             o.stcust,
             o.ordtyp]]
}
else if (@rpt_id = 45)
{
    /* Inventory Summary in remote server for Apple iPhone Matrix
     *  wh_id - Warehouse ID (Required)
     *  txtServerName - Remote Server Name. Ex.: CPROD, CAPEPROD (Required)
     */
    [select rtstr2 rprd_rmt_host,
            rtnum2 rprd_rmt_port
       from poldat_view
      where polcod = 'USR-REMOTE-HOST'
        and polvar = 'PRODUCTION-INSTANCES'
        and polval = 'SERVER-NAMES'
        and wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))
        and rtstr1 = @txtServerName]
    |
    /* Count of inventory from CAPEPRD */
    remote(@rprd_rmt_host || ':' || @rprd_rmt_port)
    list usr prod then arch
     where cmd =
    [
     [select id.prtnum,
             id.prt_client_id,
             sum(id.untqty) Remote_server_qty
        from invdtl id,
             invsub sb,
             invlod ld,
             prtmst pm
       where upper(pm.typcod) like '%IPHONE%'
         and pm.wh_id_tmpl = nvl(@wh_id, nvl(@@wh_id, '----'))
         and id.prtnum = pm.prtnum
         and id.prt_client_id = pm.prt_client_id
         and id.ship_line_id is not null
         and id.subnum = sb.subnum
         and sb.lodnum = ld.lodnum
         and ld.wh_id = pm.wh_id_tmpl
       group by id.prtnum,
             id.prt_client_id]] catch(510)
    |
    publish data
     where prtnum = @prtnum
       and prt_client_id = @prt_client_id
       and Remote_server = @txtServerName
       and Remote_server_qty = @Remote_server_qty
}
else if (@rpt_id = 46)
{
    /* Liquidations INSDMG Pass/Fail Report*
     * begdte:(reqiure)
     * enddte:(reqiure)
     * prt_client_id:(reqiure) */
    publish data
     where uc_repprv = nvl(@uc_repprv, "('5','8')")
    |
    execute usr sql
     where sqlcmd =
    [list usr prod with arch
      where cmd =
     [
      [select to_char(trunc(urh.repdte), 'MM/DD/RRRR') repdte,
              urh.uc_repprv,
              nvl(dm2.lngdsc, urh.uc_repsts) uc_repsts,
              urh.retcod,
              dh.make,
              dh.model,
              urh.prtnum,
              urh.prt_client_id,
              count(1) phones,
              dm1.lngdsc org_invsts
         from dscmst dm2,
              dscmst dm1,
              usr_dvlhdr dh,
              usr_poldat_view p,
              usr_rephdr urh
        where dm2.colnam(+) = 'uc_repsts'
          and dm2.colval(+) = urh.uc_repsts
          and dm2.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
          and dm1.colnam(+) = 'invsts'
          and dm1.colval(+) = urh.org_invsts
          and dm1.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
          and dh.prt_client_id = urh.prt_client_id
          and dh.prtnum = urh.prtnum
          and p.polcod(+) = 'USR-TEST-REPAIR'
          and p.polvar(+) = urh.uc_repprv
          and p.polval(+) = 'FINAL-REPSTS'
          and p.wh_id(+) = nvl(@wh_id, nvl(@@wh_id, '----'))
          and p.uc_client_id(+) = urh.prt_client_id
          and p.rtstr1(+) = urh.uc_repsts
          and (urh.repdte between @flddte:raw)
          and urh.uc_repprv in @uc_repprv:raw
          and @+dh.make
          and @+dh.model
          and @+urh.prtnum
          and @+urh.prt_client_id
        group by trunc(urh.repdte),
              urh.uc_repprv,
              dm1.lngdsc,
              urh.retcod,
              dh.make,
              dh.model,
              nvl(dm2.lngdsc, urh.uc_repsts),
              urh.prtnum,
              urh.prt_client_id]]]
}
else if (@rpt_id = 47)
{
    /* DLC Query
       Inputs: arecod required
       stoloc optional
       dtlnum optional */
    check usr component arguments
     where collst = 'arecod'
    |
    execute usr sql
     where show_header = '1'
       and sqlcmd =
    [list inventory
     |
     list usr prod with arch
      where cmd =
     [
      [select dt.dtlnum,
              dt.trndte rcvdte,
              oprcod,
              dt.prt_client_id,
              dt.prtnum,
              dt.movref,
              dt.trnqty,
              dt.frstol,
              dt.tostol,
              dt.toinvs,
              dt.vc_invnum,
              dt.usr_id,
              trunc(dt.trndte) trndte2,
              dt.vc_invnum rmanum,
              'U30' rmatyp,
              dt.frinvs rettyp,
              dh.model,
              dh.make,
              reacod
         from dlytrn dt,
              usr_dvlhdr dh
        where dt.frstol || '' in ('PERM-CRE-LOC', 'PERM-ADJ-LOC')
          and dt.dtlnum = @dtlnum
          and (movref = 'RMA-WORK' or dt.vc_invnum is not null)
          and dt.prtnum = dh.prtnum
          and dt.prt_client_id = dh.prt_client_id] catch(-1403)] catch(510)
     |
     list usr prod with arch
      where cmd =
     [
      [select dtlnum,
              rmanum,
              rmatyp,
              rettyp,
              rcvdte,
              warsts,
              warrid,
              mfgdte,
              custno,
              adddte
         from usr_wir uw
        where uw.dtlnum = @dtlnum
          and rcvdte >= @trndte2:date -1
          and rcvdte < @trndte2:date + 1]] catch(@?)
     |
     publish data
      where dtlnum = @dtlnum
        and rmanum = @rmanum
        and rmatyp = @rmatyp
        and make = @make
        and model = @model
        and prtnum = @prtnum
        and rettyp = @rettyp
        and rcvdte = to_char(@rcvdte, 'MM/DD/YYYY')
        and warsts = @warsts
        and warrid = @warrid
        and mfgdte = to_char(@mfgdte, 'MM/DD/YYYY')
        and custno = @custno
        and adddte = to_char(@adddte, 'MM/DD/YYYY')
        and stoloc = @stoloc
        and lodnum = @lodnum
        and reacod = @reacod]
}
else if (@rpt_id = 48)
{
    /* XBM Reship Adjustment Report */
    publish data
     where prt_client_id = nvl(@prt_client_id, "('RLO','CNG')")
       and tostol_adj = nvl(@tostol_adj, 'PERM-ADJ-LOC')
       and movref = nvl(@movref, 'XBM')
       and reacod = nvl(@reacod, 'DAMAGED')
       and sales_channel = nvl(@sales_channel, "('DF_X')")
       and rmatyp = nvl(@rmatyp, "('DFX', 'DFXR')")
    |
    execute usr sql
     where sqlcmd =
    [
     [select d.prt_client_id,
             max(d.trndte) trndte,
             wr.rcvdte,
             d.reacod,
             d.ordnum,
             d.dtlnum,
             d.prtnum,
             (select lngdsc
                from dscmst
               where colnam = 'xbm_rejection_code'
                 and colval = upper(wr.xbm_rejcod)
                 and locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))) xbm_rejcod
        from usr_wir wr,
             dlytrn d
       where d.dtlnum = wr.dtlnum
         and d.prtnum = wr.prtnum
         and d.prt_client_id = wr.prt_client_id
         and d.ordnum = wr.rmanum
         and d.movref = @movref
         and d.reacod = @reacod
         and d.tostol = @tostol_adj
         and d.trndte between @flddte:raw
         and d.prt_client_id in @prt_client_id:raw
       group by d.prt_client_id,
             wr.rcvdte,
             d.reacod,
             d.ordnum,
             d.dtlnum,
             d.prtnum,
             wr.xbm_rejcod
       order by rcvdte] catch(-1403) &
     [select ra.prt_client_id,
             ra.rcvdte trndte,
             ra.rcvdte,
             ra.ordnum,
             ra.dtlnum,
             ra.prtnum,
             (select lngdsc
                from dscmst
               where colnam = 'xbm_rejection_code'
                 and colval = upper(ra.reshrjncod)
                 and locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))) xbm_rejcod
        from usr_rmaact ra
       where ra.rcvqty = 0
         and ra.reship_traknm is not null
         and ra.sales_channel in @sales_channel:raw
         and ra.rmatyp in @rmatyp:raw
         and ra.prt_client_id in @prt_client_id:raw
         and ra.rcvdte between @flddte:raw]]
}
else if (@rpt_id = 49)
{
    /* LG Orders and Pieces Dropped*/
    list usr prod with arch
     where cmd =
    [execute usr sql
      where sqlcmd =
     [
      [select to_char(s.adddte, 'MM-DD-YYYY') adddte,
              count(distinct o.ordnum) totord,
              sum(ol.ordqty) tot_ordqty
         from ord o,
              ord_line ol,
              shipment_line sl,
              shipment s
        where o.client_id = @client_id
          and o.ordnum = ol.ordnum
          and o.wh_id = ol.wh_id
          and o.client_id = ol.client_id
          and ol.ordsln = sl.ordsln
          and ol.ordlin = sl.ordlin
          and ol.ordnum = sl.ordnum
          and ol.wh_id = sl.wh_id
          and ol.client_id = sl.client_id
          and sl.ship_id = s.ship_id
          and sl.wh_id = s.wh_id
          and s.loddte between @flddte:raw
        group by to_char(s.adddte, 'MM-DD-YYYY')]]]
}