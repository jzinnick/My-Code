[select sum(untqty)
   from inventory_view
  where stoloc like 'L%'
    and lst_arecod = 'LBRY']
[select sum(untqty)
   from inventory_view
  where lst_arecod = 'MA01']
[select count(prtnum)
   from inventory_view
  where lst_arecod = 'MA01']
[select count(prtnum)
   from inventory_view
  where stoloc like '102%'
    and lst_arecod = 'LBRY']