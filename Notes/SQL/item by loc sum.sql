[select sum(untqty),
    arecod
   from invloc
   where (arecod = 'BULK' or arecod = 'RA01' or arecod = 'RA02' or arecod = 'RA03' or arecod = 'LB02' or arecod = 'LB01' or arecod = 'HZ02')
    and untqty > 0
    group by arecod]