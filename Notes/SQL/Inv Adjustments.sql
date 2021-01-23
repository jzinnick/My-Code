[select dlytrn.trndte,
        dlytrn.oprcod,
        dlytrn.actcod,
        dlytrn.prtnum,
        dlytrn.reacod,
        dlytrn.usr_id,
        dlytrn.adj_ref1,
        dlytrn.adj_ref2,
        invact.adjqty
   from dlytrn
   left outer
   join invact
     on (dlytrn.movref = invact.sesnum)
    and (dlytrn.prtnum = invact.prtnum)
  where dlytrn.oprcod = 'INVADJ'
    and dlytrn.trndte between to_date('20181101000000')
    and to_date('20181130235959')]