[select dlytrn.trndte,
        dlytrn.oprcod,
        dlytrn.actcod,
        dlytrn.prtnum,
        dlytrn.trnqty,
        dlytrn.fr_arecod,
        dlytrn.frstol,
        dlytrn.to_arecod,
        dlytrn.tostol,
        inv_sum_view.untqty
   from dlytrn,
        inv_sum_view
  where dlytrn.trndte between to_date('20180730000000')
    and to_date('20180731235959')
    and (dlytrn.actcod = 'PALPCK' or dlytrn.actcod = 'PCEPCK')
    and dlytrn.to_arecod = 'RDTS'
    and dlytrn.oprcod <> 'UPK'
    and dlytrn.prtnum = inv_sum_view.prtnum
    and inv_sum_view.invsts = 'A']