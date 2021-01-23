publish data
 where age_limit = nvl(@age_limit, 6)
   and exclude_prt_fam = nvl(@exclude_prt_fam, "('NONINV')")
|
execute usr sql
 where sqlcmd =
[
 [select t1.wh_id "Warehouse ID",
         t1.prt_client_id "Part Client ID",
         t1.prtnum "Part Number",
         t1.lngdsc "Part Description",
         t1.prtfam "Part Family",
         t1.untcst "Unit Cost",
         dm.lngdsc "Inventory Status",
         min(t1.lst_rcvdte) "1st Receiving Date",
         sum(t1.qty_on_hand) "Total Quantity",
         sum(t1.Total_Cost) "Total Cost",
         sum(decode(t1.aging_category, 'under_30', t1.qty_on_hand, 0)) "Quantity (0 - 30 days)",
         sum(decode(t1.aging_category, 'under_30', t1.Total_Cost, 0)) "Cost (0 - 30 days)",
		 sum(decode(t1.aging_category, '31_60', t1.qty_on_hand, 0)) "Quantity (31 - 60 days)",
         sum(decode(t1.aging_category, '31_60', t1.Total_Cost, 0)) "Cost (31 - 60 days)",
         sum(decode(t1.aging_category, '61_90', t1.qty_on_hand, 0)) "Quantity (61 - 90 days)",
         sum(decode(t1.aging_category, '61_90', t1.Total_Cost, 0)) "Cost (61 - 90 days)",
         sum(decode(t1.aging_category, '91_180', t1.qty_on_hand, 0)) "Quantity (91 - 180 days)",
         sum(decode(t1.aging_category, '91_180', t1.Total_Cost, 0)) "Cost (91 - 180 days)",
         sum(decode(t1.aging_category, '181_360', t1.qty_on_hand, 0)) "Quantity (181 - 360 days)",
         sum(decode(t1.aging_category, '181_360', t1.Total_Cost, 0)) "Cost (181 - 360 days)",
         sum(decode(t1.aging_category, 'over_360', t1.qty_on_hand, 0)) "Quantity (361 days +)",
         sum(decode(t1.aging_category, 'over_360', t1.Total_Cost, 0)) "Cost (361 days +)"
    from (select a.wh_id,
                 d.prt_client_id,
                 d.prtnum,
                 pd.lngdsc,
                 pm.prtfam,
                 pm.untcst,
                 pm.lodlvl,
                 d.invsts,
                 sum(d.untqty) qty_on_hand,
                 sum(d.untqty) *(pm.untcst) Total_Cost,
                 case when sysdate - d.fifdte < 30 then 'under_30'
                      when 30 <= sysdate - d.fifdte
                  and sysdate - d.fifdte < 60 then '31_60'
                      when 60 <= sysdate - d.fifdte
                  and sysdate - d.fifdte < 90 then '61_90'
				      when 90 <= sysdate - d.fifdte
                  and sysdate - d.fifdte < 180 then '91_180'
                      when 180 <= sysdate - d.fifdte
                  and sysdate - d.fifdte < 360 then '181_360'
                      else 'over_360'
                 end aging_category,
                 min(d.fifdte) lst_rcvdte
            from prtdsc pd,
                 prtmst_view pm,
                 locmst lm,
                 aremst a,
                 invlod l,
                 invsub s,
                 invdtl d
           where pd.colnam = 'prtnum|prt_client_id|wh_id_tmpl'
             and pd.colval = pm.prtnum || '|' || pm.prt_client_id || '|' || pm.wh_id
             and pd.locale_id = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
             and pm.prtnum = d.prtnum
             and pm.wh_id = nvl(@wh_id, '----')
             and pm.prt_client_id = d.prt_client_id
             and a.fwiflg = 1
             and a.shpflg = 0
             and a.arecod = lm.arecod
             and a.wh_id = lm.wh_id
             and lm.wh_id = l.wh_id
             and lm.stoloc = l.stoloc
             and l.lodnum = s.lodnum
             and s.subnum = d.subnum
             and pm.prtfam not in @exclude_prt_fam:raw
             and @+pm.lodlvl
             and @+d.prtnum
             and @+a.wh_id
             and d.prt_client_id = @prt_client_id
           group by a.wh_id,
                 d.prt_client_id,
                 d.prtnum,
                 d.invsts,
                 pd.lngdsc,
                 pm.prtfam,
                 pm.untcst,
                 pm.lodlvl,
                 case when sysdate - d.fifdte < 30 then 'under_30'
                      when 30 <= sysdate - d.fifdte
                  and sysdate - d.fifdte < 60 then '31_60'
                      when 60 <= sysdate - d.fifdte
                  and sysdate - d.fifdte < 90 then '61_90'
				      when 90 <= sysdate - d.fifdte
                  and sysdate - d.fifdte < 180 then '91_180'
                      when 180 <= sysdate - d.fifdte
                  and sysdate - d.fifdte < 360 then '181_360'
                      else 'over_360'
                 end
           order by prtnum) t1,
         dscmst dm
   where dm.colval(+) = t1.invsts
     and dm.colnam(+) = 'invsts'
     and dm.locale_id(+) = nvl(@locale_id, nvl(@@locale_id, 'US_ENGLISH'))
   group by t1.wh_id,
         t1.prt_client_id,
         t1.prtnum,
         t1.lngdsc,
         t1.prtfam,
         t1.untcst,
         dm.lngdsc
   order by t1.wh_id,
         t1.prt_client_id,
         t1.prtnum,
         t1.lngdsc,
         t1.prtfam,
         t1.untcst,
         dm.lngdsc]]