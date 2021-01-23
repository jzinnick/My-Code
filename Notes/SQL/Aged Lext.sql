list inventory summarized by location for display
 WHERE adjflg = '0'
   AND wh_id = 'WMD1'
   AND fwiflg = '1'
   AND find_matching_kits = '0'

[select prtnum,
        sum(trnqty)
   from dlytrn
  where actcod = 'TRLR_LOAD'
    and trndte between to_date('20171201000000')
    and to_date('20180401235959')
  group by prtnum]