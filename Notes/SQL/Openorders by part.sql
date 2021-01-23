[select ordnum,
        ordlin,
        prtnum,
        dstloc,
        host_ordqty,
        ordqty,
        shpqty
   from ord_line
  where ordnum in ('55879306', '55784261', '55779555', '55776394', '55766827', '55755245', '55755240', '55744575', '55739344', '55734217', '55313617', '55346854')]