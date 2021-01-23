[select invloc.arecod,
        invloc.prtnum,
        invloc.stoloc,
        invloc.untqty,
        invloc.comqty,
        prtmst.hazmat_flg
   from invloc,
        prtmst
  where (invloc.prtnum = prtmst.prtnum)
    and prtmst.hazmat_flg = '1'
    and invloc.untqty > '1']