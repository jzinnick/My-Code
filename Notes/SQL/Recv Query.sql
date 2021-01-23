[select rcvinv.*,
        rcvlin.rcvqty,
        rcvlin.expqty
   from rcvinv,
        rcvlin
  where (invdte between to_date(20141201) and to_date(20141231))
    and rcvinv.invnum = rcvlin.invnum]