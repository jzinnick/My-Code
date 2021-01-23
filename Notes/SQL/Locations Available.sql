[select stoloc,
        arecod,
        loclen,
        locwid,
        lochgt,
        maxqvl,
        curqvl
   from locmst
  where wh_id = 'WMD1'
    and arecod = 'LB01'
     or arecod = 'LB02'
     or arecod = 'BULK'
     or arecod = 'RA01'
     or arecod = 'EP01'
     or arecod = 'EP02'
     or arecod = 'HZ02']