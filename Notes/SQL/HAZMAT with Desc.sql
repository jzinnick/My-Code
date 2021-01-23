[select invloc.arecod,
        invloc.prtnum,
        invloc.stoloc,
        invloc.untqty,
        invloc.comqty,
        prtmst.hazmat_flg,
        prtdsc.lngdsc
   from invloc,
        prtmst
   join prtdsc
     on (prtdsc.colval = prtmst.prtnum || '|GRPN|WMD1')
  where (invloc.prtnum = prtmst.prtnum)
    and prtmst.hazmat_flg = '1'
    and invloc.untqty > '1']