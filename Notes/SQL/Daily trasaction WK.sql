list daily transactions
 where wh_id = 'WMD1'
   and actcod = 'SSTG'
   and fr_arecod = 'RDTS'
   and to_arecod = 'FSTG'
   and trndte [between to_date('20160125000000' ) and to_date('20160129235959' )]