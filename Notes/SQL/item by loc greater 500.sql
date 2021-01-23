  list inventory summarized by location for display
 WHERE adjflg = '0'
   AND stoloc like ('E%')
   AND wh_id = 'WMD1'
   AND fwiflg = '1'
   AND find_matching_kits = '0'
   AND untqty > 500