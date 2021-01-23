[select dlytrn.dlytrn_id as "Tran ID",
        dlytrn.trndte as "Date",
        dlytrn.oprcod as "OP Code",
        dlytrn.actcod as "Activity",
        dlytrn.prtnum as "SKU",
        dlytrn.orgcod as "CC Code",
        dlytrn.supnum as "Supplier",
        dlytrn.reacod as "Reason",
        dlytrn.trnqty as "QTY",
        dlytrn.frinvs as "Status",
        dlytrn.adj_ref1 as "Ref 1",
        dlytrn.adj_ref2 as "Ref 2",
        dlytrn.usr_id as "User",
        prtmst.untcst as "EA Cost",
        invact.adjqty as "Adj Qty",
        prtmst.untcst * invact.adjqty as "Total"
   from dlytrn
   join prtmst
     on (dlytrn.prtnum = prtmst.prtnum)
    and prtmst.wh_id_tmpl = 'WMD1'
   join invact
     on (dlytrn.prtnum = invact.prtnum)
    and dlytrn.trndte = invact.trndte
    and invact.actcod = 'INVADJ'
  where dlytrn.trndte BETWEEN TO_DATE('20170901000000')
    AND TO_DATE('20170930235959')]