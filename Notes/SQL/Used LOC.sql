[select count(arecod),
        arecod
   from locmst
  where (arecod = 'BULK' or arecod = 'RA01' or arecod = 'RA02' or arecod = 'RA03' or arecod = 'LB02' or arecod = 'LB01' or arecod = 'HZ02')
    and (locsts = 'F' or locsts = 'P')
    and useflg = '1'
  group by arecod]