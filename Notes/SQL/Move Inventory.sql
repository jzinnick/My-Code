list inventory 
 where stoloc = 'RF31D8'
|
process inventory move
 where srclod = @lodnum
   and dstloc = 'PROBLISTPK'
   and wh_id = 'WMD1';