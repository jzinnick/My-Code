prtfam =  'EXPIRY' 


[select bldg_mst.wh_id,
        aremst.bldg_id,
        aremst.arecod,
        locmst.stoloc,
        max(decode(invdtl.ship_line_id, null, 0, 1)) picked_flg,
        decode(max(invdtl.prtnum), min(invdtl.prtnum), max(invdtl.prtnum), @mixed_item) prtnum,
        decode(max(invdtl.prtnum), min(invdtl.prtnum), max(prtdsc.lngdsc), '') lngdsc,
        decode(count(distinct invdtl.prt_client_id), 1, min(invdtl.prt_client_id), 0, '', @MANY_VALUES) prt_client_id,
        decode(count(distinct invdtl.invsts), 1, min(invdtl.invsts), 0, '', @MANY_VALUES) invsts,
        sum(invdtl.untqty) untqty,
        decode(count(distinct invdtl.lotnum), 1, min(invdtl.lotnum), 0, '', @MANY_VALUES) lotnum,
        decode(count(distinct invdtl.sup_lotnum), 1, min(invdtl.sup_lotnum), 0, '', @MANY_VALUES) sup_lotnum,
        decode(count(distinct invdtl.revlvl), 1, min(invdtl.revlvl), 0, '', @MANY_VALUES) revlvl,
        decode(count(distinct invdtl.orgcod), 1, min(invdtl.orgcod), 0, '', @MANY_VALUES) orgcod,
        decode(count(distinct invdtl.supnum), 1, min(invdtl.supnum), 0, '', @MANY_VALUES) supnum,
        decode(count(distinct to_char(invdtl.fifdte,'YYYYMMDD')), 1, to_char(min(invdtl.fifdte),'MM/DD/YYYY HH24:MI:SS'), 0, '', @MANY_VALUES) fifdte,
        decode(count(distinct to_char(invdtl.mandte,'YYYYMMDD')), 1, to_char(min(invdtl.mandte),'MM/DD/YYYY HH24:MI:SS'), 0, '', @MANY_VALUES) mandte,
        decode(count(distinct invdtl.rcvdte), 1, to_char(min(invdtl.rcvdte),'MM/DD/YYYY HH24:MI:SS'), 0, '', @MANY_VALUES) rcvdte,
        decode(count(distinct to_char(invdtl.expire_dte,'YYYYMMDD')), 1, to_char(min(invdtl.expire_dte),'MM/DD/YYYY HH24:MI:SS'), 0, '', @MANY_VALUES) expire_dte,
        decode(count(distinct invlod.asset_typ), 1, min(invlod.asset_typ), 0, '', @MANY_VALUES) asset_typ,
        decode(count(distinct invlod.load_attr1_flg), 1, min(invlod.load_attr1_flg), NULL) load_attr1_flg,
        decode(count(distinct invlod.load_attr2_flg), 1, min(invlod.load_attr2_flg), NULL) load_attr2_flg,
        decode(count(distinct invlod.load_attr3_flg), 1, min(invlod.load_attr3_flg), NULL) load_attr3_flg,
        decode(count(distinct invlod.load_attr4_flg), 1, min(invlod.load_attr4_flg), NULL) load_attr4_flg,
        decode(count(distinct invlod.load_attr5_flg), 1, min(invlod.load_attr5_flg), NULL) load_attr5_flg,
        decode(count(distinct invdtl.inv_attr_str1), 
               1, min(invdtl.inv_attr_str1), 
               0, '', 
               @MANY_VALUES) inv_attr_str1,
        decode(count(distinct invdtl.inv_attr_str2),
               1, min(invdtl.inv_attr_str2), 
               0, '', 
               @MANY_VALUES) inv_attr_str2,
        decode(count(distinct invdtl.inv_attr_str3),
               1, min(invdtl.inv_attr_str3), 
               0, '', 
               @MANY_VALUES) inv_attr_str3,
        decode(count(distinct invdtl.inv_attr_str4),
               1, min(invdtl.inv_attr_str4), 
               0, '', 
               @MANY_VALUES) inv_attr_str4,
        decode(count(distinct invdtl.inv_attr_str5),
               1, min(invdtl.inv_attr_str5), 
               0, '', 
               @MANY_VALUES) inv_attr_str5,
        decode(count(distinct invdtl.inv_attr_str6),
               1, min(invdtl.inv_attr_str6), 
               0, '', 
               @MANY_VALUES) inv_attr_str6,
        decode(count(distinct invdtl.inv_attr_str7),
               1, min(invdtl.inv_attr_str7), 
               0, '', 
               @MANY_VALUES) inv_attr_str7,
        decode(count(distinct invdtl.inv_attr_str8),
               1, min(invdtl.inv_attr_str8), 
               0, '', 
               @MANY_VALUES) inv_attr_str8,
        decode(count(distinct invdtl.inv_attr_str9),
               1, min(invdtl.inv_attr_str9), 
               0, '', 
               @MANY_VALUES) inv_attr_str9,
        decode(count(distinct invdtl.inv_attr_str10),
               1, min(invdtl.inv_attr_str10), 
               0, '', 
               @MANY_VALUES) inv_attr_str10,
        decode(count(distinct invdtl.inv_attr_str11), 
               1, min(invdtl.inv_attr_str11), 
               0, '', 
               @MANY_VALUES) inv_attr_str11,
        decode(count(distinct invdtl.inv_attr_str12),
               1, min(invdtl.inv_attr_str12), 
               0, '', 
               @MANY_VALUES) inv_attr_str12,
        decode(count(distinct invdtl.inv_attr_str13),
               1, min(invdtl.inv_attr_str13), 
               0, '', 
               @MANY_VALUES) inv_attr_str13,
        decode(count(distinct invdtl.inv_attr_str14),
               1, min(invdtl.inv_attr_str14), 
               0, '', 
               @MANY_VALUES) inv_attr_str14,
        decode(count(distinct invdtl.inv_attr_str15),
               1, min(invdtl.inv_attr_str15), 
               0, '', 
               @MANY_VALUES) inv_attr_str15,
        decode(count(distinct invdtl.inv_attr_str16),
               1, min(invdtl.inv_attr_str16), 
               0, '', 
               @MANY_VALUES) inv_attr_str16,
        decode(count(distinct invdtl.inv_attr_str17),
               1, min(invdtl.inv_attr_str17), 
               0, '', 
               @MANY_VALUES) inv_attr_str17,
        decode(count(distinct invdtl.inv_attr_str18),
               1, min(invdtl.inv_attr_str18), 
               0, '', 
               @MANY_VALUES) inv_attr_str18,
        decode(count(distinct invdtl.inv_attr_int1),
               1, min(invdtl.inv_attr_int1), 
               0, '', 
               cast(null as int)) inv_attr_int1,
        decode(count(distinct invdtl.inv_attr_int2),
               1, min(invdtl.inv_attr_int2), 
               0, '', 
               cast(null as int)) inv_attr_int2,
        decode(count(distinct invdtl.inv_attr_int3),
               1, min(inv_attr_int3), 
               0, '', 
               cast(null as int)) inv_attr_int3,
        decode(count(distinct invdtl.inv_attr_int4),
               1, min(invdtl.inv_attr_int4), 
               0, '', 
               cast(null as int)) inv_attr_int4,
        decode(count(distinct invdtl.inv_attr_int5),
              1, min(invdtl.inv_attr_int5), 
               0, '', 
               cast(null as int)) inv_attr_int5,
        decode(count(distinct invdtl.inv_attr_flt1),
               1, min(invdtl.inv_attr_flt1), 
               0, '', 
               cast(null as float)) inv_attr_flt1,
        decode(count(distinct invdtl.inv_attr_flt2),
               1, min(invdtl.inv_attr_flt2), 
               0, '', 
               cast(null as float)) inv_attr_flt2,
        decode(count(distinct invdtl.inv_attr_flt3),
               1, min(invdtl.inv_attr_flt3), 
               0, '', 
               cast(null as float)) inv_attr_flt3,
        decode(count(distinct invdtl.inv_attr_dte1),
               1, 
               min(to_char(invdtl.inv_attr_dte1)), 
               0, '', 
               @MANY_VALUES) inv_attr_dte1,
        decode(count(distinct invdtl.inv_attr_dte2),
               1, 
               min(to_char(invdtl.inv_attr_dte2)),  
               0, '', 
               @MANY_VALUES) inv_attr_dte2,
        max(invdtl.hld_flg) hld_flg,
        invsum.pndqty,
        invsum.comqty,
        locmst.maxqvl,
        locmst.curqvl,
        locmst.pndqvl,
        aremst.loccod,
        locmst.useflg,
        locmst.pckflg,
        locmst.cipflg,
        locmst.locsts,
        decode(prtmst_view.dspuom, null, sum(invdtl.untqty),
        nvl(sum(invdtl.untqty), 0)/prtftp_dtl.untqty) dsp_untqty,
        decode(prtmst_view.dspuom, null, prtmst_view.stkuom,
        prtmst_view.dspuom) untqty_uom,
        decode(prtmst_view.dspuom, null, cast(null as int), 
        prtmst_view.stkuom, cast(null as int),
        mod(sum(invdtl.untqty), prtftp_dtl.untqty)) rem_untqty,
        decode(prtmst_view.dspuom, null, null,
        prtmst_view.stkuom, null,
        prtmst_view.stkuom) rem_untqty_uom,
        invdtl.cstms_cnsgnmnt_id,
        invdtl.rttn_id,
        invdtl.dty_stmp_flg,
        invdtl.cstms_bond_flg
   from prtftp,
        prtftp_dtl,
        aremst
   join bldg_mst
     on (aremst.bldg_id = bldg_mst.bldg_id)
    and (aremst.wh_id = bldg_mst.wh_id)
   join locmst
     on (aremst.arecod = locmst.arecod)
    and (aremst.wh_id  = locmst.wh_id)
    and @+locmst.stoloc
    and @+locmst.wh_id
    and @+locmst.cntdte:date
    and @+locmst.lstdte:date
    and @+locmst.velzon
    and @+locmst.abccod
    and @+aremst.arecod
    and @+aremst.bldg_id
    and @+aremst.adjflg    
   join invlod
     on invlod.stoloc = locmst.stoloc
    and invlod.wh_id = locmst.wh_id
    and @+invlod.lodnum
    and @+invlod.lodtag
    and @+invlod.loducc
    and @+invlod.asset_typ
    and @+invlod.avg_unt_catch_qty
    and @+invlod.stoloc
    and @+invlod.wh_id    
    and @+invlod.adddte:date
    and @+invlod.lstdte:date
    and @+invlod.uccdte:date    
   join invsub
     on invlod.lodnum = invsub.lodnum    
    and @+invsub.subnum
    and @+invsub.subtag
    and @+invsub.subucc
    and @+invsub.phyflg     
    and @+invsub.adddte:date
    and @+invsub.lstdte:date
    and @+invsub.uccdte:date    
   join invdtl
     on (invdtl.subnum = invsub.subnum)
    and @+invdtl.prtnum
    and @+invdtl.prt_client_id
    and @+invdtl.dtlnum
    and @+invdtl.prtnum
    and @+invdtl.prt_client_id
    and @+invdtl.supnum
    and @+invdtl.fifdte:date
    and @+invdtl.mandte:date
    and @+invdtl.adddte:date
    and @+invdtl.lstdte:date    
    and @+invdtl.rcvkey
    and @+invdtl.ship_line_id
    and @+invdtl.cmpkey
    and @+invdtl.age_pflnam
    and @+invdtl.ftpcod
    and @+invdtl.phdflg
    and @+invdtl.orgcod
    and @+invdtl.lotnum
    and @+invdtl.sup_lotnum
    and @+invdtl.revlvl
    and @+invdtl.invsts
    and @+invdtl.supnum
    and @+invdtl.cnsg_flg
    and @+invdtl.hld_flg
    and @+invdtl.untpak
    and @+invdtl.untcas
    and @+invdtl.untqty
    and @+invdtl.catch_qty
    and @+invdtl.expire_dte:date
    and @+invdtl.rcvdte:date
    and @+invdtl.bill_through_dte:date
    and @+invdtl.inv_attr_str1
    and @+invdtl.inv_attr_str2
    and @+invdtl.inv_attr_str3
    and @+invdtl.inv_attr_str4
    and @+invdtl.inv_attr_str5
    and @+invdtl.inv_attr_str6
    and @+invdtl.inv_attr_str7
    and @+invdtl.inv_attr_str8
    and @+invdtl.inv_attr_str9
    and @+invdtl.inv_attr_str10
    and @+invdtl.inv_attr_str11
    and @+invdtl.inv_attr_str12
    and @+invdtl.inv_attr_str13
    and @+invdtl.inv_attr_str14
    and @+invdtl.inv_attr_str15
    and @+invdtl.inv_attr_str16
    and @+invdtl.inv_attr_str17
    and @+invdtl.inv_attr_str18
    and @+invdtl.inv_attr_int1
    and @+invdtl.inv_attr_int2
    and @+invdtl.inv_attr_int3
    and @+invdtl.inv_attr_int4
    and @+invdtl.inv_attr_int5
    and @+invdtl.inv_attr_flt1
    and @+invdtl.inv_attr_flt2
    and @+invdtl.inv_attr_flt3
    and @+invdtl.inv_attr_dte1:date
    and @+invdtl.inv_attr_dte2:date
    and @+invdtl.cstms_cnsgnmnt_id
    and @+invdtl.rttn_id
    and @+invdtl.dty_stmp_flg
    and @+invdtl.cstms_bond_flg
       and decode(invdtl.ship_line_id, null,0, 1) = 
            decode(@picked_flg, null,decode(invdtl.ship_line_id, null,0, 1), @picked_flg)
    and (@days_to_expire is null
         or invdtl.expire_dte is null
         or nvl(round(moca_util.date_diff_days(sysdate, invdtl.expire_dte)),
            nvl(cast(@days_to_expire as int),
            1)+1)
      = nvl(cast(@days_to_expire as int),
            nvl(round(moca_util.date_diff_days(sysdate, invdtl.expire_dte)),
            nvl(cast(@days_to_expire as int), 
            1)+1
        )))
    and (@min_days_to_expire is null
         or invdtl.expire_dte is null
         or nvl(round(moca_util.date_diff_days(sysdate, invdtl.expire_dte)),
            nvl(cast(@min_days_to_expire as int),
            1)-1)
     >= nvl(cast(@min_days_to_expire as int),
            nvl(round(moca_util.date_diff_days(sysdate, invdtl.expire_dte)),
            nvl(cast(@min_days_to_expire as int),
            1)-1
        )))
    and (@max_days_to_expire is null
         or invdtl.expire_dte is null
         or nvl(round(moca_util.date_diff_days(sysdate, invdtl.expire_dte)),
            nvl(cast(@max_days_to_expire as int),
            1)+1)
     <= nvl(cast(@max_days_to_expire as int),
            nvl(round(moca_util.date_diff_days(sysdate, invdtl.expire_dte)),
            nvl(cast(@max_days_to_expire as int),
            1)+1
        )))    
    and invdtl.prtnum != 'RETURNPART'
   left outer join inv_ser_num
     on ((inv_ser_num.invtid = invlod.lodnum 
         and inv_ser_num.ser_lvl = 'L')
     or (inv_ser_num.invtid = invsub.subnum 
         and inv_ser_num.ser_lvl = 'S')
     or (inv_ser_num.invtid = invdtl.dtlnum 
         and inv_ser_num.ser_lvl = 'D'))    
    /* This select is neccessary for not duplicate the quantity for the 
     * location, if the location contains inventory with multiple 
     * serial numbers.
     */   
         and not exists(select 'x'
                     from inv_ser_num isn
                    where isn.invtid = inv_ser_num.invtid
                      and isn.ser_num_typ_id > inv_ser_num.ser_num_typ_id)
    left outer join manfst
      on (invdtl.subnum = manfst.subnum)
      or (invdtl.wrkref = manfst.wrkref)
    /* The join invdtl.invsts = invsum.invsts has been removed 
     * here, since we need to show the committed quantity 
     * for the location, if the location contains similar inventory
     * with multiple invsts.
     */
    left outer join invsum
     on (invlod.wh_id = invsum.wh_id)
    and (locmst.arecod = invsum.arecod) 
    and (locmst.stoloc = invsum.stoloc)
    and (invdtl.prtnum = invsum.prtnum)
    and (invdtl.prt_client_id = invsum.prt_client_id)
   left outer join prtmst_view
     on (locmst.wh_id = prtmst_view.wh_id )
    and (invdtl.prtnum = prtmst_view.prtnum)
    and (invdtl.prt_client_id = prtmst_view.prt_client_id)
   left outer join prtdsc
     on (prtdsc.colval = /*=varchar(*/prtmst_view.prtnum||'|'||prtmst_view.prt_client_id||'|'||prtmst_view.wh_id_tmpl) /*=)*/
    and prtdsc.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
    and prtdsc.locale_id = nvl(@locale_id, @@locale_id)
   left outer join asset_link parent_asset_link
     on (parent_asset_link.asset_num = invlod.lodnum) 
   left outer join asset_typ parent_asset_typ
     on (parent_asset_typ.asset_typ = invlod.asset_typ)
   left outer join asset_typ child_asset_typ
     on (invsub.asset_typ = child_asset_typ.asset_typ)
  where @client_in_clause:raw
    and prtmst_view.wh_id  = prtftp.wh_id
    and prtmst_view.prtnum = prtftp.prtnum
    and prtmst_view.prt_client_id = prtftp.prt_client_id
    and invdtl.ftpcod = prtftp.ftpcod
    and prtftp.wh_id = prtftp_dtl.wh_id
    and prtftp.prtnum = prtftp_dtl.prtnum
    and prtftp.prt_client_id = prtftp_dtl.prt_client_id
    and prtftp.ftpcod = prtftp_dtl.ftpcod
    and prtftp_dtl.uomcod = nvl(prtmst_view.dspuom, prtmst_view.stkuom)
    and @+inv_ser_num.ser_lvl
    and @+inv_ser_num.ser_num
    and @+manfst.traknm
    and @+parent_asset_link.asset_id^parent_asset_id
    and @+parent_asset_typ.asset_typ^parent_asset_typ
    and @*
  group by bldg_mst.wh_id,
           aremst.bldg_id,
           aremst.arecod,
           locmst.stoloc,
           invdtl.ship_line_id,
           invsum.pndqty,
           invsum.comqty,
           locmst.maxqvl,
           locmst.curqvl,
           locmst.pndqvl,
           aremst.loccod,
           locmst.useflg,
           locmst.pckflg,
           locmst.cipflg,
           locmst.locsts,
           prtmst_view.dspuom,
           prtftp_dtl.untqty,
           prtmst_view.stkuom,
           invsum.prtnum, 
           prtdsc.lngdsc,
           invdtl.invsts, 
           invsum.untqty,
           invdtl.cstms_cnsgnmnt_id,
           invdtl.rttn_id,
           invdtl.dty_stmp_flg,
           invdtl.cstms_bond_flg
  order by aremst.bldg_id,
           aremst.arecod,
           locmst.stoloc,
           invsum.prtnum,
           prtdsc.lngdsc,
           invdtl.invsts,
           invsum.untqty,
           invsum.pndqty,
           invsum.comqty,
           locmst.maxqvl,
           locmst.curqvl,
           locmst.pndqvl,
           locmst.useflg,
           locmst.pckflg,
           locmst.locsts,
           locmst.cipflg] catch (-1403)