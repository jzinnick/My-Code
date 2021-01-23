[select ordnum,
        traknm,
        carcod,
        srvlvl,
        shpdte
   from manfst
  where shpdte between to_date('201406300000')
    and to_date('201407102359')
    and carcod = 'DHL']