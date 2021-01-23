[select invsum.prtnum,
        invsum.stoloc,
        invsum.untqty,
        prtmst.untcst
   from invsum
   join prtmst
     on prtmst.prtnum = invsum.prtnum]