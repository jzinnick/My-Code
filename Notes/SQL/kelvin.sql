[select *
   from shipment
  where ship_id = 'SID5468977'];
[select *
   from manfst
  where ship_id in ('SID5468977', 'SID5276423')];
[select *
   from dlytrn
  where subnum in ('CTN5321251', 'CTN5323296')
  order by 6,
        1];
       
        [update shipment
        set shpsts = 'C'
        where ship_id = 'SID5468977']
        [update manfst
        set mansts = 'M'
        where ship_id = 'SID5468977']
        
        [select *
   from invlod
  where lodnum in ('L00001943032', 'L00005701964') ]
 [select *
    from invlod
   where lodnum = 'L00001943032']
 [update invlod
     set stoloc = 'TRL6434900'
   where lodnum = 'L00005701964']